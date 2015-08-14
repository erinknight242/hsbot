# Description:
#   Sending out school theme related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule
#
# Author:
#   hulahomer

schedule = require('node-schedule')

module.exports = (robot) ->
  meditation = schedule.scheduleJob({hour:16, minute: 45, dayOfWeek: 1}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Meditation in 15 minutes! Go get your PE credits for the Headspring Back To School Theme"
  )

  basketball = schedule.scheduleJob({hour:17, minute: 0, dayOfWeek: 2}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Basketball in 15 minutes on the parking garage roof! Go get your PE credits for the Headspring Back To School Theme"
  )

  volleyball = schedule.scheduleJob({hour:17, minute: 15, dayOfWeek: 4}, ->
    robot.messageRoom "18483_austin@conf.hipchat.com", "@here Volleyball in 15 minutes! Go get your PE credits for the Headspring Back To School Theme"
  )
