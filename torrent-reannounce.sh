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
  CLIENT="localhost:${RPC_PORTS[i]}"
  sudo transmission-remote "$CLIENT" -tall --reannounce
done

response_ok
