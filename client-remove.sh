#! /bin/bash

# Add multiple torrent clients

source utilities.sh

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
  if ! rm -rf "${CLIENT_ROOT:?}/$client_name"; then
    response_error "Could not remove client directory ${CLIENT_ROOT}/$client_name"
  fi
done

# Delete ports from UFW and reload the firewall
RPC_PORTS_STRING=$(join , "${RPC_PORTS[@]}")
TRANSMISSION_PORTS_STRING=$(join , "${TRANSMISSION_PORTS[@]}")

sudo ufw delete "$RPC_PORTS_STRING","$TRANSMISSION_PORTS_STRING"
sudo ufw reload

response_ok
