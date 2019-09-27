#! /bin/bash

source './utilities.sh'

HASH_ARRAY=()
WHITELIST_ARRAY=()
OUTPUT_ARRAY=()
MODIFIED=0

# Get CLI args
while getopts ":h:" opt; do
  case $opt in
    h) HASH_ARRAY+=("$OPTARG")
    ;;
    \?) error "Invalid option -$OPTARG"
    ;;
  esac
done

# Build arrays for the whitelist and the new hashes so that we can check for
# duplicates
while read line
do
  WHITELIST_ARRAY+=("$line")
done < $TRACKER_WHITELIST

# Only append unique items to the whitelist
for hash in "${WHITELIST_ARRAY[@]}"
do
  if [[ ! " ${HASH_ARRAY[@]} " =~ " ${hash} " ]]; then
    OUTPUT_ARRAY+=("$hash")
  else
    MODIFIED=$((MODIFIED + 1))
  fi
done

(IFS=$'\n'
echo "${OUTPUT_ARRAY[*]}" > $TRACKER_WHITELIST)

echo $(jq -n --arg modified "$MODIFIED" '{
  code: 0,
  data: { modified: $modified }
}')
