# Everchain Message Structure

Because everchain messages are 'free-form' we need to design a set of
messages and guidelines that can be used for messages on the chain.

# Limitations
* All messages (including headers, signatures, etc) must be less than **8 KB**
due to the limitations of the underlying architecture.
* All message **must** contain a `type:` field. A `type` simply must be
  a string between 3 and 52 characters long.
* Message processors should interpret messages "defensively." There's
  nothing enforcing a schema, so (as with any input) all skills and code
  must be prepared for malformed content objects in messages.

# Namespacing
While the base 'Everlife' core functionality and skills will use
messages without prefixes, to avoid accidental collisions with other
skills, it's a good idea to add your org or skill name (or both!)
to the message type. We recommend:

        {org}-{skill}-{type}


# Content-Hash Linking
In order to link to other entities (skills, messages, blobs) we use
specially-formatted identifiers. Message and blob IDs are
content-hashes, while feed IDs are public keys.

*TODO*: Skill content linking

To indicate the type of ID, a "sigil" is prepended to the string. They
are:

* `@` for feeds
* `%` for messages
* `&` for blobs

Additionally, each ID has a "tag" appended to indicate the hash or key
algorithm. Some example IDs:

* A feed: `@LA9HYf5rnUJFHHTklKXLLRyrEytayjbFZRo76Aj/qKs=.ed25519`
* A message: `%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256`
* A blob: `&Pe5kTo/V/w4MToasp1IuyMrMcCkQwDOdyzbyD5fy4ac=.sha256`


# Standard Message Types
In this section we detail out the standard message types Everlife
understands.

## Post
A post is a text-based message, for a public or private audience. It can
be a reply to other posts.

```js
{
  type: 'post',
  text: String,     // markdown body of post
  channel: String?, // optionally used for categorization
  root: MsgLink?,   // point to the topmost message in the thread
  branch: MsgLink?, // point to set of messages in the thread being replied to
  recps: FeedLinks?, // typically used for encrypted messages
  mentions: Links?  // User/Blob/Message references
}
```

## About
About-messages set attributes about the avatar's owner.

```js
{ type: 'about', about: Link, name: String, image: BlobLink }
```

## Contact
Contact-messages determine who you are following or blocking.

```js
{
  type: 'contact',
  contact: FeedLink,
  following: Bool,
  blocking: Bool
}
```

## Vote
Vote-messages signal approval about someone or something. The value should be negative, 0, or positive. If the value is non-numeric, it is invalid.

The reason is an optional string to explain the vote.

```js
{
  type: 'vote',
  vote: {
    link: Link,
    value: -1|0|1,
    reason: String?
  }
}
```

## Pub
Pub-messages announce the ID, address, and port of public Pub's (Hub's). They are automatically published after successfully using an invite.

When the avatar sees a pub-message, it will add the link/host/port triple to its peers table, and connect to the peer in the future to sync messages.

```js
{
  type: 'pub',
  pub: {
    link: FeedLink,
    host: String,
    port: Number
  }
}
```

## Skill
A skill message references the skills that the avatar will automatically
download and install.

```js
{
  type: 'skill',
  id: namespace/skill-id, // converts into URL for download
  version: <blob hash> / <git sha>,
  uninstall: Bool,
}
```

*TODO*: Algorithm for converting id to URL


## Job

```js
{
  type: 'job',
  id: marketplace/job-id, // references marketplace and job id
  desc: String,
  req: [ namespace/skill-id, ...],
  closed: Bool,
}
```

`req` gives the skill requirements (if any) for the job.

## Job Contract

The job contract is an exchange of two messages - by the worker and
employer. The worker's message contains the employer-signed `job`
message and the employer's message contains the worker-signed `contract`
message so the agreement between the two is publicly visible.

```js
{
  type: 'job-contract-worker',
  employer: @User,
  ref: <job message with signature>,
  resigned: Bool,
}

{
  type: 'job-contract-employer',
  worker: @User,
  ref: <job-contract-worker message with signature>,
  closed: Bool,
}
```

## Canary Message

This message is used for "proof of uptime"

```js
{
  type: 'canary-says',
  key: Int,     // 372431
  msg: String,  // All things bright and beautiful
}
```

The `key` and `msg` are randomly created for the canary so they are more
easily identified.

## Chat Message
*TODO*

## Direct Message
*TODO*


