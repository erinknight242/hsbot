# Description:
#   Gets information on food trucks at the office.
#
# Commands:
#   hubot food truck - Returns the food truck that is scheduled for The Campus that day.

date = require 'datejs'

module.exports = (robot) ->
  robot.respond /(food truck|foodtruck)$/i, (msg) ->
    trucks = [null,
              [
                {
                  breakfast: null,
                  lunch:
                    {
                      name: "Thai 2 U",
                      site: "http://thecampusatarboretum.info/toc.cfm",
                      time: "11:30am - 2:00pm"
                    }
                },
                {
                  breakfast: null,
                  lunch:
                    {
                      name: "Mission Hot Dogs",
                      site: "https://twitter.com/MissionHotDogs",
                      time: "11:30am - 2:00pm"
                    }
                }
              ],
              [
                {
                  breakfast: null
                  lunch: {
                    name: "Ramonas Hummus",
                    site: "https://www.ramonashummus.com/",
                    time: "11:30am - 2:00pm"
                  }
                },
                {
                  breakfast:
                    {
                      name: "Top Taco",
                      site: "http://www.tacofoodgroup.com/",
                      time: "8:00am - 10:15am"
                    }
                  lunch:
                    {
                      name: "Cafe Ybor",
                      site: "http://www.cafeybor.com",
                      time: "11:00am - 1:30pm"
                    }
                }
              ],
              [
                null,
                null
              ],
              [
                {
                  breakfast:
                    {
                      name: "Top Taco",
                      site: "http://www.tacofoodgroup.com/",
                      time: "8:00am - 10:15am"
                    }
                  lunch:
                    {
                      name: "Cluck-N-Burger",
                      site: "https://www.facebook.com/CLUCKNBURGER/",
                      time: "11:30am - 1:30pm"
                    }
                },
                {
                  breakfast: null,
                  lunch:
                    {
                      name: "Heros Gyros",
                      site: "http://www.theherosgyros.com",
                      time: "11:30am - 2:00pm"
                    }
                }
              ],
              [
                {
                  breakfast: null,
                  lunch:
                    {
                      name: "Dragon Bowl",
                      site: "https://www.facebook.com/DragonBowlATX",
                      time: "11:30am - 2:00pm"
                    }
                },
                null
              ],
              null]
    today = new Date()
    day = today.getDay()
    hour = today.getHours()
    weekday = today.toString("dddd")
    if(hour > 20)
      day = day + 1
      today.setDate(today.getDate() + 1)
      weekday = today.toString("dddd")
    truck = trucks[day]
    if truck
      if truck.length == 2
        truck = truck[Date.today().getWeek() % 2]
      if not truck
        truck = trucks[new Date().getDay()][(Date.today().getWeek() + 1) % 2]
        if (truck && truck.lunch)
          message = "No food truck today, but next week it will be #{truck.lunch.name}"
        else
          message = "No food truck today (sadpanda)"
        msg.send message
        return
      if truck.breakfast
        message = "The breakfast food truck for " + weekday + " is #{truck.breakfast.name}, and they will be here from #{truck.breakfast.time}, which you can verify here: #{truck.breakfast.site}"
        msg.send message
      if truck.lunch
        message = "The lunch food truck for " + weekday + " is #{truck.lunch.name}, and they will be here from #{truck.lunch.time}, which you can verify here: #{truck.lunch.site}"
        msg.send message
      msg.send "(chompy)"
    else
      msg.send "Awww beans! There's no food truck today. (sadpanda) Try `hsbot lunch me`! ;)"
  robot.respond /food truck schedule$/i, (msg) ->
    msg.send "Here is the food truck schedule for The Campus: https://raw.githubusercontent.com/HeadspringLabs/hsbot/master/foodtruckschedule.jpg"
