# Description:
#   For all your BTTF needs

odds  = [1...100]

module.exports = (robot) ->
	robot.hear /\bheavy\b/i, (msg) ->
		val = msg.random odds
		if val > 50
			msg.send "There's that word again. Heavy. Why are things so heavy in the future?"

	robot.hear /\broad(s)?\b/i, (msg) ->
		val = msg.random odds
		if val > 50
			msg.send "Roads? Where we're going, we don't need roads."
