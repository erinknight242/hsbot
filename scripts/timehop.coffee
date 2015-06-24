# Description:
#   hsbot will go back in time and try to nab a snippet of conversation from that room long ago.
#   You can use days/weeks/months/years in any order, with or without puncation, enjoy!
#
# Dependencies:
#   datejs, https, underscore
#
# Commands:
#   hubot timehop – go back one year
#   hubot timehop 1 year, 2 months, 3 weeks, 4 days – go back a specific amount of time

date = require 'datejs'
https = require 'https'
_ = require 'underscore'

rooms = []
auth_token = 'WBoCSSKBxZpd6nuQ5WLZfYmrYSzFxn1NG3t4AvXa'

getDatePartValue = (parts, pattern) ->
  part = _.find(parts, (p) -> p.match pattern)
  index = _.indexOf(parts, part)
  return parts[index + 1]

fluxCapacitate = (input) ->
  parts = input.split(/[ ,]+/).reverse()
  if parts.length > 1
    d = getDatePartValue parts, /^d(.*)/gi || 0
    m = getDatePartValue parts, /^m(.*)/gi || 0
    w = getDatePartValue parts, /^w(.*)/gi || 0
    y = getDatePartValue parts, /^y(.*)/gi || 0
  else
    y = 1

  return { years: 0-y, months: 0-m, days: 0-d, weeks: 0-w }

module.exports = (robot) ->

  robot.http("https://api.hipchat.com/v2/room?auth_token=#{auth_token}")
    .get() (err, res, body) ->
      rooms = JSON.parse(body).rooms

  robot.respond /timehop( me)?( (.*))?/i, (msg) ->
    txt = msg.match[3]
    dateShift = fluxCapacitate(txt || '1')
    jid = msg.message.user.reply_to
    room = _.findWhere(rooms, { xmpp_jid: jid })
    room_id = room?.room_id || 67789
    targetDate = Date.today().setTimezoneOffset(+600).add(dateShift)
    targetDateFormatted = targetDate.toString("yyyy-MM-dd")
    robot.http("https://api.hipchat.com/v2/room/{room_id}/history?auth_token=#{auth_token}&date=#{targetDateFormatted}")
      .get() (err, res, body) ->

        data = JSON.parse(body)

        if (!data)
          msg.send "(greatscott) Great Scott, there was a problem!"
          return

        if (data.error)
          msg.send "(greatscott) Great Scott, there was a problem! #{data.error.message}"
          return

        if (data.messages.length < 1)
          msg.send "No chats found on #{targetDate.toString('MMM dS, yyyy')}"
          return

        message = msg.random data.messages
        messageDate = Date.parse(message.date).setTimezoneOffset(+600).toString('MMM dS, yyyy @ h:mm tt')
        msg.send "/quote \"#{message.message}\" – #{message.from.name} (#{messageDate})"
