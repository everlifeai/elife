# Managing Your Everlife Avatar

This document contains instructions for setting up and running your
`Everlife` avatar on your own machines.

![Avatar](avatar_256x256.png)


## Pre-requisites
In order to make it easy for you to deploy, rather than needing you to
install all the various dependencies that the avatar requires, we have
packaged the avatar into a [Docker](https://www.docker.com/) container.

To get started, please ensure you have Docker installed and configured
on your machine.


## Setup

In order to get a working avatar, you need to download it, set it up and
set up a [Telegram](the://telegram.org) communication channel with it.
The steps for doing this are not difficult and are as follows:

1. Download the latest avatar zip file from [Everlife.ai](https://everlife.ai)
2. Unzip the avatar into a directory of your choice
3. Open your `terminal` and navigate to this directory
4. Run

        ./run.sh setup

5. Go to [botfather](https://telegram.me/botfather) and use the

       `/newbot`

    command to create your telegram bot.
6. The BotFather will ask you for a name and username, then generate an
   authorization token for your new bot. The token is a string along the
   lines of `110201543:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`.
7. We now need to link your new telegram bot with your avatar. To
   do this, simply save the telegram token in [`cfg.env`](cfg.env)



## Set up your Stellar Wallet

In order to safeguard the wallet, it is password protected. So that the
user does not need to type in this password again and again it needs to
be saved once. In order to do this you need to do the following:

1. Load the node

        $> ./run.sh load

2. Go to the Stellar Server

        # cd services/elife-stellar

3. Run the password manager

        # node pw

When prompted for the password, pick a good password that you are
comfortable with. PLEASE REMEMBER THIS PASSWORD AS IT **CANNOT BE
RECOVERED**.


## Starting and Chatting with Your Avatar

Now that your avatar is set up you can start him up by running

        ./run.sh avatar


Now you can go to your Telegram and start chatting!


## Next steps
1. Join the Everlife network through a `hub`. Get an invite from
   [Everlife.ai](https://everlife.ai) and inform your avatar that you
    would like to join by saying:

        "use this invite xxxxxx"

2. Install and try out various skills

        "install calculator"
        "install what-wine"

3. Fund your avatar by using
   [coupons](https://github.com/everlifeai/elife-coupon) from the
   [Everstore](https://github.com/everlifeai/everlife-marketplace)

Feel free to provide us your feedback and issues in our discord and
support groups.
