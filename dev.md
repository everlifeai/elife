# Everlife Node for Developers

This document contains instructions for developers of Everlife that want
to setup and begin work on the node. For everyone else a far more useful
read would be [this one](node.md).

## Setup

### Accessing Private Repositories
Because we have multiple private repositories in
[Everlife](https://github.com/everlifeai), in order to access them we
need to authenticate ourselves.

Needing to authenticate ourselves multiple times for multiple downloads
and updates is tiresome so we use `ssh` access. If you can access Github-via-ssh
your avatar can use the ssh settings to download the repositories.

- [Set up ssh access to Github](https://help.github.com/articles/connecting-to-github-with-ssh/)



## Troubleshooting
Processes are managed by [pm2](https://pm2.io/). The logs for processes
started will be available in the `logs` directory. They are useful for
debugging/troubleshooting.


## Package Overview

This package code will download and manage all the dependencies needed
to run the avatar, install the skills, communicate with the user and so
on.  Configuration, updates, and troubleshooting can all take place from
here.

This package itself can be thought of as the core of the avatar - it
keeps the rest of the avatar (the AI brain, the immortal feed, the
database etc) alive and stable. That is it's main responsibility (after
all - it has to *live forever*).



### Package Details

![Everlife Architecture](elife.png)

For this to work, it delegates all other work to different processes
(a.l.a Erlang's supervisor trees).

These core processes include:
1. The EverChain Feed and Replication
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
   - Intent Resolution
   - NLP
   - Generative Dialogues (python with microservices relay...)
   - ...
7. The stellar blockchain interface for payments, receipts, and smart
contracts.
8. ...


