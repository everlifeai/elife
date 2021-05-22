# Everlife Node for Developers

## Troubleshooting
Processes are managed by process managers like [pm2](https://pm2.io/) and [@elife/pm2](https://www.npmjs.com/package/@elife/pm2). The logs for these can be found under your `$HOME/everlife` and in the `logs` folder in this repository. These logs are very useful for debugging/troubleshooting any issues you may face.


## Package Overview

The Everlife Server Node will download and manage all the other dependencies needed to run the avatar, install the skills, communicate with the user and soon.  Configuration, updates, and troubleshooting can all take place from here.

This package itself can be thought of as the core of the avatar - it keeps the rest of the avatar (the AI brain, the immortal feed, the database etc) alive and stable. That is it's main responsibility (after all - it has to *live forever*).

### Everlife Server Node Architectural Overview

![Everlife Architecture](elife.png)

As you can see from the architecture above, the server node delegates all other work to other core processes (a.l.a Erlang's supervisor trees).

These core processes include:
1. The EverChain Feed and Replication
2. A Database for storing working data
3. A Skill Manager for installing, running, and managing skills
  - Infrastructure Skills (as hub/as host/...)
  - Worker skills (twitter svc, vanity address, ...)
5. A Communication Manager for installing, running, and managing communication channels
   - Telegram channel
   - Messenger channel
   - Alexa channel
   - Web channel
   - ...
6. An AI for understanding and managing user interaction and strategies for earning
   - Intent Resolution
   - NLP
   - Generative Dialogues (python with microservices relay...)
   - ...
6. The stellar blockchain interface for payments, receipts, and smart contracts.
8. The interface to the polkadot relay chain to integrate with other blockchains.

Because all the code is open source you should be able to go through and understand any part that interests you in more detail. Otherwise you are welcome to [ping us on our Discord channel](https://discord.gg/TDyRSr4) and ask any questions or doubts you may have.

