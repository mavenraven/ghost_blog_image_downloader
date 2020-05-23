#!/bin/sh
# shellcheck disable=SC2002

SITE_NAME="$1"
INPUT_FILE="$2"

if [ -z "$SITE_NAME" ]; then
    echo 'site name required, should be of the form https://hello.ghost.io'
    exit 1
fi

if [ -z "$INPUT_FILE" ]; then
    echo 'input file required, should be of the form hello.2020-05-21-05-45-33.json'
    exit 1
fi

set -eu

if ! command -v pup > /dev/null; then 
    echo 'pup not on path. Run go get github.com/ericchiang/pup and add ~/go/bin to your PATH.'
    exit 1
fi

if ! command -v jq > /dev/null; then 
    echo 'jq not on path'
    exit 1
fi

if ! command -v wget > /dev/null; then 
    echo 'wget not on path'
    exit 1
fi

SCRIPT_NAME=$(mktemp)
#hacky, but just generate a bunch of pup commands to execute
cat "$INPUT_FILE" | jq  '{html: ..|.html? }' | jq 'select(.html != null)' | jq -r '"echo \(.html|@sh) | pup img attr{src}"'  > "$SCRIPT_NAME"
LINKS=$(sh "$SCRIPT_NAME" | xargs -I {} sh -c "printf \"$SITE_NAME{}\n\"") 
echo "$LINKS" | wget --force-directories --input-file -
