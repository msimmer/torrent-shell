#! /bin/bash

# @desc Create torrent file from source. Single file passed in via CLI argument.
#       Run against a single file or list of files iteratively.
# @return Torrent hash
# @requires transmission-create transmission-show

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

OUTPUT_FILENAME="$1.torrent"


if sudo transmission-create -o "$APP_DIR/torrents/$OUTPUT_FILENAME" -t "$TRACKER_URL_UDP" "$TMP_DIR/$1" > /dev/null 2>&1
  # Create the torrents and get the hash
  then
  # Add tier 2 tracker URL
  if sudo transmission-edit -a "$TRACKER_URL_TCP" "$APP_DIR/torrents/$OUTPUT_FILENAME" > /dev/null 2>&1
  then
    # Move source file to app dir -- TODO: since all the clients are happy to
    # share a single dir, that dir should be made the sources dir
    sudo mv "$TMP_DIR/$1" "$APP_DIR/sources/$1"
    sudo chown "$TRANSMISSION_USER":"$TRANSMISSION_GROUP" "$APP_DIR/torrents/$OUTPUT_FILENAME"
    sudo chown "$TRANSMISSION_USER":"$TRANSMISSION_GROUP" "$APP_DIR/sources/$1"

    # Return torrent hash for the API
    TORRENT_HASH=$(sudo transmission-show "$APP_DIR/torrents/$OUTPUT_FILENAME" | grep -oP --color=none "(?<=Hash: )\w+")

    # shellcheck disable=SC2005
    echo "$(jq -n \
            --arg torrent_hash "$TORRENT_HASH" \
            '{
              code: 0,
              data: {
                hash: $torrent_hash
              }
            }')"
  else
    response_error "Could not create file"
  fi
fi
