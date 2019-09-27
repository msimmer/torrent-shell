#! /bin/bash

function error {
  echo $(jq -n --arg message "$1" '{
    code: 1,
    message: $message
  }')
  exit
}

function join {
  local IFS="$1"
  shift
  echo "$*"
}
