# Description:
#   Listens for messages with 'twins', 'hotel', redrum', 'flight', 'vacation', 'travel', 'motel' in it and responds with the twins image

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
	robot.hear /(twins|hotel|redrum|flight|vacation|travel|motel)/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val < 5
				msg.send "http://i.imgur.com/qWorWzk.png"
