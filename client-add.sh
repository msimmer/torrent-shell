#! /bin/bash

# Add multiple torrent clients

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

RPC_PORTS=()
TRANSMISSION_PORTS=()
TRANSMISSION_PORTS_PROTOCOL=()
SETTINGS=$(< "$CLIENT_SETTINGS_PATH")

while getopts ":p:P:" opt; do
  case $opt in
    p) RPC_PORTS+=("$OPTARG")
    ;;
    P)
      TRANSMISSION_PORTS+=("$OPTARG")
      TRANSMISSION_PORTS_PROTOCOL+=("$OPTARG/tcp")
    ;;
    \?) response_error "Invalid option -$OPTARG"
    ;;
  esac
done

# Requires same number of arguments to be passed into both RPC_PORTS (-p) and
# TRANSMISSION_PORTS (-P)
if [[ ${#RPC_PORTS[@]} -ne ${#TRANSMISSION_PORTS[@]} || ${#RPC_PORTS[@]} -gt 1 || ${#TRANSMISSION_PORTS[@]} -lt 1 ]]; then
  response_error "Incorrect number of arguments for rpc-ports and transmission-ports"
fi

# Create the settings files and add them to each client's working dir.
# Instantiate the clients using systemd. Pass in the newly created settings.json
# file for each to create the necessary folder structure based on each client's
# home directory
for i in "${!RPC_PORTS[@]}"
do
  rpc_port="${RPC_PORTS[i]}"
  transmission_port="${TRANSMISSION_PORTS[i]}"
  client_name="transmission-$rpc_port"

  # Modify settings for each client
  SETTINGS=$(perl -X -pi -e "s/(\"peer-port\":) [^,]+/\1 $transmission_port/" <<< "$SETTINGS")
  SETTINGS=$(perl -X -pi -e "s/(\"rpc-port\":) [^,]+/\1 $rpc_port/" <<< "$SETTINGS")
  SETTINGS=$(perl -X -pi -e "s/(\"rpc-authentication-required\":) [^,]+/\1 false/" <<< "$SETTINGS")
  SETTINGS=$(perl -X -pi -e "s/(\"rpc-password\":) [^,]+/\1 \"$(date +%s | sha256sum | base64 | head -c 32)\"/" <<< "$SETTINGS")
  SETTINGS=$(perl -X -pi -e "s/(\"rpc-url\":) [^,]+/\1 \"\/$client_name\/\"/" <<< "$SETTINGS")
  SETTINGS=$(perl -X -pi -e "s/(\"rpc-username\":) [^,]+/\1 \"$client_name\"/" <<< "$SETTINGS")

  # Write the settings files
  sudo mkdir -p "$CLIENT_ROOT/$client_name"
  echo "$SETTINGS" | sudo tee "$CLIENT_ROOT/$client_name/settings.json" > /dev/null

  # Set permissions
  sudo chown -R "$TRANSMISSION_USER":"$TRANSMISSION_GROUP" "$CLIENT_ROOT/$client_name"

  # Start the client
  if ! sudo service "transmission-daemon@$client_name" start; then
    response_error "Could not start client $client_name"
  fi
done

# Add ports to UFW and reload the firewall
for i in "${!RPC_PORTS[@]}"
do
  sudo ufw allow "${RPC_PORTS[i]}","${TRANSMISSION_PORTS_PROTOCOL[i]}"
done

sudo ufw reload

response_ok
