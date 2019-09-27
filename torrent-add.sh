#! /bin/bash

# @desc Add a/a list of torrents to a client Run against a single file or list
#       of files iteratively.
# @return nil
# @requires transmission-remote

source './utilities.sh'

TORRENTS_ARRAY=()
TORRENTS_STRING=''
PORT=''

while getopts ":t:p:" opt; do
  case $opt in
    t) TORRENTS_ARRAY+=("$OPTARG")
    ;;
    p) PORT="$OPTARG"
    ;;
    \?) error "Invalid option -$OPTARG"
    # \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

for torrent in "${TORRENTS_ARRAY[@]}"
do
  TORRENTS_STRING+="$torrent "
done

eval "transmission-remote ${CLIENT_IP}:${PORT} -a $TORRENTS_STRING > /dev/null 2>&1" # TODO: auth?
# # eval "transmission-remote ${CLIENT_IP}:${PORT} -n user:pass -a $TORRENTS_STRING > /dev/null 2>&1"

if [ $? -eq 0 ]
then
  echo $(jq -n '{ code: 0, data: {} }')
else
  error "Could not add torrent"
fi
