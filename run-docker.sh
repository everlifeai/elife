#!/bin/bash

SCRIPTNAME=$(basename "$0")
CWD=$(pwd)
ELIFE_HOME_DIR=${CWD}/everlifeai

if [ "$1" == "-h" -o "$1" == "--help" ]
then
  echo 'Usage: ./$SCRIPTNAME [node number]'
  exit
fi

if [ -z "$1" ]
then
  NUM="0"
else
  NUM="$1"
fi

shift

docker run -it --rm \
  -v ${ELIFE_HOME_DIR}:/root/everlifeai \
  elife-docker:latest \
  node run.js -n $NUM
