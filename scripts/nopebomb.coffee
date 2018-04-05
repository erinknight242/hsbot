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
#   hsbot nope - Get a nope
#   hsbot nooope - Get 3 nopes (as many nopes as o's)

tumblr = require 'tumblrbot'

module.exports = (robot) ->

  count = (string) ->
    re = new RegExp('o',"gi");
    string.match(re).length - 1; #'hsbot' has one o

  robot.respond /nope help$/i, (msg) ->
    msg.send "\thsbot nope - Get a nope\n\thsbot nooope - Get 3 nopes (as many nopes as o's)"

  robot.respond /n(o)+pe/i, (msg) ->
    matches = count msg.match[0]
    if matches > 10 then matches = 10
    i = 0
    while i < matches
      tumblr.photo("nopecards.tumblr.com").random (post) ->
        msg.send post.photos[0].original_size.url
      i++
