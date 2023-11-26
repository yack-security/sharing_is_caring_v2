# sharing_is_caring_v2

clone

```bash
git clone --recursive https://github.com/yack-security/sharing_is_caring_v2.git
```

```bash
pip3 install -r requirements.txt
pip3 install -r FindUncommonShares/requirements.txt

# set the config.json file
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

credits

- [p0dalirius](https://github.com/p0dalirius)
