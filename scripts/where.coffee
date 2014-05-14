# Description:
#   Let hubot tell you where things are.
#
# Commands:
#   hubot where is mercury - find a conference room by name

conferenceRooms = {
  mercury: "http://i.imgur.com/0m2y6yG.png",
  zinc: "http://i.imgur.com/0m2y6yG.png",
  silver: "http://i.imgur.com/0m2y6yG.png",
  titanium: "http://i.imgur.com/0m2y6yG.png",
  oxygen: "http://i.imgur.com/0m2y6yG.png",
  hydrogen: "http://i.imgur.com/0m2y6yG.png",
  silicon: "http://i.imgur.com/0m2y6yG.png",
  carbon: "http://i.imgur.com/0m2y6yG.png",
  nitrogen: "http://i.imgur.com/0m2y6yG.png",
  promethium: "http://i.imgur.com/0m2y6yG.png"
}

barks = [
  "I only know how to find conference rooms.",
  "I don't think {0} is a conference room.",
  "I dunno..."
]

module.exports = (robot) ->
  robot.respond /where ?is ([^\?]*)[\?]*/i, (msg) ->
    term = msg.match[1].toLowerCase().trim()
    location = conferenceRooms[term]
    if location?
      msg.send location
    else
      msg.send (msg.random barks).replace("{0}", term)