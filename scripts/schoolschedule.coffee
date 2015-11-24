# Description:
#   Sending out school theme related messages based on a predefined schedule
#
# Dependencies:
#   node-schedule
#
# Author:
#   hulahomer

schedule = require 'node-schedule'
moment = require 'moment-timezone'

today = moment.tz new Date(), "America/Chicago"

DSToffset = today.utcOffset() / -60

module.exports = (robot) ->
  meditation = schedule.scheduleJob( {hour: 16 + DSToffset, minute: 45, dayOfWeek: 1}, ->
    robot.messageRoom process.env.HUBOT_ROOM_AUSTIN, "@here Meditation in 15 minutes! Go get your PE credits for the Headspring Back To School Theme"
  )
  
  hackClub = schedule.scheduleJob( {hour: 16 + DSToffset, minute: 45, dayOfWeek: 4}, ->
    today = new Date().getDate()
    #only the first Thursday of the month
    if today < 8
      robot.messageRoom process.env.HUBOT_ROOM_AUSTIN, "@here Hack Club in 15 minutes! Go get your Extracurricular credits for the Headspring Back To School Theme"
  )
