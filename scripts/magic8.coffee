# Description:
#   Ask the Magic 8 Ball to predict the future!!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot will <ask your question with a question mark>?
#
# Author:
#   CodeSharez

answers = [
  'It is certain',
  'It is decidedly so',
  'Without a doubt',
  'Yes definitely',
  'You may rely on it',
  'As I see it, yes',
  'Most likely',
  'Outlook good',
  'Yes',
  'Signs point to yes',
  'Reply hazy try again',
  'Ask again later',
  'Better not tell you now',
  'Cannot predict now',
  'Concentrate and ask again',
  'Do not count on it',
  'My reply is no',
  'My sources say no',
  'Outlook not so good',
  'Very doubtful'
]

module.exports = (robot) ->
  robot.respond /(will (.+)\?)/ig, (msg) ->
    val = msg.random answers.length
    msg.send '(magic8ball) ' + msg.random answers
