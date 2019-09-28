#! /bin/bash

# @desc Add a/a list of torrents to a client Run against a single file or list
#       of files iteratively.
# @return nil
# @requires transmission-remote

source utilities.sh

TORRENTS_ARRAY=()
TORRENTS_STRING=''
PORT=''

while getopts ":t:p:" opt; do
  case $opt in
    t) TORRENTS_ARRAY+=("$OPTARG")
    ;;
    p) PORT="$OPTARG"
    ;;
    \?) response_error "Invalid option -$OPTARG"
    ;;
  esac
done

for torrent in "${TORRENTS_ARRAY[@]}"
do
  TORRENTS_STRING+="$torrent "
done

if transmission-remote "$CLIENT_IP":"$PORT" -a "$TORRENTS_STRING" > /dev/null 2>&1
then
  response_ok
else
  response_error "Could not add torrent"
fi
