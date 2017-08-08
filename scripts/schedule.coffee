# Description:
#   Sending out theme team related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule

schedule = require('node-schedule')
moment = require('moment-timezone')

timeOffset = moment.tz.zone('America/Chicago').offset(moment())/60

module.exports = (robot) ->
  basketball = schedule.scheduleJob({hour: 16 + timeOffset, minute: 45, dayOfWeek: 2}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Basketball in 15 minutes on the parking garage roof!"
  )
