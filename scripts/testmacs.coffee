# Description:
#   Because, it's just (supposed to) work!

odds  = [1...100]

pics = ["http://i.imgur.com/fEbhFJs.png",
		"http://i.imgur.com/NSj5Yed.jpg",
		"http://i.imgur.com/ET7lt18.png",
		"http://i.imgur.com/mFh3qzV.jpg",
		"http://i.imgur.com/KEgZLy1.jpg",
		"http://i.imgur.com/P004fny.jpg",
		"http://i.imgur.com/l2B10sl/jpg",
		"http://i.imgur.com/jmZyaFX.jpg",
		"http://i.imgur.com/IZqHEPM.jpg"
		]

rooms = ["18483_austin@conf.hipchat.com",
    "18483_houston@conf.hipchat.com",
    "18483_dallas@conf.hipchat.com",
    "18483_lunch_planning_committee@conf.hipchat.com"
    ]

module.exports = (robot) ->
	robot.hear /testroom/i, (msg) ->
		val = msg.random odds
		room = msg.message.room
		msg.send room
