#! /bin/bash

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
  TORRENTS_STRING+="$torrent "
done

for port in "${PORTS[@]}"
do
  if ! transmission-remote "$CLIENT_IP":"$port" -r "$TORRENTS_STRING" > /dev/null 2>&1; then
    response_error "Could not remove torrents"
  fi
done

response_ok