# Description:
#   Fetch the Challonge bracket standings link
#
# Commands:
#   hsbot standings

module.exports = (robot) ->
  robot.respond /standings/ig, (msg) ->
    foosballUrl = 'https://challonge.com/headspring_world_cup'
    msg.send "#{foosballUrl} (foosball)"
