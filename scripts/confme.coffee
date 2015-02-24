# Description:
#   A way to view conference room numbers.
#
# Commands:
#	hubot confrooms
#	hubot conf rooms <location>
#   hubot conf save <number> to <location> as <name>
#	hubot conf remove <name> in <location>
#
# Examples:
#	hubot conf Houston
#	hubot conf save 555-555-5555 to Houston as Spicewood
#	hubot conf remove Spicewood in Houston

module.exports = (robot) ->
	robot.respond /conf\ssave\s+(.*)\sto\s(.*)\sas\s(.*)/i, (msg) ->
		
		data = JSON.stringify({
		    phone: msg.match[1]
		    location: msg.match[2]
		    name: msg.match[3]
		  })

		robot.http("http://hsbotdev.azurewebsites.net/rooms")
			.header('Content-Type', 'application/json')
			.post(data) (err, res, body) ->
				if res.statusCode isnt 200
			        msg.send "Could not save room :( - #{err} - #{body}"
			        return

				msg.send "Room saved #{body}"
	
	robot.respond /conf\sremove\s(.*)\sin\s(.*)/i, (msg) ->
		name = msg.match[1]
		location = msg.match[2]

		robot.http("http://hsbotdev.azurewebsites.net/rooms?name=#{name}&location=#{location}")
			.delete() (err, res, body) ->
				if res.statusCode isnt 200
			        msg.send "Could not save room :( - #{err} - #{body}"
			        return
				msg.send "Removed #{name} in #{location}"
	

	robot.respond /conf\srooms\s(.*)/i, (msg) ->
		location = msg.match[1]

		robot.http("http://hsbotdev.azurewebsites.net/rooms?location=#{location}")
			.get() (err, res, body) ->
				msg.send "#{room.name}: #{room.phone}\n" for room in JSON.parse(body)[0..50]

		
	robot.respond /confrooms/i, (msg) ->
		robot.http("http://hsbotdev.azurewebsites.net/rooms")
			.get() (err, res, body) ->
				msg.send "(#{room.location}) #{room.name}: #{room.phone}\n" for room in JSON.parse(body)[0..50]

