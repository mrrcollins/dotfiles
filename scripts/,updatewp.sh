#!/bin/bash

wp=$(command -v wp)
[ -z ${wp} ] && { echo "wp-cli not found!"; exit; }

echo "Making sure wp-cli is up to date..."
sudo wp cli update

echo -e "\nList of blogs:"
cat "${HOME}/.wp-cli/config.yml" | grep "^@" | sed 's/^@//; s/:$//'
read -p "Which blog do you want to work with? " blog

echo -e "\nGetting ${blog}'s name and address...'"
blogname=$(${wp} @${blog} option get blogname)
bloghome=$(${wp} @${blog} option get home)

read -p "Do you want to see what updates are available? " yn
if ! echo "${yn}" | grep -Eiq "^n(o)?$"; then
    echo "Checking the core of ${blogname} (${bloghome})..."
    ${wp} @${blog} core check-update
    echo "Checking plugins..."
    ${wp} @${blog} plugin status | grep "^ U"
    echo "Checking themes..."
    ${wp} @${blog} theme status | grep "^ U"
fi

read -p "Update ${blogname} (${bloghome})? " yn
[ "${yn}" = "n" ] && { echo "Aborting..."; exit; }

${wp} @${blog} core update
${wp} @${blog} plugin update --all
${wp} @${blog} theme update --all


