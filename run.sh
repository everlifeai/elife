#!/bin/bash

SCRIPTNAME=$(basename "$0")
DATADIR="$(dirname $(pwd))/elife.data"

function help() {
    cat <<EOF
$SCRIPTNAME <command>
    where:
        <command> == Commands to run your everlife node
         setup: Setup docker & node modules needed for the avatar to start

         avatar: Start the avatar

         enter: Enter the avatar's container machine to look around
         enter_running: Enter the avatar's container while it is running

         docs: Generate documentation
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
    docker run -it --rm \
        -v "$(pwd):/code" \
        -v "$HOME/.ssh:/root/.ssh" \
        -w "/code" \
        -e "HOME=/tmp" \
        everlifeai/elife ./run.sh update_node_deps
}

#       outcome/
# Find all the packages available on disk and update their dependent
# `node_modules` if not already present
#
function update_node_deps() {
    REPOS=$(find . -type d -name .git | sed 's/\.git$//')
    for R in $REPOS
    do

        cd "$R" || exit 1

        N=$(basename $R)
        echo "Setting up dependencies for $N..."
        if [ -d node_modules ]
        then
            echo node_modules present so skipping...
        else
            yarn install || exit 1
        fi

        cd - > /dev/null 2>&1 || exit 1
    done
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
    if [ -z "$SSB_HOST" ]
    then
        SSB_HOST=$(ifconfig | grep 'inet '| grep -v 127.0.0.1 | sed 's,.*:,,' | awk '{print $2}')
    fi
    if [ -z "$SSB_PORT" ]
    then
        NAME="elife"
        SSB_PORT="8997"
    else
        NAME="elife-$SSB_PORT"
    fi
}

#           problem/
# Cote.js auto-discovers all relevant microservices on the same network
# (even within docker containers). We would like to use the microservice
# only within a node's docker container.
#
#           way/
# We use Cote.js' `environment` parameter to partition the node's
# services so that nodes will not interfere with each other.
function setupPartitionParam() {
    COTE_ENV=$(yarn -s part)
}

function avatar() {
    run_avatar_docker ./run.sh cnt_start_avatar
}

#       outcome/
# Run the docker container containing the avatar with all the
# appropriate settings and then execute whatever has been requested as
# parameters
function run_avatar_docker() {
    setupDataFolder
    setupDockerParams
    setupPartitionParam

    docker run -it --rm \
        -v "$(pwd):/code" \
        -v "$DATADIR:/data" \
        -v "$HOME/.ssh:/root/.ssh" \
        -w "/code" \
        -e "HOME=/tmp" \
        -e ELIFE_DATADIR="$DATADIR" \
        -e SSB_HOST="$SSB_HOST" \
        -e SSB_PORT="$SSB_PORT" \
        -e COTE_ENV="$COTE_ENV" \
        -p "$SSB_PORT:$SSB_PORT" \
        --name "${NAME}" \
        --env-file "$DATADIR/cfg.env" \
        everlifeai/elife "$@"
}

#       problem/
# When working with the avatar's code, we want to make sure it's
# dependencies etc are managed withing the proper avatar docker
# container and not the host machine.
#
#       way/
# Start the correct docker container but do not run the avatar. Instead,
# run the shell so we can move around and make changes without the
# avatar being active.
function enter() {
    run_avatar_docker bash
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
    REDIS_DIR="/data/redis"
    [ -d "$REDIS_DIR" ] || mkdir "$REDIS_DIR"
    /root/redis-4.0.11/src/redis-server ./redis.conf &
}

#       outcome/
# Ensure that the data folder `elife-data` is present (create if
# necessary)
function setupDataFolder() {
    [ -d "$DATADIR" ] || mkdir "$DATADIR"
}

#       outcome/
# Enter the running docker container to execute tests, manual commands
# etc etc.
function enter_running() {
    setupDockerParams
    echo Entering ${NAME}...
    docker exec -it "${NAME}" bash
}

#       outcome/
# Generate HTML documentation from Markdown
#
function docs() {
    yarn docs
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
run_fn enter_running "$@"
run_fn cnt_start_avatar "$@"
run_fn update_node_deps "$@"
run_fn docs "$@"
else_show_help

