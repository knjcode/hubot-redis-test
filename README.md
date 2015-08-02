# hubot-redis-test

A hubot script to access Redis

**Use this hubot script carefully, it allows your team members to access Redis.**


## Installation

In hubot project repo, run:

`npm install --save knjcode/hubot-redis-test`

or

`npm install --save https://github.com/knjcode/hubot-redis-test/archive/master.tar.gz`

Then add **hubot-redis-test** to your `external-scripts.json`:

```json
["hubot-redis-test"]
```


## Sample Interaction

```
> hubot redis-keys *
(empty)

> hubot redis-set foo 1000
OK (foo=1000)

> hubot redis-set bar 2000
OK (bar=2000)

> hubot redis-keys *
foo,bar

> hubot redis-get foo
1000

> hubot redis-del foo
1 (foo is deleted)

> hubot redis-keys *
bar
```


## Configurations

**Same as hubot-redis-brain. But prefix is ignored.**

hubot-redis-test requires a redis server to work.
It uses the `REDISTOGO_URL` or `REDISCLOUD_URL` or `BOXEN_REDIS_URL` or `REDIS_URL` environment variable for determining where to connect to.
The default is on localhost, port 6379 (ie the redis default).

The following attributes can be set using the `REDIS_URL`

* authentication
* hostname
* port
* key prefix

For example, `export REDIS_URL=redis://passwd@192.168.0.1:16379/prefix` would
authenticate with `password`, connecting to 192.168.0.1 on port 16379, and
key prefix is ignored.


## Commands

### redis-keys

Find all keys matching the given pattern.

`> hubot redis-keys pattern`

### redis-get

Get the value of a key

`> hubot redis-get key`

### redis-set

Set the string value of a key

`> hubot redis-set key value`

### redis-exists

Determin if a key exists

`> hubot redis-exists key`

### redis-del

Delete a key

`> hubot redis-del key`


## Acknowledgements

[hubot-redis-brain](https://github.com/hubot-scripts/hubot-redis-brain)
