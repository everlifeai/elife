#!/bin/bash

#   understand/
# Entry point
function main() {
    setup
    run "$@"
}

#   outcome/
# If `node_modules` is missing we set it up
function setup() {
    [ -d node_modules ] || setup_node_modules
}

function setup_node_modules() {
    printf "Setting up node_modules...\n"
    npm install
    printf "\n\n"
}

function run() {
    node run.js "$@"
}

main "$@"
