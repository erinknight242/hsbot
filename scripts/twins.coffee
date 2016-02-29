# Description:
#   Listens for messages with 'twins', 'hotel', redrum', 'flight', 'vacation', 'travel', 'motel' in it and responds with the twins image

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
	robot.hear /(twins|hotel|redrum|flight|vacation|travel|motel)/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val < 5
				msg.send "http://i.imgur.com/qWorWzk.png"
