# Description:
#   Listens for interesting Detroit happenings.
module.exports = (robot) ->
  robot.hear /(^|\s)detroit(\s|$|[\W])/ig, (msg) ->
    onDetroitDuty = robot.brain.get('onDetroitDuty')
    if onDetroitDuty
      room = msg.envelope.room
      if room and room != 'detroit'
        user = msg.envelope.user.name
        robot.messageRoom process.env.HUBOT_ROOM_DETROIT, "Pssst!! #{user} is talking about Detroit in #{room}."

  robot.respond /spy for detroit/ig, (msg) ->
    if msg.envelope.user.reply_to == process.env.HUBOT_ROOM_DETROIT
      robot.brain.set 'onDetroitDuty', true

  robot.respond /stop spying for detroit/ig, (msg) ->
    if msg.envelope.user.reply_to == process.env.HUBOT_ROOM_DETROIT
      robot.brain.set 'onDetroitDuty', false
