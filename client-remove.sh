#! /bin/bash

# Add multiple torrent clients

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilitie.sh"

RPC_PORTS=()
TRANSMISSION_PORTS=()

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
  rpc_port="${RPC_PORTS[i]}"
  client_name="transmission-$rpc_port"
  transmission_port=$(jq '.["peer-port"]' < "$CLIENT_ROOT/$client_name/settings.json")

  # Add to the ports that will be deleted from UFW
  TRANSMISSION_PORTS+=("$transmission_port/tcp")

  # Stop the client
  if ! sudo service "transmission-daemon@$client_name" stop; then
    response_error "Could not stop client $client_name"
  fi

  # Remove the client's home directory
  if ! sudo rm -rf "${CLIENT_ROOT:?}/$client_name"; then
    response_error "Could not remove client directory ${CLIENT_ROOT}/$client_name"
  fi
done

# Close ports from UFW and reload the firewall
for i in "${!RPC_PORTS[@]}"
do
  sudo ufw deny "${RPC_PORTS[i]}","${TRANSMISSION_PORTS[i]}"
done

sudo ufw reload

response_ok
