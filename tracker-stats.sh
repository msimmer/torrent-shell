#! /bin/bash

###### INFO #######
#
# More info : https://github.com/FoRTu/OpenTracker-Munin
#
##################


############## CONFIGURATION
#
#  The URL of OpenTracker statistics
#
TRACKER_STATS_URL="$TRACKER_IP:$TRACKER_PORT/$TRACKER_STATS_PATH"
#
#
######## End of Configuration

PEERS=`curl -s $TRACKER_STATS_URL | awk 'NR == 1'`
SEEDERS=`curl -s $TRACKER_STATS_URL | awk 'NR == 2'`
TORRENTS=`curl -s $TRACKER_STATS_URL | awk 'NR == 3' | awk '{print $3}'`

let LEECHERS=$PEERS-$SEEDERS


case $1 in
  config)

  # Chart settings
  echo raph_title Open Tracker Stats
  echo graph_title Open Tracker Tracker
  echo graph_args --base 1000 -l 0
  echo graph_vlabel Open Bittorrent Tracker Stats
  echo graph_category network
  echo graph_info Open Bittorrent Tracker Stats.
  echo Peers.label Peers
  echo Peers.info Seeders + Leechers. Conected all clients.
  echo Seeders.label Seeders
  echo Seeders.info A computer that has a complete copy of the torrent.
  echo Leechers.label Leecher
  echo Leechers.info "A computer that doesn't have the complete file".
  echo Torrents.label Torrents
  echo Torrents.info Number of Torrents tracking.


  exit 0;;
esac

echo $(jq -n \
          --arg peers "$PEERS" \
          --arg seeders "$SEEDERS" \
          --arg leechers "$LEECHERS" \
          --arg torrents "$TORRENTS" \
          '{
            code: 0,
            data: {
              peers: $peers,
              seeders: $seeders,
              leechers: $leechers,
              torrents: $torrents
            }
          }')
