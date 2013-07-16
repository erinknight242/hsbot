# Description:
#   A way to view conference room numbers.
#
# Commands:
#   hubot location conf add number
#	hubot location conf me
#
# Examples:
#	hubot huston conf add Spicewood: 555-555-5555
# 	hubot austin conf me

rooms = [];

module.exports = (robot) ->
	robot.respond /(?:(austin|houston)[- ])?conf add([- ](.+))?/i, (msg) ->
		room = 
			number: msg.match[3]
			location: msg.match[1]
			
		rooms.push room;
		output = "Added room to " + room.location;
		msg.send output
		
	robot.respond /(?:(austin|houston)[- ])?conf me/i, (msg) ->
		location = msg.match[1];
		output = location + " conference rooms:\n===========================\n";
		for room in rooms
			if(room.location == location)
				output += room.number + "\n";
		msg.send output