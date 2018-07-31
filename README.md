# Your Everlife.Ai Avatar Node

This is the main Everlife.ai avatar node. It runs in a docker container
and can be deployed on any VPS to run a standard avatar.

## Quickstart
```sh
$> run.sh <command>
    where:
        <command> == One of the following:-
           setup : Setup requirements for the avatar to start (docker & node modules)
           avatar: Start the avatar
           enter : Enter running node container to examine and execute commands
```

## Troubleshooting
Processes are managed by [pm2](https://pm2.io/). The logs for processes
started will be available in the `logs` directory. They are useful for
debugging/troubleshooting.

## Package Overview

This package code will download and manage all the dependencies needed
to run the avatar, install the skills, communicate with the user and so
on.  Configuration, updates, and troubleshooting can all take place from
here.

This package itself can be thought of as the
core of the avatar - it keeps the rest of the avatar (the AI brain, the
immortal feed, the database etc) alive and stable. That is it's main
responsibility (after all - it has to *live forever*).


### Package Details

![Everlife Architecture](elife.png)

For this to work, it delegates all other work to different processes
(a.l.a Erlang's supervisor trees).

These core processes include:
1. The Scuttlebot Immortal Feed and Replication
2. A Database for storing working data
3. A Work Queue for managing and distributing work (with a worker
pool)
4. A Skill Manager for installing, running, and managing skills
     - Infrastructure Skills (as hub/as host/...)
     - Worker skills (twitter svc, vanity address, ...)
5. A Communication Manager for installing, running, and managing
communication channels
   - Telegram channel
   - Messenger channel
   - Alexa channel
   - Web channel
   - ...
6. An AI for understanding and managing user interaction and
strategies for earning
   - Cakechat (python with microservices relay...)
   - ...
7. The stellar blockchain interface for payments, receipts, and smart
contracts.
8. ...

## Scaling Out
Because all communication happens via microservices in a docker
container, for more advanced uses we can deploy services on multiple
machines and have scale-out.

