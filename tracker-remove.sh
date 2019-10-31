#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

HASH_ARRAY=()
WHITELIST_ARRAY=()
OUTPUT_ARRAY=()
MODIFIED=0

# Get CLI args
while getopts ":h:" opt; do
  case $opt in
    h) HASH_ARRAY+=("$OPTARG")
    ;;
    \?) response_error "Invalid option -$OPTARG"
    ;;
  esac
done

# Build arrays for the whitelist and the new hashes so that we can check for
# duplicates
while read -r line
do
  WHITELIST_ARRAY+=("$line")
done < "$TRACKER_WHITELIST"

# Only append unique items to the whitelist
for hash in "${WHITELIST_ARRAY[@]}"
do
  # shellcheck disable=SC2199,SC2076
  if [[ ! " ${HASH_ARRAY[@]} " =~ " $hash " ]]; then
    OUTPUT_ARRAY+=("$hash")
  else
    MODIFIED=$((MODIFIED + 1))
  fi
done

(IFS=$'\n'
echo "${OUTPUT_ARRAY[*]}" > "$TRACKER_WHITELIST")

# shellcheck disable=SC2005
echo "$(jq -n --arg modified "$MODIFIED" '{
  code: 0,
  data: { modified: $modified }
}')"
