# sharing_is_caring_v2

This tool help you compare the shares access between multiple users.

clone

```bash
git clone --recursive https://github.com/yack-security/sharing_is_caring_v2.git
```

```bash
pip3 install -r requirements.txt
pip3 install -r FindUncommonShares/requirements.txt

# modify the config.json file
# ...

# collect shares
./sharing_is_caring_v2.sh

# compare shares
python3 compare.py --no-ipc --no-print
```

Compare Usage:

```bash
usage: compare.py [-h] [--no-print] [--no-ipc] [directory] [output_file]

Compare JSON files in a directory.

positional arguments:
  directory    Path to the directory containing JSON files (default: ./data)
  output_file  Path for the output JSON file (default: output.json)

options:
  -h, --help   show this help message and exit
  --no-print   Exclude "print$" shares from the results
  --no-ipc     Exclude "IPC$" shares from the results
```

Docker usage

note: the docker image also include manspider

```bash
# pull the image
docker pull ghcr.io/yack-security/sharing_is_caring_v2:main
# if problem with architecture go check the 'OS / Arch' tab on this page: https://github.com/yack-security/sharing_is_caring_v2/pkgs/container/sharing_is_caring_v2. Should work on Mac M* and on AMD64
# enter the new image
docker run -it $(docker images --no-trunc | grep sharing_is_caring_v2 | cut -d ':' -f2 | cut -d " " -f1) -v $(pwd)/shared_output:/app/sharing_is_caring_v2 -v $(pwd)/shared_output:/app/manspider
# to make sure everything is working
cd /app/sharing_is_caring_v2
pip3 install -r requirements.txt
pip3 install -r FindUncommonShares/requirements.txt
#
# modify the config.json file
# fun sharing_is_caring_v2.sh to collect shares information
./sharing_is_caring_v2.sh
# parse the data and output a .json and .csv file.
python3 compare.py --no-ipc --no-print
#
# when finished, exit the container
exit
# oneliner for delete container and image
docker container rm $(docker container ls -a --no-trunc | grep $(docker images --no-trunc | grep sharing_is_caring_v2 | cut -d ':' -f2 | cut -d " " -f1) | cut -d " " -f1) && docker image rm $(docker images --no-trunc | grep sharing_is_caring_v2 | cut -d ':' -f2 | cut -d " " -f1)
```

Credits

- [p0dalirius](https://github.com/p0dalirius) for FindUncommonShares
- [blacklanternsecurity](https://github.com/blacklanternsecurity) for manspider
