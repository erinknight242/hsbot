# Description:
#   For all your BTTF needs

odds  = [1...100]

module.exports = (robot) ->
	robot.hear /(.+)?(heavy)(.+)?/i, (msg) ->
		val = msg.random odds
		if val > 50
			msg.send "There's that word again. Heavy. Why are things so heavy in the future?"

	robot.hear /(.+)?(road)(.+)?/i, (msg) ->
		val = msg.random odds
		if val > 50
			msg.send "Roads? Where were going, we don't need roads"