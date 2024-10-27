import json
import os

def split_json_by_language(input_json_file):
    # Read the processed data
    with open(input_json_file, 'r', encoding='utf-8') as infile:
        data_list = json.load(infile)

    # Dictionary to hold lists of objects per language
    language_dict = {}

    for item in data_list:
        languages = item.get('languages', [])
        if not languages:
            continue  # Skip items without languages

        for lang_code in languages:
            # Initialize the list for this language if not already done
            if lang_code not in language_dict:
                language_dict[lang_code] = []
            # Add the item to the language-specific list
            language_dict[lang_code].append(item)

    # Write out the data for each language
    for lang_code, items in language_dict.items():
        output_file = f"rag_{lang_code}.json"
        with open(output_file, 'w', encoding='utf-8') as outfile:
            json.dump(items, outfile, indent=4)
        print(f"Data for language '{lang_code}' has been saved to '{output_file}'.")

if __name__ == "__main__":
    # Replace 'processed_data.json' with your input file path if needed
    input_json_file = 'processed_data.json'
    split_json_by_language(input_json_file)
