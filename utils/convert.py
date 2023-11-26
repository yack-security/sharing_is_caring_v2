import json
import csv

def flatten_json(json_data):
    flattened_data = []

    for user, user_data in json_data.items():
        for comp_user, comp_data in user_data.get("comparaisons", {}).items():
            for share_type in ["unique_readable_shares", "unique_writable_shares"]:
                for share in comp_data["shares"].get(share_type, []):
                    flattened_data.append({
                        "User": user,
                        "Comparaison User": comp_user,
                        "Share Type": share_type,
                        "Computer": share[0],
                        "Share Name": share[1],
                        "UNC Path": share[2],
                        "Readable Count Diff": comp_data["readable_count_diff"],
                        "Writable Count Diff": comp_data["writable_count_diff"]
                    })
    return flattened_data

def convert_json_to_csv(json_file_path, csv_file_path):
    # Load JSON data
    with open(json_file_path, 'r') as file:
        data = json.load(file)

    # Flatten the JSON data
    flattened_data = flatten_json(data)

    # Write to the CSV file
    with open(csv_file_path, 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=flattened_data[0].keys())
        writer.writeheader()
        for item in flattened_data:
            writer.writerow(item)

# Example usage
# input_json_file = 'output.json'
# output_csv_file = 'output.csv'
# convert_json_to_csv(input_json_file, output_csv_file)