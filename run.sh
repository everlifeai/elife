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

function setup() {
    echo Setting up docker for node...
    docker pull node
    echo Setting up node_modules...
    docker run -it --rm \
        -v "$(pwd):/code" \
        -w "/code" \
        -e "HOME=/tmp" \
        node yarn install
}

function avatar() {
    docker run -it --rm \
        -v "$(pwd):/code" \
        -w "/code" \
        -e "HOME=/tmp" \
        -p "8997:8997" \
        --name "${NAME}" \
        node yarn start
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

