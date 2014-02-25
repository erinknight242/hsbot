# Description:
#   Gets information on food trucks at the office.
#
# Commands:
#   hubot food truck - Returns the food truck that is scheduled for the Avallon that day.

date = require 'datejs'

module.exports = (robot) ->
  robot.respond /food truck$/i, (msg) ->
    trucks = [null, [null, "Evil Weiner"], "Short Bus Subs", null, ["Chaat Shop", null], null, null]
    truck = trucks[new Date().getDay()]
    if truck
        if truck.length == 2
            truck = truck[Date.today().getWeek() % 2]
        if not truck
            truck = trucks[new Date().getDay()][(Date.today().getWeek() + 1) % 2]
            msg.send "No food truck today, but next week it will be #{truck}"
            return
        msg.send "The food truck for " + Date.today().toString("dddd") + " is #{truck} (chompy)"
    else
        msg.send "Awww beans! There's no food truck today. (sadpanda) Try `hsbot lunch me`! ;)"
