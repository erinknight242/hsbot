# Description:
#   blarg
#
# Dependencies:
#   datejs, https
#
# Commands:
#   hubot timehop

date = require 'datejs'
https = require 'https'
_ = require 'underscore'

rooms = []

module.exports = (robot) ->
  robot.http("https://api.hipchat.com/v1/rooms/list?auth_token=#{process.env.HUBOT_HIPCHAT_TOKEN}")
    .get() (err, res, body) ->
      rooms = JSON.parse(body).rooms
      console.log "#{rooms.length} rooms loaded into memory for timehop"

  robot.respond /timehop/i, (msg) ->
    jid = msg.message.user.reply_to
    room = _.findWhere(rooms, { xmpp_jid: jid })
    room_id = room?.room_id || 67789
    targetDate = Date.today().add({ years: -1 })
    targetDateFormatted = targetDate.toString("yyyy-MM-dd")
    robot.http("https://api.hipchat.com/v1/rooms/history?auth_token=#{process.env.HUBOT_HIPCHAT_TOKEN}&room_id=#{room_id}&date=#{targetDateFormatted}")
      .get() (err, res, body) ->

        data = JSON.parse(body) 

        if (!data)
          msg.send "Great Scott, there was a problem!"
          return

        if (data.error)
          msg.send "Great Scott, there was a problem! #{data.error.message}"
          return

        if (data.messages.length < 1)
          msg.send "No chats found on #{targetDate.toString('MMM dS, yyyy')}"
          return

        message = msg.random data.messages
        messageDate = Date.parse(message.date).toString('MMM dS, yyyy @ h:mm tt')
        msg.send "/quote \"#{message.message}\" – #{message.from.name} (#{messageDate})"
