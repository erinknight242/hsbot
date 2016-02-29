# Description:
#   Listens for messages with 'Deran' in it and responds with the Hi Deran image

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
	robot.hear /(Deran|deran)/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val < 10
				msg.send "http://i.imgur.com/reDPhBx.jpg"
