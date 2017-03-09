# Description:
#   Sending out theme team related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule

schedule = require('node-schedule')

module.exports = (robot) ->
  basketball = schedule.scheduleJob({hour:17, minute: 15, dayOfWeek: 4}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Basketball in 15 minutes on the parking garage roof! Go earn a blue star!"
  )

  discGolf = schedule.scheduleJob('45 13 8-14 * 2', -> #2nd Tuesday of the month at 1:45
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Disc Golf in 15 minutes! Join in to earn a blue star!"
  )

  tedTalks = schedule.scheduleJob('45 11 22-28 * 2', -> #4th Tuesday of the month at 11:45
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here TED Talk Time in 15 minutes, bring your lunch to Promethium!"
  )
