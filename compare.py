import json
import os
import argparse
import re
from utils.banner import generate_banner
from utils.convert import convert_json_to_csv, flatten_json

def load_json(file_path):
    """Load JSON data from a file."""
    with open(file_path, 'r') as file:
        return json.load(file)

def get_user_identifier(file_path):
    """Extract the username from the file name."""
    match = re.search(r'_([^.]+)\.json', file_path)
    return match.group(1) if match else 'unknown'

def get_shares(data, exclude_print, exclude_ipc):
    """Extract shares information, optionally excluding specified shares."""
    shares_info = {
        'readable_shares': set(),
        'writable_shares': set()
    }
    for computer, shares in data.items():
        for share in shares:
            share_name = share['share']['name']
            if exclude_print and share_name == "print$":
                continue
            if exclude_ipc and share_name == "IPC$":
                continue

            share_tuple = (computer, share_name, share['share']['uncpath'])
            if share['share']['access_rights']['readable']:
                shares_info['readable_shares'].add(share_tuple)
            if share['share']['access_rights']['writable']:
                shares_info['writable_shares'].add(share_tuple)
    return shares_info

def find_unique_shares(data_shares, other_data_shares):
    """Find unique shares in 'data_shares' compared to 'other_data_shares'."""
    unique_shares = {
        'unique_readable_shares': list(data_shares['readable_shares'] - other_data_shares['readable_shares']),
        'unique_writable_shares': list(data_shares['writable_shares'] - other_data_shares['writable_shares'])
    }
    return unique_shares

def compare_json_files_in_directory(directory, output_file_path, exclude_print, exclude_ipc):
    """Compare all JSON files in a directory and output the results in another JSON file."""
    file_paths = [os.path.join(directory, file) for file in os.listdir(directory) if file.endswith('.json')]
    user_identifiers = [get_user_identifier(file) for file in file_paths]
    all_data_shares = [get_shares(load_json(file_path), exclude_print, exclude_ipc) for file_path in file_paths]
    output_json = {}

    for i, (data_shares, user_id) in enumerate(zip(all_data_shares, user_identifiers)):
        user_key = f"{user_id}"

        comparaisons = {}
        for j, (other_data_shares, other_user_id) in enumerate(zip(all_data_shares, user_identifiers)):
            if i != j:
                other_user_key = f"{other_user_id}"
                unique_shares = find_unique_shares(data_shares, other_data_shares)

                comparaisons[f"unique_shares_vs_{other_user_key}"] = {
                    "readable_count_diff": len(unique_shares['unique_readable_shares']),
                    "writable_count_diff": len(unique_shares['unique_writable_shares']),
                    "shares": unique_shares
                }

        output_json[user_key] = {
            "total_readable_shares": len(data_shares['readable_shares']),
            "total_writable_shares": len(data_shares['writable_shares']),
            "comparaisons": comparaisons
        }

    with open(output_file_path, 'w') as file:
        json.dump(output_json, file, indent=4)

# Command-line argument parsing
parser = argparse.ArgumentParser(description='Compare JSON files in a directory.')
parser.add_argument('directory', nargs='?', default="./data", help='Path to the directory containing JSON files (default: ./data)')
parser.add_argument('output_file', nargs='?', default='output.json', help='Path for the output JSON file (default: output.json)')
parser.add_argument('--no-print', action='store_true', help='Exclude "print$" shares from the results')
parser.add_argument('--no-ipc', action='store_true', help='Exclude "IPC$" shares from the results')

args = parser.parse_args()

# Running the script
generate_banner()
compare_json_files_in_directory(args.directory, args.output_file, args.no_print, args.no_ipc)
input_json_file = args.output_file
output_csv_file = 'output.csv'
convert_json_to_csv(input_json_file, output_csv_file)