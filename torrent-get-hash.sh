#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilities.sh"

FILE_PATH="$APP_DIR/torrents/$1"
TORRENT_HASH=$(sudo transmission-show "$FILE_PATH" | grep -oP --color=none "(?<=Hash: )\w+")

# shellcheck disable=SC2005
echo "$(jq -n \
        --arg torrent_hash "$TORRENT_HASH" \
        '{
          code: 0,
          data: {
            hash: $torrent_hash
          }
        }')"
