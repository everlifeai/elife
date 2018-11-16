#!/bin/bash

SCRIPTNAME=$(basename "$0")
DATADIR="$(dirname $(pwd))/elife.data"
SKILLDIR="$(dirname $(pwd))/elife.skills"

function help() {
    cat <<EOF
$SCRIPTNAME <command>
    where:
        <command> == Commands to run your everlife node
         setup: Setup docker & node modules needed for the avatar to start

         avatar: Start the avatar
         stop: Stop the avatar

         gui: Run the default GUI client (QWERT)

         enter: Enter the avatar's container machine to look around
         enter_running: Enter the avatar's container while it is running

         docs: Generate documentation
         help: Show this help
EOF
}

#       outcome/
# Set up the everlife docker and the QWERT application
function setup() {
    echo Setting up everlife docker...
    docker build -t everlifeai/elife .

    echo Setting up QWERT...
    if [ -d qwert ]
    then
        cd qwert
        yarn install
        cd ..
    else
        echo Failed to find QWERT
        exit 1
    fi
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

#       outcome/
# Run the default GUI to connect with our avatar (QWERT)
#
function gui() {
    cd qwert || exit 1
    yarn start
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
        SSB_PORT="8997"
        P1="DEFAULT"
    fi
    if [ -z "$QWERT_PORT" ]
    then
        QWERT_PORT="7766"
        P2="DEFAULT"
    fi

    if [ "$P1" = "DEFAULT" -a "$P2" = "DEFAULT" ]
    then
        NAME="elife"
    else
        NAME="elife-$SSB_PORT-$QWERT_PORT"
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
    checkPasswdFile
    DOCKER_RESTART_POLICY="unless-stopped"
    run_avatar_docker ./run.sh cnt_start_avatar
}

#       outcome/
# Run the docker container containing the avatar with all the
# appropriate settings and then execute whatever has been requested as
# parameters
function run_avatar_docker() {
    setupDataFolders
    setupCfgEnv
    setupDockerParams
    setupPartitionParam

    if [ "$DOCKER_RESTART_POLICY" == "no" ]
    then
        RM="--rm"
    else
        RM=""
    fi

    if [ -d "$HOME/.ssh" ]
    then
        SSH_DOCKER_PARAM=(-v "$HOME/.ssh:/root/.ssh")
    else
        SSH_DOCKER_PARAM=()
    fi

    docker run -it $RM \
        -v "$(pwd):/code" \
        -v "$DATADIR:/data" \
        -v "$SKILLDIR:/skills" \
        -w "/code" \
        -e "HOME=/tmp" \
        ${SSH_DOCKER_PARAM[@]} \
        -e ELIFE_DATADIR="$DATADIR" \
        -e ELIFE_SKILLDIR="$SKILLDIR" \
        -e COTE_ENV="$COTE_ENV" \
        -e SSB_HOST="$SSB_HOST" \
        -e SSB_PORT="$SSB_PORT" \
        -e QWERT_PORT="$QWERT_PORT" \
        -p "$SSB_PORT:$SSB_PORT" \
        -p "$QWERT_PORT:$QWERT_PORT" \
        --name "${NAME}" \
        --env-file "$DATADIR/cfg.env" \
        --restart $DOCKER_RESTART_POLICY \
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
    DOCKER_RESTART_POLICY="no"
    run_avatar_docker bash
}

function stop() {
    setupDockerParams
    docker stop "$NAME" && docker rm "$NAME"
}

#       understand/
# This function is called within the docker container to start the node
# once the docker virtual machine has started up
#
#       outcome/
# Start the node using yarn
#
function cnt_start_avatar() {
    yarn start
}

function start_redis() {
    REDIS_DIR="/data/redis"
    [ -d "$REDIS_DIR" ] || mkdir "$REDIS_DIR"
    /root/redis-4.0.11/src/redis-server ./redis.conf &
}

#       outcome/
# Ensure that the data folder (`elife.data`) and skill folder
# (`elife.skills`) are present (create if necessary)
function setupDataFolders() {
    [ -d "$DATADIR" ] || mkdir "$DATADIR"
    [ -d "$SKILLDIR" ] || mkdir "$SKILLDIR"
}

#       outcome/
# Ensure that we have a valid template for cfg.env if it does not
# already exist.
#
function setupCfgEnv() {
    CFG="$DATADIR/cfg.env"
    if [ ! -f "$CFG" ]
    then
        cat > "$CFG" <<EOF
#       understand/
# We use environment variables to configure various skills and services.
# In order to pass those into the docker container running our node we
# list them in this file
#
TELEGRAM_TOKEN=
COTE_ENV=
EOF
    fi
}

#       problem/
# `elife-stellar` expects a wallet password to be present in a file in
# the data directory. If it does not find it, it stops and the process
# manager restarts it causing it to look for the file again, crash again
# and so on in a never ending cycle of despair.
#
#       way/
# Although we shouldn't really *know* what stellar is going to use we
# will reach inside pull out the path and check for it before we allow
# the avatar to start.
# Update: This does not work when the file is obfuscated! We will now
# hardcode the path.
# TODO: Move this check to `elife-stellar`
function checkPasswdFile() {
    STELLAR_PW_FLE=".luminate-pw"
    if [ ! -f "$DATADIR/$STELLAR_PW_FLE" ]
    then
        cat <<EOF
Error: Stellar password not found

Please set up your stellar password before starting the node.
Steps to follow:
    1. ./run.sh enter
    2. cd services/elife-stellar
    3. node pw
(See node setup instructions - node.html - for more details)
EOF
        exit 1
    fi

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
run_fn gui "$@"
run_fn stop "$@"
run_fn enter "$@"
run_fn enter_running "$@"
run_fn cnt_start_avatar "$@"
run_fn update_node_deps "$@"
run_fn docs "$@"
else_show_help

