#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

TORRENT_HASHES=()
PORTS=()

while getopts ":t:p:" opt; do
  case $opt in
    t) TORRENT_HASHES+=("$OPTARG")
    ;;
    p) PORTS+=("$OPTARG")
    ;;
    \?) response_error "Invalid option -$OPTARG"
    ;;
  esac
done

for hash in "${TORRENT_HASHES[@]}"
do
  for port in "${PORTS[@]}"
  do
    if ! transmission-remote localhost:"$port" -t "$hash" -r > /dev/null 2>&1; then
      response_error "Could not remove torrents"
    fi
  done
done


response_ok
