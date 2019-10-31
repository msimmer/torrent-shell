#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

RPC_PORTS=()

while getopts ":p:" opt; do
  case $opt in
    p) RPC_PORTS+=("$OPTARG")
    ;;
    \?) response_error "Invalid option -$OPTARG"
    ;;
  esac
done

for i in "${!RPC_PORTS[@]}"
do
  client_name="transmission-${RPC_PORTS[i]}"
  if ! sudo service "transmission-daemon@$client_name" start; then
    response_error "Could not start client $client_name"
  fi
done

response_ok
