#!/bin/bash
#

source "${HOME}/.goz2me"

#curl --silent -H "Content-Type: multipart/form-data" -H "authorization: $TOKEN" -H "No-JSON: true" -F file=@"$1" $HOST/api/upload | cut -d "\"" -f4 | pbcopy
curl --silent -H "Content-Type: multipart/form-data" -H "authorization: $TOKEN" -H "No-JSON: true" -F file=@"$1" $HOST/api/upload | pbcopy

