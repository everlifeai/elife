# Managing Your Everlife Avatar

This document contains instructions for setting up and running your
**Everlife** avatar on your own machines.

![Avatar](avatar_256x256.png)


## Pre-requisites

1. Install [NodeJS](https://nodejs.org/en/download/) LTS Version: 14.16.0 and above
2. Install [Yarn](https://yarnpkg.com/)
3. Install [Python 2.7](https://www.python.org/)

### Additional Windows Pre-requisities

1. Install Cygwin: [64 Bit Version](https://www.cygwin.com/setup-x86_64.exe) or
   [32 Bit Version](https://www.cygwin.com/setup-x86.exe)



## Setup

There are three run scripts: (`./run-mac.sh`, `./run-linux.sh`,
`run-win.cmd`). Pick the one appropriate to your platform and use it:

        $> ./run-mac.sh

The first time it runs it will set up your environment for you.


## Talking over Telegram
In order to talk with your avatar over [Telegram](the://telegram.org)
you only need to set up communication channel with it. The steps
for doing this are as follows:

1. Go to [Telegram](https://telegram.me/botfather) to create a bot by
   typing

       `/newbot`

    command to create your telegram bot.

1. The BotFather will ask you for a name and username, then generate an
   authorization token for your new bot. The token is a string along the
   lines of 110201543:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw. 
1. We now need to link this new telegram bot with your avatar. To do
   this, simply save the telegram token in `$YOUR_DATA_FOLDER/cfg.env`


## Your Data Folder

In order to find your data folder simply run:

        $> ./run-mac.sh --info



## Next steps
1. Join the Everlife network through an **Avatar Hub**.Contact our
   support channel in discord to get your invite code to join the hub
   and inform your avatar that you would like to join this Avatar Hub by
   saying

        /use_invite xxxx

2. Install and try out various skills

        "install calculator"
        "install what-wine"


Feel free to provide us your feedback and issues in our [discord support
channel](https://discord.gg/TDyRSr4).
