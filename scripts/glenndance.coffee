# Description:
#   Spread the joy of Glenn dancing to everyone.
#
# Commands:
#   hubot make glenn dance
#   hubot glenn dance
#   hubot glenn dance bomb N - get N glenn dance gifs

glenngifs = [
  "https://i.imgur.com/0G6Bdvs.gif",
  "https://i.imgur.com/3YveU2X.gif",
  "https://i.imgur.com/88vefL9.gif",
  "https://i.imgur.com/HAuH8ly.gif",
  "https://i.imgur.com/cTxSiI1.gif",
  "https://i.imgur.com/flyMHi1.gif"
]

module.exports = (robot) ->
  robot.respond /glenn dance bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    i = 0
    while i < count
      msg.send msg.random glenngifs
      i++

  robot.respond /make glenn dance/i, (msg) ->
    msg.send msg.random glenngifs
