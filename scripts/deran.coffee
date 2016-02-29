# Description:
#   Listens for messages with 'Deran' in it and responds with the Hi Deran image

rooms = [
		HUBOT_ROOM_HEADSPRING,
		HUBOT_ROOM_DEVELOPERS,
		HUBOT_ROOM_AUSTIN,
		HUBOT_ROOM_HOUSTON,
		HUBOT_ROOM_DALLAS,
		HUBOT_ROOM_MONTERREY
	]

odds  = [1...100]

module.exports = (robot) ->
	robot.hear /(Deran|deran)/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val < 10
				msg.send "http://i.imgur.com/reDPhBx.jpg"
