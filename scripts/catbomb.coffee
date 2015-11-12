# Description:
#   Based on the pug bomb; Lola required a cats-with-tongues-out bomb
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hsbot cat me - Receive a cat with its tongue out
#   hsbot cat bomb N - get N cats with their tongues out

tumblr = require 'tumblrbot'

module.exports = (robot) ->

  robot.respond /cat help$/i, (msg) ->
    msg.send "\thsbot cat me - Receive a cat with its tongue out\n\thsbot cat bomb - Get 5 cats with their tongues out\n\thsbot cat bomb N - Get N cats with their tongues out"

  robot.respond /cat me/i, (msg) ->
    tumblr.photo("tongueoutcats.tumblr.com").random (post) ->
      msg.send post.photos[0].original_size.url

  robot.respond /cat bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    i = 0
    while i < count
      tumblr.photo("tongueoutcats.tumblr.com").random (post) ->
        msg.send post.photos[0].original_size.url
      i++
