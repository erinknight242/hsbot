# Description:
#   Listens for messages with 'Deran' in it and responds with the Hi Deran image

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
	robot.hear /(Deran|deran)/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val < 10
				msg.send "http://i.imgur.com/reDPhBx.jpg"
