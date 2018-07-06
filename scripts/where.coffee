# Description:
#   Let hubot tell you where things are.
#
# Commands:
#   hubot where is mercury - find a conference room by name

conferenceRooms = {
  # Austin
  mercury: "https://i.imgur.com/6GyUimi.png",
  zinc: "https://i.imgur.com/erKXXNJ.png",
  silver: "https://i.imgur.com/YmA07P3.png",
  titanium: "https://i.imgur.com/lrSteNN.png",
  oxygen: "https://i.imgur.com/KotsrgR.png",
  hydrogen: "https://i.imgur.com/rtr6Yf8.png",
  silicon: "https://i.imgur.com/TI7o6HV.png",
  carbon: "https://i.imgur.com/EszbFwm.png",
  nitrogen: "https://i.imgur.com/ky4pgBK.png",
  promethium: "https://i.imgur.com/1S6ieRs.png",
  'mean-eyed cat': "https://i.imgur.com/lGimPD5.png",
  'mean eyed cat': "https://i.imgur.com/lGimPD5.png",
  'lustre pearl': "https://i.imgur.com/nf6jOSt.png"

  # Not Rooms
  coffee: "(jura)",
  jimmy: "https://s3.amazonaws.com/grabbagoftimg/jimmy.png",

  # Houston
  burnet: "http://i.imgur.com/CUJd3Di.png",
  'capital of texas': "http://i.imgur.com/20GipJn.png",
  mopac: "http://i.imgur.com/YrVXsQA.png",
  morado: "http://i.imgur.com/4Uc5c2G.png",
  richmond: "http://i.imgur.com/XEv0cEw.png",
  spicewood: "http://i.imgur.com/UMxipTc.png"
}

barks = [
  "I only know how to find conference rooms.",
  "I don't think {0} is a conference room.",
  "I dunno..."
]

module.exports = (robot) ->
  robot.respond /where ?[i']s ([^\?]*)[\?]*/i, (msg) ->
    term = msg.match[1].toLowerCase().trim()
    location = conferenceRooms[term]
    if location?
      msg.send location
    else
      msg.send (msg.random barks).replace("{0}", term)
