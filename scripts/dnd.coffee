# Description:
#   Provides some common D&D-related functions.
#
# Commands:
#   hubot roll XdY - roll X (or one) Y-sided dice

roll = (die, qty = 1) ->
  total = 0

  rolls = for number in [1..qty]
    result = Math.floor(Math.random() * die) + 1
    total += result
    result

  total: total
  rolls: rolls

module.exports = (robot) ->
  robot.respond /dnd (\d+)?d(\d+)/i, (msg) ->
    qty = msg.match[1]
    die = msg.match[2]
    result = roll die, qty
    msg.send "rolled a #{result.total} (#{result.rolls.join ', '})"