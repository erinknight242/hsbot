# Description:
#   Fetch the March Madness bracket standings
#
# Commands:
#   hsbot (foosball|pingpong) standings

module.exports = (robot) ->
  robot.respond /standings/ig, (msg) ->
  robot.respond /(?:(foosball|pingpong)[- ])?standings([- ](.+))?/i, (msg) ->
    foosballUrl = 'http://challonge.com/headspring_marchmadness_foosball'
    pingpongUrl = 'http://challonge.com/headspring_march_madness_pingpong'
    if msg.match[1] == 'foosball'
      msg.send foosballUrl
    else if msg.match[1] == 'pingpong'
      msg.send pingpongUrl
    else
      msg.send foosballUrl
      msg.send pingpongUrl
