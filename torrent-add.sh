#! /bin/bash

# @desc Add a/a list of torrents to a client Run against a single file or list
#       of files iteratively.
# @return nil
# @requires transmission-remote

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

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
    if ! transmission-remote localhost:"$port" -a "$APP_DIR/torrents/$torrent" > /dev/null 2>&1; then
      response_error "Could not add torrents"
    fi
  done
done


response_ok
