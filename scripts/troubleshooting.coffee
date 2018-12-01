# Description:
#   Place to add scripts for troubleshooting hsbot issues in Slack
#
# Commands:
#
#  hsbot diag (message) - logs the message object
#  hsbot send message (messageText) to (channel id or channel name)

module.exports = (robot) ->

  robot.respond /diag (.*)$/i, (msg) ->
    console.log msg
    msg.send 'Message logged'

  robot.respond /send message (.*) to (.*)$/i, (msg) ->
    messageText = msg.match[1]
    room = msg.match[2]
    robot.messageRoom room, messageText

