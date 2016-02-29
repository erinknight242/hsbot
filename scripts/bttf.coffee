# Description:
#   For all your BTTF needs

rooms = [
		HUBOT_ROOMS_HEADSPRING,
		HUBOT_ROOMS_DEVELOPERS,
		HUBOT_ROOMS_AUSTIN,
		HUBOT_ROOMS_HOUSTON,
		HUBOT_ROOMS_DALLAS,
		HUBOT_ROOMS_MONTERREY
	]

odds  = [1...100]

module.exports = (robot) ->
	robot.hear /\bheavy\b/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val > 50
				msg.send "There's that word again. Heavy. Why are things so heavy in the future?"

	robot.hear /\broad(s)?\b/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val > 50
				msg.send "Roads? Where we're going, we don't need roads."
