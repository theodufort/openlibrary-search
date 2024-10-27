import json
import re

def process_text_file(input_text):
    # Fields to exclude from the JSON objects
    fields_to_exclude = {
        "publishers", "key", "created", "number_of_pages",
        "last_modified", "authors", "latest_revision",
        "works", "type", "revision"
    }

    # Regular expression pattern to extract JSON objects
    json_pattern = re.compile(r'(\{.*?\})(?=\s*/type|$)', re.DOTALL)

    # Find all JSON objects in the text
    json_objects = json_pattern.findall(input_text)

    # List to store parsed JSON data
    data_list = []

    for obj in json_objects:
        try:
            # Clean up the JSON string
            obj_clean = obj.replace('\n', '').replace('\r', '').strip()
            # Parse JSON data
            data = json.loads(obj_clean)
            # Remove unwanted fields
            filtered_data = {k: v for k, v in data.items() if k not in fields_to_exclude}
            data_list.append(filtered_data)
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON object: {e}")
            continue

    return data_list

if __name__ == "__main__":
    # Replace 'input.txt' with your text file's path
    with open('ol_dump_editions.txt', 'r', encoding='utf-8') as file:
        input_text = file.read()

    processed_data = process_text_file(input_text)

    # Output the processed data to a JSON file
    with open('processed_data.json', 'w', encoding='utf-8') as outfile:
        json.dump(processed_data, outfile, indent=4)

    print("Data has been processed and saved to 'processed_data.json'.")

#Sample output
# [
#     {
#         "isbn_13": [
#             "9780106912612"
#         ],
#         "physical_format": "Paperback",
#         "isbn_10": [
#             "0106912615"
#         ],
#         "publish_date": "December 31, 1995",
#         "title": "40index to the House of Commons Parliamentary Debates (Hansard)"
#     },
#     {
#         "title": "House of Lords Official Report (Parliamentary Debates (Hansard): 1991-92)",
#         "isbn_13": [
#             "9780107002992"
#         ],
#         "physical_format": "Paperback",
#         "isbn_10": [
#             "010700299X"
#         ],
#         "publish_date": "December 9, 1998",
#         "subjects": [
#             "Central government",
#             "United Kingdom, Great Britain"
#         ]
#     }
# ]
