# Description:
#   Place to add scripts for troubleshooting hsbot issues in Slack
#
# Commands:
#
#  hsbot diag (message) - logs the message object
#  hsbot send message `(messageText)` to (channel id or channel name)

module.exports = (robot) ->

  robot.respond /diag (.*)$/i, (msg) ->
    console.log msg
    msg.send 'Message logged'

  robot.respond /send message `((.|\n)*)` to (.*)$/i, (msg) ->
    messageText = msg.match[1]
    channel = msg.match[3]
    robot.messageRoom channel, messageText
    msg.send "\"#{messageText}\" sent to #{channel}"

