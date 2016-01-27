# Description:
#   Houston quotes!

answers = [
  'http://i.imgur.com/LpIujA6.jpg'
]

module.exports = (robot) ->
  robot.respond /houston me/i, (msg) ->
    msg.random answers
