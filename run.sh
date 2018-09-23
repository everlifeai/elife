#!/bin/bash

SCRIPTNAME=$(basename "$0")

function help() {
    cat <<EOF
$SCRIPTNAME <command>
    where:
        <command> == Commands to run your everlife node
         setup: Setup requirements for the avatar to start (docker & node modules)
         avatar: Start the avatar
         enter: Enter running node container to execute commands
         help: Show this help
EOF
}

#       problem/
# Some of our repositories are privately hosted on github. These are not
# accesible within the docker container.
#
#       way/
# Share our local ~/.ssh/ folder into the docker container which allows
# us to use our local credentials when connecting to github
#
function setup() {
    echo Setting up everlife docker...
    docker build -t everlifeai/elife .
    echo Setting up node modules...
    docker run -it --rm \
        -v "$(pwd):/code" \
        -v "$HOME/.ssh:/root/.ssh" \
        -w "/code" \
        -e "HOME=/tmp" \
        everlifeai/elife yarn install
}

#       problem/
# Our node runs within a docker container and this is a 'virtual'
# machine with it's own IP address. However this IP address is not on
# our 'normal' network (and we don't want to set up a docker network)
#
#       way/
# We carry across our 'host' IP address into the container as an
# environment variable so it is accessible within the node. We also
# carry across port numbers so we can run multiple nodes without
# conflicting on the same machine (we update the name for the same
# reason)
#
function setupDockerParams() {
    SSB_HOST=$(ifconfig | grep 'inet '| grep -v 127.0.0.1 | awk '{print $2}')
    if [ -z "$SSB_PORT" ]
    then
        NAME="elife"
        SSB_PORT="8997"
    else
        NAME="elife-$SSB_PORT"
    fi
}

function avatar() {
    setupDockerParams

    docker run -it --rm \
        -v "$(pwd):/code" \
        -v "$HOME/.ssh:/root/.ssh" \
        -w "/code" \
        -e "HOME=/tmp" \
        -e SSB_HOST="$SSB_HOST" \
        -e SSB_PORT="$SSB_PORT" \
        -p "$SSB_PORT:$SSB_PORT" \
        --name "${NAME}" \
        --env-file cfg.env \
        everlifeai/elife ./run.sh cnt_start_avatar
}

#       understand/
# This function is called within the docker container to start the node
# once the docker virtual machine has started up
#
#       outcome/
# Start the redis server, wait 10 seconds so it has time to start up,
# then start the node
#
# TODO: Start default AI service here as well?
#
function cnt_start_avatar() {
    start_redis
    sleep 10
    yarn start
}

function start_redis() {
    /root/redis-4.0.11/src/redis-server &
}

#       outcome/
# Enter the running docker container to execute tests, manual commands
# etc etc.
function enter() {
    setupDockerParams
    echo Entering ${NAME}...
    docker exec -it "${NAME}" bash
}

#       outcome/
# Run the appropriate function based on the command-line parameter
# If nothing was run, show the help.
RUN=0
function run_fn() {
    if [ "$1" == "$2" ]
    then
         RUN=1
         shift
         "$@"
    fi
}

function else_show_help() {
    if [ "$RUN" == "0" ]
    then
        help
    fi
}

run_fn setup "$@"
run_fn avatar "$@"
run_fn enter "$@"
run_fn cnt_start_avatar "$@"
else_show_help

