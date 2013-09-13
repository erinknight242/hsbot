# Description:
#   Provides some common D&D-related functions.
#
# Commands:
#   hubot roll dX - roll an X-sided die (e.g. `d20`)
#   hubot roll YdX - roll Y X-sided dice (e.g. `2d6`)
#   hubot roll YdX+Z - roll Y X-sided dice, adding a modifier (e.g. `1d4+2`)

roll = (die, qty = 1, mod = 0) ->
  total = +mod

  rolls = for number in [1..qty]
    result = Math.floor(Math.random() * die) + 1
    total += result
    result

  total: total
  rolls: rolls

module.exports = (robot) ->
  robot.respond /dnd (\d+)?d(\d+)(\+(\d+))?/i, (msg) ->
    qty = msg.match[1]
    die = msg.match[2]
    mod = msg.match[4] # `match[3]` includes the '+'
    result = roll die, qty, mod
    msg.send "rolled a #{result.total} (#{result.rolls.join ', '})"