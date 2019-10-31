#! /bin/bash

# shellcheck source=utilities.sh
source "$(cd "$(dirname "$0")" || exit; pwd -P)/utilitie.sh"

if ! sudo service opentracker stop
then
  response_error "Could not stop tracker"
fi

if ! sudo service opentracker start
then
  response_error "Could not start tracker"
else
  response_ok
fi
