#! /bin/bash

# @desc Create torrent file from source. Single file passed in via CLI argument.
#       Run against a single file or list of files iteratively.
# @return Torrent hash
# @requires transmission-create transmission-show

source './utilities.sh'

OUTPUT_FILENAME="${1}.torrent"
TRACKER_URLS=("$TRACKER_URL_UDP" "$TRACKER_URL_TCP")
TRACKER_ARGS=''

for url in "${TRACKER_URLS[@]}"
do
  TRACKER_ARGS+=" -t ${url}"
done

# Create the torrents and get the hash
CREATE_COMMAND="transmission-create -o ${APP_DIR}/torrents/${OUTPUT_FILENAME} ${TRACKER_ARGS} ${TMP_DIR}/${1} > /dev/null 2>&1"
SHOW_TORRENT_HASH="transmission-show ${APP_DIR}/torrents/${OUTPUT_FILENAME} | grep -oP --color=none \"(?<=Hash: )\w+\""

eval $CREATE_COMMAND

if [ $? -eq 0 ]
then
  # Move source file to app dir -- TODO: since all the clients are happy to
  # share a single dir, that dir should be made the sources dir
  mv "${TMP_DIR}/${1}" "${APP_DIR}/sources/${1}"

  # Return torrent hash for the API
  TORRENT_HASH="$($SHOW_TORRENT_HASH)"
  echo $(jq -n \
            --arg torrent_hash "$TORRENT_HASH" \
            '{
              code: 0,
              data: {
                hash: $torrent_hash
              }
            }')
else
  error "Could not create file"
fi
