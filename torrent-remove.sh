#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

TORRENTS=()
PORTS=()
TORRENTS_STRING=''

while getopts ":t:p:" opt; do
  case $opt in
    t) TORRENTS+=("$OPTARG")
    ;;
    p) PORTS+=("$OPTARG")
    ;;
    \?) response_error "Invalid option -$OPTARG"
    ;;
  esac
done

for torrent in "${TORRENTS[@]}"
do
  TORRENTS_STRING+="$torrent "
done

for port in "${PORTS[@]}"
do
  if ! transmission-remote localhost:"$port" -r "$TORRENTS_STRING" > /dev/null 2>&1; then
    response_error "Could not remove torrents"
  fi
done

response_ok
