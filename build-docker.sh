#!/bin/bash
VERSION=$(cat package.json | grep '^[\t ]*"version"[ \t]*:' | sed 's/.*"version".*"\(.*\)",/\1/')
mv package-lock.json package-lock-outer.json
docker build . -t elife-docker:latest
docker tag elife-docker:latest elife-docker:$VERSION
mv package-lock-outer.json package-lock.json
