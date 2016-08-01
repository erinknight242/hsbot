# Description:
#   Gets information on food trucks at the office.
#
# Commands:
#   hubot food truck - Returns the food truck that is scheduled for The Campus that day.

date = require 'datejs'

module.exports = (robot) ->
  robot.respond /(food truck|foodtruck)$/i, (msg) ->
    trucks = [null,
              [{name: "Savery Grilled Cheese", site: "http://www.saverygrilledcheese.com", time: "11:30am - 1:30pm"}, {name: "Mission Hot Dogs", site: "https://twitter.com/MissionHotDogs", time: "11:30am - 2:00pm"}],
              [{name: "Ground Up", site: "http://www.grounduptruck.com/", time: "8:00am - 1:30pm"}, {name: "Cafe Ybor", site: "http://www.cafeybor.com", time: "11:00am - 1:30pm"}],
              null,
              [{name: "The Ginger Armadillo", site: "http://thegingerarmadillo.com/locate", time: "11:00am - 2:00pm"}, {name: "Heart of Texas BBQ", site: "http://www.heartoftexasbarbecue.com", time: "11:00am - 2:00pm"}],
              [{name: "WunderPig", site: "http://www.wunderpig.com/", time: "11:30am - 2:00pm"}, {name: "Melted Grilled Cheese", site: "http://www.meltedtruck.com/", time: "11:00am - 2:00pm"}],
              null]
    truck = trucks[new Date().getDay()]
    if truck
        if truck.length == 2
            truck = truck[Date.today().getWeek() % 2]
        if not truck
            truck = trucks[new Date().getDay()][(Date.today().getWeek() + 1) % 2]
            message = "No food truck today, but next week it will be #{truck.name}"
            msg.send message
            return
        message = "The food truck for " + Date.today().toString("dddd") + " is #{truck.name}, which you can verify here: #{truck.site} (chompy)"
        msg.send message
    else
        msg.send "Awww beans! There's no food truck today. (sadpanda) Try `hsbot lunch me`! ;)"
  robot.respond /food truck schedule$/i, (msg) ->
    msg.send "Here is the food truck schedule for The Avallon: https://raw.githubusercontent.com/HeadspringLabs/hsbot/master/foodtruckschedule.jpg"
