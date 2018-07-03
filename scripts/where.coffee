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

  # Not Rooms
  coffee: "(jura)",
  jimmy: "https://s3.amazonaws.com/grabbagoftimg/jimmy.png",

  # Austin 1st floor
  neocoltrane: "http://i.imgur.com/H8FUzPS.png",
  davis: "http://i.imgur.com/pE20nhD.png",
  brubeck: "http://i.imgur.com/dmJ2BDv.png",
  parker: "http://i.imgur.com/v1AhrJQ.png",

  # Houston
  burnet: "http://i.imgur.com/CUJd3Di.png",
  capitaloftexas: "http://i.imgur.com/20GipJn.png",
  mopac: "http://i.imgur.com/YrVXsQA.png",
  morado: "http://i.imgur.com/4Uc5c2G.png",
  richmond: "http://i.imgur.com/XEv0cEw.png",
  spicewood: "http://i.imgur.com/UMxipTc.png",

  # Dallas
  babbage: "http://i.imgur.com/NBa3oPh.png",
  church: "http://i.imgur.com/wSNZg2G.png",
  descartes: "http://i.imgur.com/N9kdLb6.png",
  euclid: "http://i.imgur.com/ca523ge.png",
  leibniz: "http://i.imgur.com/lIy2AB4.png",
  liskov: "http://i.imgur.com/FJIFI5B.png",
  pascal: "http://i.imgur.com/ldiEdlf.png",
  turing: "http://i.imgur.com/qwP8Pzd.png"
}

barks = [
  "I only know how to find conference rooms.",
  "I don't think {0} is a conference room.",
  "I dunno..."
]

module.exports = (robot) ->
  robot.respond /where ?[i']s ([^\?]*)[\?]*/i, (msg) ->
    term = msg.match[1].toLowerCase().trim()
    term = term.split("-").pop()
    location = conferenceRooms[term]
    if location?
      msg.send location
    else
      msg.send (msg.random barks).replace("{0}", term)
