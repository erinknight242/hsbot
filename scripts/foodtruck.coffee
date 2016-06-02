# Description:
#   Gets information on food trucks at the office.
#
# Commands:
#   hubot food truck - Returns the food truck that is scheduled for the Avallon that day.

date = require 'datejs'

module.exports = (robot) ->
  robot.respond /(food truck|foodtruck)$/i, (msg) ->
    trucks = [null,
              [{name: "Savery Grilled Cheese", site: "http://www.saverygrilledcheese.com"}, {name: "Mission Hot Dogs", site: "https://twitter.com/MissionHotDogs"}],
              [{name: "Ground Up", site: "http://www.grounduptruck.com/"}, {name: "Cafe Ybor", site: "http://www.cafeybor.com"}],
              null,
              [{name: "The Ginger Armadillo", site: "http://thegingerarmadillo.com/locate"}, {name: "Heart of Texas BBQ", site: "http://www.heartoftexasbarbecue.com"}],
              [{name: "WunderPig", site: "http://www.wunderpig.com/"}, {name: "Melted Grilled Cheese", site: "http://www.meltedtruck.com/"}],
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
  robot.respond /food truck schedule$/i, (msg) ->
    msg.send "Here is the food truck schedule for The Avallon: https://raw.githubusercontent.com/HeadspringLabs/hsbot/master/foodtruckschedule.jpg"
