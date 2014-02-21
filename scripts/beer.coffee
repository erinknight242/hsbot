# Description:
#   Lets a user know if it's beer:30 or not
#
# Commands:
#   hubot beer - Reply with whether or not you can have a beer

module.exports = (robot) ->
  robot.respond /beer/i, (msg) ->
    msg.send "yes"
