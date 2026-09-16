#!/bin/bash

# args
site="${1}"
pic="${2}"

# Variables
tmppic="/tmp/sharepic.jpg"
wp_pic="/tmp/wp_pic.jpg"

# Picture category for site
category["r"]="361"
# 355 is Asides
category["e"]="2074"

# Post_format for picture
post_format["r"]="359"
post_format["e"]=""

# Author
author["r"]="1"
author["e"]="1"

# Functions
comment() {
    [ ! -z ${debug} ] && echo "${1}"
}

comment "Setting up the filename and extension"
ext="${pic##*.}"
md5=$(md5sum "${pic}" | awk '{print $1}' | head -c 5)
filename=$(date +"%Y-%m-%d-%H-%M")"-${md5}.${ext}"
comment "Filename is ${filename}"

comment "Resize the ${pic} to be 1080 width (${wp_pic})"
convert "${pic}" -resize 1080x "${wp_pic}"

comment "Upload image to WP..."
host=$(grep -A 1 @${site} ${HOME}/.wp-cli/config.yml | grep ssh | cut -d " " -f 6)
scp "${wp_pic}" "${host}:/tmp/${filename}"
imgid=$(wp @${site} media import "/tmp/${filename}" --porcelain )
imgurl=$(wp @${site} db query "SELECT guid FROM wp_posts  WHERE ID=\"${imgid}\"" | head -n 2 | tail -1)
comment "Image uploaded with ID of ${imgid} (${imgurl})"

post="
<!-- wp:image {\"id\":${imgid},\"sizeSlug\":\"medium\",\"linkDestination\":\"none\",\"align\":\"center\"} -->
<figure class=\"wp-block-image aligncenter size-medium\"><img src=\"${imgurl}\" alt=\"\" class=\"wp-image-${imgid}\"/></figure>
<!-- /wp:image -->
"
title="Draft post for ${imgid}"

if [ -f "/tmp/msg.txt" ]; then
	msgfile="/tmp/msg.txt"
	{
		IFS= read -r title
		IFS= read -r tags
		body=$(cat)
	} < "$msgfile"

formatted_body=$(
    printf '%s\n' "$body" |
    awk '
        BEGIN {
            RS=""
            ORS=""
        }

        {
            gsub(/\n/, " ")
            print "<!-- wp:paragraph -->\n"
            print "<p>" $0 "</p>\n"
            print "<!-- /wp:paragraph -->\n\n"
        }
    '
)

post+=$'\n'"$formatted_body"

fi

comment "Create draft..."
#echo "Site: ${site}
#Tite: ${title}
#Author: ${author[${site}]}
#Category= ${category[$site]}
#"

postid=$(printf '%s' "$post" | wp "@${site}" post create - \
        --porcelain \
        --post_title="$title" \
        --tags_input="$tags" \
        --post_author="${author[$site]}" \
        --post_type="post" \
        --post_status="draft" \
        --post_category="361")


