# Description:
#   Spread the joy of Glenn dancing to everyone.
#
# Commands:
#   hubot make glenn dance
#   hubot glenn dance

module.exports = (robot) ->
  robot.respond /glenn dance/i, (msg) ->
    msg.send "http://storage.pardot.com/52582/68569/Napoleon_Glenn_1.gif"
