#!/bin/bash
mkdir -p logs/buyer
mkdir -p logs/seller
docker compose stop
docker compose rm -f
docker compose up --remove-orphans
