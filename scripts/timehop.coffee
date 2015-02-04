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

module.exports = (robot) ->
  robot.respond /timehop/i, (msg) ->
    targetDate = Date.today().add({ years: -1 })
    targetDateFormatted = targetDate.toString("yyyy-MM-dd")
    robot.http("https://api.hipchat.com/v1/rooms/history?auth_token=#{process.env.HUBOT_HIPCHAT_TOKEN}&room_id=#{msg.message.room}&date=#{targetDate}")
      .get() (err, res, body) ->
        data = JSON.parse(body) 

        if (!data || data.length < 1)
          msg.send "No chats found on #{targetDate.toString('MMM dS, yyyy')}"
          return

        message = msg.random data.messages
        messageDate = Date.parse(message.date).toString('MMM dS, yyyy @ h:mm tt')
        msg.send "/quote \"#{message.message}\" – #{message.from.name} (#{messageDate})"


