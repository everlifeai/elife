#!/bin/bash
VERSION=$(cat package.json | grep '^[\t ]*"version"[ \t]*:' | sed 's/.*"version".*"\(.*\)",/\1/')
mv package-lock.json package-lock-outer.json
docker build . -t everlife-server-node:latest
docker tag everlife-server-node:latest everlife-server-node:$VERSION
docker tag everlife-server-node:latest charleslobo77/everlife-server-node:$VERSION
docker tag everlife-server-node:latest charleslobo77/everlife-server-node:latest
mv package-lock-outer.json package-lock.json
