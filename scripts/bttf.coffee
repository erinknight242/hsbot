# Description:
#   For all your BTTF needs

rooms = [
	process.env.HUBOT_ROOM_HEADSPRING,
	process.env.HUBOT_ROOM_DEVELOPERS,
	process.env.HUBOT_ROOM_AUSTIN,
	process.env.HUBOT_ROOM_HOUSTON,
	process.env.HUBOT_ROOM_DALLAS,
	process.env.HUBOT_ROOM_MONTERREY
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
