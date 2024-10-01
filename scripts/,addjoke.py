#!/usr/bin/python3

import sys

# Define the file where your Kanban board is located
file_path = "/home/goz/notes/Notes/ContentCreator/jokes-planning.md"

# Get the task passed from the command line
task = sys.argv[1]

# Read the file
with open(file_path, "r") as file:
    lines = file.readlines()

# Locate the Inventory section and add the task
inventory_found = False
for i in range(len(lines)):
    if lines[i].strip() == "## Inventory":
        inventory_found = True
    # Check when the Inventory section ends and trim any blank lines before adding the task
    if inventory_found and (i + 1 == len(lines) or (lines[i + 1].startswith("##") and lines[i].strip())):
        # Remove blank lines at the end of the Inventory section
        while lines[i].strip() == "":
            lines.pop(i)
        # Insert the new task right after the last item in the Inventory section
        lines.insert(i + 1, f"- [ ] {task}\n")
        break

# Write the changes back to the file
with open(file_path, "w") as file:
    file.writelines(lines)

print(f"Task '{task}' added to the Inventory list.")

