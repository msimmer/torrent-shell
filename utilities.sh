#! /bin/bash

function response_error {
  # shellcheck disable=SC2005
  echo "$(jq -n --arg message "$1" '{
    code: 1,
    message: $message
  }')"
  exit
}

function response_ok {
  # shellcheck disable=SC2005
  echo "$(jq -n '{ code: 0, data: {} }')"
}

function join {
  local IFS="$1"
  shift
  echo "$*"
}
