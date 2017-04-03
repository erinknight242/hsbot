# Description:
#   Sending out theme team related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule

schedule = require('node-schedule')
moment = require('moment-timezone')

timeOffset = moment.tz.zone('America/Chicago').offset(moment())/60

module.exports = (robot) ->
  basketball = schedule.scheduleJob({hour: 16 + timeOffset, minute: 45, dayOfWeek: 4}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Basketball in 15 minutes on the parking garage roof!"
  )

  #Runs every Tuesday; only sends message every other Tuesday (because cron and outlook don't agree on recurrence rules)
  discGolf = schedule.scheduleJob({ hour: 13 + timeOffset, minute: 45, dayOfWeek: 2}, ->
    if (moment().format("w") % 2 == 0) #even weeks of the year
      robot.messageRoom "18483_austin@conf.hipchat.com", "@here Disc Golf in 15 minutes!"
  )

  #4th Tuesday of the month at 11:45
  tedTalks = schedule.scheduleJob({ hour: 11 + timeOffset, minute: 45, dayOfWeek: 2, date: new schedule.Range(22, 28)}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here TED Talk Time in 15 minutes, bring your lunch to Promethium!"
  )
