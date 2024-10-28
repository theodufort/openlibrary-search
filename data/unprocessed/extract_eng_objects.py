import json

def extract_eng_language_objects(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as infile:
        data_list = json.load(infile)

    # List to store objects that contain {"key": "/languages/eng"}
    eng_objects = []

    for item in data_list:
        languages = item.get('languages', [])
        # Check if "languages" contains {"key": "/languages/eng"}
        for lang in languages:
            if lang.get('key') == '/languages/eng':
                eng_objects.append(item)
                break  # No need to check other languages in this item

    # Write the filtered data to the output file
    with open(output_file, 'w', encoding='utf-8') as outfile:
        json.dump(eng_objects, outfile, indent=4)

    print(f"Extracted {len(eng_objects)} objects with English language to '{output_file}'.")

if __name__ == '__main__':
    input_file = 'processed_data.json'  # Replace with your input JSON file
    output_file = 'eng_only.json'       # Output file for English language objects
    extract_eng_language_objects(input_file, output_file)
