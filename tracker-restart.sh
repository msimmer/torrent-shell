#! /bin/bash

source './utilities.sh'

sudo service opentracker stop

if [ $? -ne 0 ]
then
  error "Could not stop tracker"
fi

sudo service opentracker start

if [ $? -ne 0 ]
then
  error "Could not start tracker"
else
  echo $(jq -n '{ code: 0, data: {} }')
fi
