Proof of Uptime Design
======================

![canary](canary-icon.png)

# Background
As part of growing the Everlife network, we would like to incentivize
our community to keep community nodes running. Because it is
decentralized, we the more nodes that are available, the more stable our
network.

One mechanism for rewarding our users for keeping their nodes active is
to create a 'proof-of-uptime' job. If you have a good uptime (time you
are connected to the network), you will get paid.

Another related behaviour we would like to incentivize is "valuing
`EVER`". The more `EVER` you hold, the more you are invested in the
network. Therefore, the payout to the node should be proportional to the
ever held. And if you do not hold some minimum `EVER`, no payout will be
made to you.

    payout = Avatar's Ever / Total Ever held by all Uptime Avatars


# The Canary Message Design
![canary](canary.png)

In order to check if the node is up we use a simple mechanism - the
**_CANARY MESSAGE_** <sub>{&iexcl;cheep!}</sub>.

At random times during the week a canary message will be circulated.
Nodes that are up and active will notice this message and are expected
to re-post it on their own feeds. If the re-post is noticed within 30
minutes of the original message then the node is up and well connected
and will be in the running for the payout for the week.

The **_CANARY MESSAGE_** structure is described in message structure
document (linked below).


# The First Job (on community node)
Proof-of-Uptime is the first 'job' on the community node. This allows us
to start building in 'employer-employee' relationships, payment
distribution, and the beginnings of a marketplace which is another
incentive in building this feature.


## Marketplace
This is a web application skill (`everlife-marketplace`) that will
manage the user profiles, job postings, and so on. Users are free to
start up their own marketplaces so they do not create a central
dependency on the network.

## Employer
This is a skill that provides an avatar with the ability to post jobs on
the marketplace, accept workers, and pay them

## Worker
This is a skill that provides an avatar with the ability to sign up for
jobs on the marketplace and get paid for doing the work.

*TODO*: Are Marketplace/Employer/Worker skills should we embed it as part of the
core architecture?

## Payment Subsystem
*TODO*
In order for the employer to pay out the wages, it will need to do
wallet management and so on. For this we could extend
[Luminate](https://github.com/theproductiveprogrammer/luminate) or
rewrite a wallet subsystem to manage the interaction.



# Sequence of Steps

## Employer Posts "Proof-of-Uptime" Job
* Employer: Request job posting with stellar address + minimum EVER balance
* Marketplace: Accept job posting
* Employer: Post job message on feed
* Marketplace: Create job listing

## Worker Signs up for Job
* Worker: Sign up for job and follow employer and provide stellar address
* Marketplace: Add worker to job list
* Employer: Accept and follow worker
* Worker: Create job contract and verify employer job (up connection validated)
* Employer: Create job contract and verify worker contract (down connection validated)

## Proof-of-Uptime Work
* Employer: Post canary message at random
* Worker: Repost canary message on feed
* Employer: Notice canary message and update levelDB
* Employer: Post on feed all relevant workers (if too many?)

## Proof-of-Uptime Payment
* Employer: Weekly calculate balance and distribute payment to workers


# Message Structure
Refer to [the message structure](msg-structure.md) documentation.

