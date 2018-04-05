# Description:
#   Based on the pug bomb; Garo requested a "nope" response
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hsbot nope - Receive a cat with its tongue out
#   hsbot nooope - get 3 nopes

tumblr = require 'tumblrbot'

module.exports = (robot) ->

  robot.respond /nope help$/i, (msg) ->
    msg.send "\thsbot nope - Get a nope\n\thsbot nooope - Get 3 nopes"

  robot.respond /nope/i, (msg) ->
    tumblr.photo("nopecards.tumblr.com").random (post) ->
      msg.send post.photos[0].original_size.url

  robot.respond /nooope/i, (msg) ->
    count = 3
    i = 0
    while i < count
      tumblr.photo("nopecards.tumblr.com").random (post) ->
        msg.send post.photos[0].original_size.url
      i++
