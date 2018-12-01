# Description:
#   Place to add scripts for troubleshooting hsbot issues in Slack
#
# Commands:
#
#  hsbot diag (message) - logs the message object

module.exports = (robot) ->

  robot.respond /diag (.*)$/i, (msg) ->
    console.log msg
    msg.send 'Message logged'
