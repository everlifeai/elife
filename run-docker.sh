#!/bin/bash

SCRIPTNAME=$(basename "$0")
CWD=$(pwd)
ELIFE_HOME_DIR=${CWD}/everlifeai

if [ -z "$ELIFE_NODE_NUM" ]
then
  NUM="0"
else
  NUM="$ELIFE_NODE_NUM"
fi

shift

EXPOSE_PORTS=$(node run.js --docker-port-param)

docker run -it --rm \
  $EXPOSE_PORTS \
  -v ${ELIFE_HOME_DIR}:/root/everlifeai \
  elife-docker:latest \
  node run.js -n $NUM
