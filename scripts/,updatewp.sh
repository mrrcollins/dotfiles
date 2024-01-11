#!/bin/bash

wp="/usr/local/bin/wp"

echo "Which blog? (enter the alias only):"
cat "${HOME}/.wp-cli/config.yml" | grep "^@"
read -e blog

echo "Working on @${blog}..."
${wp} @${blog} core update
${wp} @${blog} plugin update --all
${wp} @${blog} theme update --all


