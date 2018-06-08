# Description:
#   Sending out theme team related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule

schedule = require('node-schedule')
moment = require('moment-timezone')

timeOffset = moment.tz.zone('America/Chicago').offset(moment())/60

module.exports = (robot) ->
  discGolf = schedule.scheduleJob({ hour: 8 + timeOffset, minute: 30, dayOfWeek: 5}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Good morning! Disc Golf in 15 minutes. Toss some discs before it gets too hot! (discgolf)"
  )
