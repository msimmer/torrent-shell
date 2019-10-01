#! /bin/bash

# @desc Add a/a list of torrents to a client Run against a single file or list
#       of files iteratively.
# @return nil
# @requires transmission-remote

source utilities.sh

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
  TORRENTS_STRING+="$APP_DIR/torrents/$torrent "
done

for port in "${PORTS[@]}"
do
  if ! transmission-remote "$CLIENT_IP":"$port" -a "$TORRENTS_STRING" > /dev/null 2>&1; then
    response_error "Could not add torrents"
  fi
done

response_ok
