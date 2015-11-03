# Description:
#   Sending out school theme related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule
#
# Author:
#   hulahomer

schedule = require('node-schedule')

DSToffset = new Date().getTimezoneOffset() / 60

module.exports = (robot) ->
  meditation = schedule.scheduleJob( {hour: 16 + DSToffset, minute: 45, dayOfWeek: 1}, ->
    robot.messageRoom process.env.HUBOT_ROOM_AUSTIN, "@here Meditation in 15 minutes! Go get your PE credits for the Headspring Back To School Theme"
  )

  basketball = schedule.scheduleJob( {hour: 17 + DSToffset, minute: 15, dayOfWeek: 2}, ->
    robot.messageRoom process.env.HUBOT_ROOM_AUSTIN, "@here Basketball in 15 minutes on the parking garage roof! Go get your PE credits for the Headspring Back To School Theme"
  )

  volleyball = schedule.scheduleJob( {hour: 17 + DSToffset, minute: 15, dayOfWeek: 4}, ->
    robot.messageRoom process.env.HUBOT_ROOM_AUSTIN, "@here Volleyball in 15 minutes! Go get your PE credits for the Headspring Back To School Theme"
  )

  hackClub = schedule.scheduleJob( {hour: 16 + DSToffset, minute: 45, dayOfWeek: 4}, ->
    today = new Date().getDate()
    #only the first Thursday of the month
    if today < 8
      robot.messageRoom process.env.HUBOT_ROOM_AUSTIN, "@here Hack Club in 15 minutes! Go get your Extracurricular credits for the Headspring Back To School Theme"
  )
