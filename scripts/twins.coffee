# Description:
#   Listens for messages with 'twins', 'hotel', redrum', 'flight', 'vacation', 'travel', 'motel' in it and responds with the twins image

odds  = [1...100]

module.exports = (robot) ->
	robot.hear /(twins|hotel|redrum|flight|vacation|travel|motel)/i, (msg) ->
		val = msg.random odds
		if val < 5
			msg.send "http://i.imgur.com/qWorWzk.png"
