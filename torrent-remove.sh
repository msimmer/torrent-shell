#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilitie.sh"

TORRENTS=()
PORTS=()

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
  for port in "${PORTS[@]}"
  do
    if ! transmission-remote localhost:"$port" -t "$torrent" -r > /dev/null 2>&1; then
      response_error "Could not remove torrents"
    fi
  done
done


response_ok
