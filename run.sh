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

NAME=elife

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
        everlifeai/elife bash
}

function avatar() {
    docker run -it --rm \
        -v "$(pwd):/code" \
        -v "$HOME/.ssh:/root/.ssh" \
        -w "/code" \
        -e "HOME=/tmp" \
        -p "8997:8997" \
        --name "${NAME}" \
        everlifeai/elife yarn start
}

function enter() {
    docker exec -it "${NAME}" bash
}

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
else_show_help

