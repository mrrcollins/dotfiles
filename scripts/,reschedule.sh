#!/bin/bash

newdate="${1}"
file="${2:11}"

echo "Changing the date of ${2} to ${newdate}-${file}..."

git mv "${2}" "${newdate}-${file}"


