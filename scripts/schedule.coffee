# Description:
#   Sending out theme team related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule

schedule = require('node-schedule')
moment = require('moment-timezone')

timeOffset = moment.tz.zone('America/Chicago').offset(moment())/60

module.exports = (robot) ->
  basketball = schedule.scheduleJob({hour: 17 + timeOffset, minute: 15, dayOfWeek: 4}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Basketball in 15 minutes on the parking garage roof! Go earn a blue star!"
  )

  #2nd Tuesday of the month at 1:45
  discGolf = schedule.scheduleJob({ hour: 13 + timeOffset, minute: 45, dayOfWeek: 2, date: new schedule.Range(8, 14)}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Disc Golf in 15 minutes! Join in to earn a blue star!"
  )

  #4th Tuesday of the month at 11:45
  tedTalks = schedule.scheduleJob({ hour: 11 + timeOffset, minute: 45, dayOfWeek: 2, date: new schedule.Range(22, 28)}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here TED Talk Time in 15 minutes, bring your lunch to Promethium!"
  )
