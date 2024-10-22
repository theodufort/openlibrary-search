import csv
import ctypes as ct
import os
import json

# See https://stackoverflow.com/a/54517228 for more info on this
csv.field_size_limit(int(ct.c_ulong(-1).value // 2))

LINES_PER_FILE = 2000000

INPUT_PATH = "./data/unprocessed/"
OUTPUT_PATH = "./data/processed/"

FILE_IDENTIFIERS = ['authors', 'works', 'editions']

# Define fields to remove for each identifier
FIELDS_TO_REMOVE = {
    'authors': [],
    'works': [],
    'editions': ["latest_revision", "last_modified", "type", "works", "created", "source_records", "key", "revision", "lccn", "pagination", "table_of_contents", "lc_classifications", "by_statement"],
}

def filter_json_data(json_string, fields_to_remove):
    """Filter out unwanted fields from the JSON data if it's a JSON object."""
    try:
        data = json.loads(json_string)
        if isinstance(data, dict):
            for field in fields_to_remove:
                data.pop(field, None)
            return json.dumps(data)
        else:
            return json_string  # Return original string if it's not a JSON object
    except json.JSONDecodeError:
        return json_string  # Return original string if it's not valid JSON

def run():
    """Run the script."""

    filenames_array = []
    file_id = 0

    for identifier in FILE_IDENTIFIERS:
        print('Currently processing ', identifier)

        filenames = []
        csvoutputfile = None

        with open(os.path.join(INPUT_PATH, ('ol_dump_' + identifier + '.txt')), encoding="utf-8") as cvsinputfile:
            reader = csv.reader(cvsinputfile, delimiter='\t')

            for line, row in enumerate(reader):

                if line % LINES_PER_FILE == 0:
                    if csvoutputfile:
                        csvoutputfile.close()

                    filename = identifier + '_{}.csv'.format(line + LINES_PER_FILE)
                    filenames.append(filename)
                    csvoutput = open(os.path.join(OUTPUT_PATH, filename), "w", newline="", encoding="utf-8")
                    writer = csv.writer(csvoutput, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)

                if len(row) > 4:
                    # Get fields to remove for the current identifier
                    fields_to_remove = FIELDS_TO_REMOVE.get(identifier, [])
                    filtered_json = filter_json_data(row[4], fields_to_remove)
                    
                    # Handle the 6th column (work_key) for editions
                    if identifier == 'editions':
                        work_key = row[5] if len(row) > 5 else ''
                        writer.writerow([row[0], row[1], row[2], row[3], filtered_json, work_key])
                    else:
                        writer.writerow([row[0], row[1], row[2], row[3], filtered_json])

                else:
                    writer.writerow(row)  # Write the row as-is if it doesn't have the data column

            if csvoutputfile:
                csvoutputfile.close()

        filenames_array.append([identifier, str(file_id), False, filenames])

        print('\n', identifier, 'text file has now been processed.\n')
        print(identifier, str(file_id), filenames)
        file_id += 1

    # List of filenames that can be loaded into the database for automatic file reading.
    with open(os.path.join(OUTPUT_PATH, "filenames.txt"), "a", newline="", encoding="utf-8") as filenamesoutput:
        filenameswriter = csv.writer(filenamesoutput, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        for row in filenames_array:
            filenameswriter.writerow([row[0], row[1], row[2], '{' + ','.join(row[3]).strip("'") + '}'])

    print("Process complete")

run()
