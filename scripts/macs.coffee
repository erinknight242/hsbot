# Description:
#   Because, it's just (supposed to) work!

rooms = [
	process.env.HUBOT_ROOM_HEADSPRING,
	process.env.HUBOT_ROOM_DEVELOPERS,
	process.env.HUBOT_ROOM_AUSTIN,
	process.env.HUBOT_ROOM_HOUSTON,
	process.env.HUBOT_ROOM_DALLAS,
	process.env.HUBOT_ROOM_MONTERREY
]


odds  = [1...100]

pics = [
	"http://i.imgur.com/fEbhFJs.png",
	"http://i.imgur.com/NSj5Yed.jpg",
	"http://i.imgur.com/ET7lt18.png",
	"http://i.imgur.com/mFh3qzV.jpg",
	"http://i.imgur.com/KEgZLy1.jpg",
	"http://i.imgur.com/P004fny.jpg",
	"http://i.imgur.com/l2B10sl/jpg",
	"http://i.imgur.com/jmZyaFX.jpg",
	"http://i.imgur.com/IZqHEPM.jpg"
]

module.exports = (robot) ->
	robot.hear /it just works/i, (msg) ->
		room = msg.envelope.user.reply_to
		if room in rooms
			val = msg.random odds
			if val > 50
				msg.send "#{pics[val%5]}"
