#! /bin/bash

source './utilities.sh'

RPC_PORTS=()
TRANSMISSION_PORTS=()
TRANSMISSION_PORTS_PROTOCOL=()
SETTINGS="$(< $CLIENT_SETTINGS_PATH)"
# RPC_PASSWORD=''

while getopts ":p:P:" opt; do
  case $opt in
    p) RPC_PORTS+=("$OPTARG")
    ;;
    P)
      TRANSMISSION_PORTS+=("$OPTARG")
      TRANSMISSION_PORTS_PROTOCOL+=("$OPTARG/tcp")
    ;;
    \?) error "Invalid option -$OPTARG"
    ;;
  esac
done


# Add ports to UFW
# sudo ufw allow $(join , "${RPC_PORTS[@]}"),$(join , "${TRANSMISSION_PORTS_PROTOCOL[@]}")
# sudo ufw reload

# x=$(join , "${RPC_PORTS[@]}")
# y=$(join , "${TRANSMISSION_PORTS[@]}")
# z=$(join , "${TRANSMISSION_PORTS_PROTOCOL[@]}")
# echo $x
# echo $y
# echo $z

# echo "${RPC_PORTS[*]}"
# echo "${TRANSMISSION_PORTS[*]}"
