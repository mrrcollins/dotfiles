#!/bin/bash

# Requires `faketime` to be installed
if ! command -v faketime &> /dev/null
then
    echo "faketime could not be found, please install"
    exit
fi

if [ $(date +"%u") == "1" ]; then
    first=$(date +"%Y-%m-%d")
else
    first=$(date -d "last monday" +"%Y-%m-%d")
fi

temp="##############"

echo "|--   MON    --|--   TUE    --|--   WED    --|--   THR    --|--   FRI    --|--   SAT    --|--   SUN    --|"
for day in {0..29..7}
do
    dateline=""
    artline=""
    blankline=""

    for dow in {0..6}
    do
        calcday=$(($day + $dow))
        tday=$(faketime "${first} 12:00:00" date -d "${calcday} day" +"%Y-%m-%d")
        file=$(grep -i ^date\: *.md | grep "${tday}" | cut -d ":" -f 1)

        if [[ ${file:0:2} == "20" ]]; then
            out=${file:11:14}
        else
            out=${file:0:14}
        fi

        if [ -z ${file} ]; then out=" "; fi
        dateline=${dateline}$(echo -en "|--${tday}--")
        #artline="${artline}"$(echo "|${temp:0:-${#out}}${out}")
        artline="${artline}"$(printf "|%-14s" ${out})
        blankline="${blankline}|              "
    done

    echo "${dateline}|"
    echo "${artline}|"
    echo "${blankline}|"
done
