# Description:
#   Listens for words and sometimes replies with beer related insight.

odds  = [1...100]

quips = [
	"┬─┬ノ(ಠ_ಠノ) please respect tables"	,
]

module.exports = (robot) ->
	robot.hear /(.+)?(tableflip)(.+)?/i, (msg) ->
		val = msg.random odds
		if val > 25
			msg.send msg.random quips