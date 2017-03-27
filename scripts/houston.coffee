# Description:
#   Houston quotes!

answers = [
  "Let's get f**ked up",
  "I'm shy",
  'I feel nothing',
  'Pick a number',
  "I don't like being friends with people I work with",
  "I don't know about that"
]

module.exports = (robot) ->
  robot.respond /houston me/i, (msg) ->
    msg.send msg.random answers
