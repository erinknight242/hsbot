# Description:
#   Gets information on food trucks at the office.
#
# Commands:
#   hubot food truck - Returns the food truck that is scheduled for the Avallon that day.

date = require 'datejs'

module.exports = (robot) ->
  robot.respond /(food truck|foodtruck)$/i, (msg) ->
    trucks = [null,
              [{name: "Keiths BBQ", site: "http://keithsbbq.com/"}, {name: "Mission Hot Dogs", site: "https://twitter.com/MissionHotDogs"}],
              [null, {name: "Short Bus Subs", site: "http://www.shortbussubs.com/event-calendar.html"}],
              null,
              [{name: "Rosarito Foodtruck", site: "https://twitter.com/rosaritoatx"}, {name: "The Ginger Armadillo", site: "http://thegingerarmadillo.com/locate"}],
              [null, null],
              null]
    truck = trucks[new Date().getDay()]
    if truck
        if truck.length == 2
            truck = truck[Date.today().getWeek() % 2]
        if not truck
            truck = trucks[new Date().getDay()][(Date.today().getWeek() + 1) % 2]
            message = "No food truck today, but next week it will be #{truck.name}"
            message = message + if truck.name == "Short Bus Subs" then " (sandwich)" else ""
            msg.send message
            return
        message = "The food truck for " + Date.today().toString("dddd") + " is #{truck.name}, which you can verify here: #{truck.site} (chompy)"
        message = message + if truck.name == "Short Bus Subs" then " (sandwich)" else ""
        msg.send message
    else
        msg.send "Awww beans! There's no food truck today. (sadpanda) Try `hsbot lunch me`! ;)"
