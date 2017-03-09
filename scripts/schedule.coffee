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

  discGolf = schedule.scheduleJob('45 13 22-28 * 0', ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Disc Golf in 15 minutes! Join in to earn a blue star!"
  )
