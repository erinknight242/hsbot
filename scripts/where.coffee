# Description:
#   Let hubot tell you where things are.
#
# Commands:
#   hubot where is mercury - find a conference room by name

conferenceRooms = {
  mercury: "http://i.imgur.com/AZfkrM8.png",
  zinc: "http://i.imgur.com/z8JcXX5.png",
  silver: "http://i.imgur.com/sT3pAGO.png",
  titanium: "http://i.imgur.com/ZUqPTp7.png",
  oxygen: "http://i.imgur.com/5eHK2Hd.png",
  hydrogen: "http://i.imgur.com/48mayHi.png",
  silicon: "http://i.imgur.com/rvw1Y5P.png",
  carbon: "http://i.imgur.com/9CeF1oB.png",
  nitrogen: "http://i.imgur.com/MqF2DZz.png",
  promethium: "http://i.imgur.com/zxwVDru.png",
  jimmy: "https://s3.amazonaws.com/grabbagoftimg/jimmy.png",
  neocoltrane: "http://i.imgur.com/H8FUzPS.png",
  davis: "http://i.imgur.com/pE20nhD.png",
  brubeck: "http://i.imgur.com/dmJ2BDv.png",
  parker: "http://i.imgur.com/v1AhrJQ.png",
  coffee: "(jura)",
  burnet: "http://i.imgur.com/CUJd3Di.png",
  capitaloftexas: "http://i.imgur.com/20GipJn.png",
  mopac: "http://i.imgur.com/YrVXsQA.png",
  morado: "http://i.imgur.com/4Uc5c2G.png",
  richmond: "http://i.imgur.com/XEv0cEw.png",
  spicewood: "http://i.imgur.com/UMxipTc.png",
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
    location = conferenceRooms[term]
    if location?
      msg.send location
    else
      msg.send (msg.random barks).replace("{0}", term)
