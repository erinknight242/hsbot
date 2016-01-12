# Description:
#   Listens for messages with 'Deran' in it and responds with the Hi Deran image

odds  = [1...100]

module.exports = (robot) ->
	robot.hear /(Deran|deran)/i, (msg) ->
		val = msg.random odds
		if val < 10
			msg.send "http://i.imgur.com/reDPhBx.jpg"
