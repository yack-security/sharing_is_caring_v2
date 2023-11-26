#!/bin/bash

repo_path=$(pwd)
# data_path arg 1 or default to data
data_path=$repo_path/${1:-data}
# domain
domain=$(jq -r '.Domain' "$repo_path/config.json")
# dc ip
dc_ip=$(jq -r '.DCIP' "$repo_path/config.json")

if [ ! -d "$data_path" ]; then
    mkdir "$data_path"
fi

# loop through all users in the config and run FindUncommonShares
function loopUsers() {
    for user in $(jq -r '.Users[].Username' "$repo_path/config.json"); do
        echo ""
        echo "Checking shares for $user"
        password=$(jq -r --arg user "$user" '.Users[] | select(.Username == $user) | .Password' "$repo_path/config.json")
        # echo "$user"
        # check if password value is none
        if [[ "$password" == "null" || "$password" == "none" ]]; then
            # check if hash value is none
            hash=$(jq -r --arg user "$user" '.Users[] | select(.Username == $user) | .NTLM_Hash' "$repo_path/config.json")
            if [[ "$hash" == "null" || "$hash" == "none" ]]; then
                # skip user
                echo "Password and No hash found. Skipping [$user]"
            else
                # echo "NTLM_Hash: $hash"
                runFindUncommonSharesHash
            fi
        else
            # echo "$password"
            runFindUncommonSharesPassword
        fi
    done
}

function runFindUncommonSharesPassword() {
  echo ""
  python3 FindUncommonShares/FindUncommonShares.py -u "$user" -p "$password" -d "$domain" --dc-ip "$dc_ip" --check-user-access --export-json "$data_path/results_$user.json"
}

function runFindUncommonSharesHash() {
  echo ""
  python3 FindUncommonShares/FindUncommonShares.py -u "$user" -H "$hash" -d "$domain" --dc-ip "$dc_ip" --check-user-access --export-json "$data_path/results_$user.json"
}

function theEnd() {
  echo ""
  echo "Data saved to $data_path"
  echo "You can now run compare.py to compare the results"
  echo ""
  echo "Example: python3 compare.py"
  echo "Example: python3 compare.py --no-ipc --no-print"
  echo "Example: python3 compare.py --help"
}

function doActions() {
  python3 utils/banner.py
  loopUsers
  theEnd
}
doActions