import json
import re
import os

ORDER_UP_TO = 511

print("Turning invalid lines into JSON ")
REGEX = r'^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),(.*)$'
with open("all.json") as infile:
    with open("all.json.fixed", "w") as outfile:
        for lineno, line in enumerate(infile):
            if ",fail," in line:
                org = line
                line = re.sub(REGEX, r'[\1,\2,\3,\4,\5,\6,null,[\8,\9],"\10"],', line)
            outfile.write(line)
        replace_line = lineno - 1

# open the file again
print("Removing trailing comma")
REGEX_2 = r'^(.*),(\s)*$'
with open("all.json", "w") as outfile:
    with open("all.json.fixed") as infile:
        for lineno, line in enumerate(infile):
            if lineno == replace_line:
                line = re.sub(REGEX_2, r'\1\2', line)
            outfile.write(line)

# check that it's valid json now
print("Removing unuused field and filtering")
with open("all.json") as infile:
    data = json.load(infile)

data = [
    row[0:6] + row[7:9] for row in data if row[0] <= ORDER_UP_TO
]

for row in data:
    if len(row) != 8:
        print("FAILURE")

print("Writing final result of {} items".format(len(data)))
with open("all.json", "w") as outfile:
    json.dump(data, outfile)