# Description:
#   Gets information on food trucks at the office.
#
# Commands:
#   hubot food truck - Returns the food truck that is scheduled for the Avallon that day.

date = require 'datejs'

module.exports = (robot) ->
  robot.respond /food truck$/i, (msg) ->
    trucks = [null, "Evil Weiner", "Short Bus Subs", null, "Little Fatty's", ["Way South Philly", "Wholly Kabob"], null]
    truck = trucks[new Date().getDay()]
    if truck
    	if truck.length == 2
    		truck = truck[Date.today().getWeek() % 2]
    	msg.send "The food truck for " + Date.today().toString("dddd") + " is #{truck} (chompy)"
    else
    	msg.send "Awww beans! There's no food truck today. (sadpanda) Try `hsbot lunch me`! ;)"
