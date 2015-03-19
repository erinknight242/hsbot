# Description:
#   Listens for messages in ALL CAPS to tell the user to simmer down

quips = [
	"Whoa Captain Capitals, simmer down...",
	"Easy killer, CAPS never got anyone anywhere...",
	"Repeat after me: 3,2,1...1,2,3 What the heck is bothering me?",
	"Some people say that if you don't have anything nice to say, SAY IT IN ALL CAPS",
	"SAYING IT LOUDER DOESN'T MEAN YOU'RE RIGHT"
]

module.exports = (robot) ->
	robot.hear /([A-Z\s]){7,}/g, (msg) ->
		msg.send msg.random quips
