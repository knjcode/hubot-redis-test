# Description
#   A hubot script to access Redis
#
# Dependencies:
#   "redis": "^0.12.1"
#
# Configuration:
#   REDISTOGO_URL or REDISCLOUD_URL or BOXEN_REDIS_URL or REDIS_URL.
#   URL format: redis://<host>:<port>[/<brain_prefix>]
#   You can set brain_prefix to compatible with hubot-redis-brain.
#
# Commands:
#   hubot redis-keys <pattern>    - Find all keys matching the given pattern
#   hubot redis-get <key>         - Get the value of a key
#   hubot redis-set <key> <value> - Set the string value of a key
#   hubot redis-exists <key>      - Determin if a key exists
#   hubot redis-del <key>         - Delete a key
#
# Author:
#   knjcode <knjcode@gmail.com>

# Originated in https://github.com/hubot-scripts/hubot-redis-brain
Url   = require "url"
Redis = require "redis"

module.exports = (robot) ->
  redisUrl = if process.env.REDISTOGO_URL?
               redisUrlEnv = "REDISTOGO_URL"
               process.env.REDISTOGO_URL
             else if process.env.REDISCLOUD_URL?
               redisUrlEnv = "REDISCLOUD_URL"
               process.env.REDISCLOUD_URL
             else if process.env.BOXEN_REDIS_URL?
               redisUrlEnv = "BOXEN_REDIS_URL"
               process.env.BOXEN_REDIS_URL
             else if process.env.REDIS_URL?
               redisUrlEnv = "REDIS_URL"
               process.env.REDIS_URL
             else
               'redis://localhost:6379'

  if redisUrlEnv?
    robot.logger.info "hubot-redis-test: Discovered redis from #{redisUrlEnv} environment variable"
  else
    robot.logger.info "hubot-redis-test: Using default redis on localhost:6379"

  info   = Url.parse redisUrl, true
  client = if info.auth then Redis.createClient(info.port, info.hostname, {no_ready_check: true}) else Redis.createClient(info.port, info.hostname)
  prefix = info.path?.replace('/', '') or 'hubot'

  if info.auth
    client.auth info.auth.split(":")[1], (err) ->
      if err
        robot.logger.error "hubot-redis-test: Failed to authenticate to Redis"
      else
        robot.logger.info "hubot-redis-test: Successfully authenticated to Redis"

  robot.respond /redis-keys (.*)$/i, (res) ->
    pattern = res.match[1].trim()
    client.keys pattern, (err, reply) ->
      if err
        robot.logger.error("#{err}")
        return
      if reply.length > 0
        res.send  "#{reply}"
      else
        res.send "(empty)"

  robot.respond /redis-get (.*)$/i, (res) ->
    key = res.match[1].trim()
    client.get key, (err, reply) ->
      if err
        robot.logger.error("#{err}")
        return
      if reply
        res.send "#{reply}"
      else
        res.send "#{key} is not found"

  robot.respond /redis-set ([^\s]*) (.*)$/i, (res) ->
    key   = res.match[1].trim()
    value = res.match[2].trim()
    client.set key, value, (err, reply) ->
      if err
        robot.logger.error("#{err}")
        return
      if reply
        res.send "#{reply} (#{key}=#{value})"

  robot.respond /redis-exists (.*)$/i, (res) ->
    key = res.match[1].trim()
    client.exists key, (err, reply) ->
      if err
        robot.logger.error("#{err}")
        return
      if reply == 1
        res.send "#{reply} (#{key} is exists)"
      else
        res.send "#{reply} (#{key} is not found)"

  robot.respond /redis-del (.*)$/i, (res) ->
    key = res.match[1].trim()
    client.del key, (err, reply) ->
      if err
        robot.logger.error("#{err}")
        return
      if reply
        res.send "#{reply} (#{key} is deleted)"

  client.on "error", (err) ->
    if /ECONNREFUSED/.test err.message

    else
      robot.logger.error err.stack
