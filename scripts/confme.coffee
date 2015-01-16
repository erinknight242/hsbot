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
	rooms = () -> robot.brain.data.rooms ?= []

	saveRoom = (location, name, number) ->
		room = 
			number: number
			location: location
			name: name

		saved = false
		for r in rooms()
			if(r.location == room.location && r.name == room.name)
				r.number = room.number
				saved = true

		if(!saved)
			rooms().push room


	removeRoom = (location, name) ->
		for r in rooms()
			if(r.location == location && r.name == name)
				rooms().pop r


	String::capitalize = ->
    	@replace /^./, (match) ->
        	match.toUpperCase()


	robot.respond /conf\ssave\s+(.*)\sto\s(.*)\sas\s(.*)/i, (msg) ->
		number = msg.match[1]
		location = msg.match[2].toLowerCase().capitalize()
		name = msg.match[3].toLowerCase().capitalize()

		saveRoom(location, name, number)

		msg.send "Saved " + number + " as " + name + " at the " + location + " office"

	
	robot.respond /conf\sremove\s(.*)\sin\s(.*)/i, (msg) ->
		name = msg.match[1].toLowerCase().capitalize()
		location = msg.match[2].toLowerCase().capitalize()

		removeRoom(location, name)
		msg.send "Removed any room named " + name + " in " + location


	robot.respond /conf\srooms\s(.*)/i, (msg) ->
		location = msg.match[1].toLowerCase().capitalize()

		output = location + " Conference Rooms: \n===========================\n";
		for room in rooms()
			if(room.location == location)
				output += room.name + ": " + room.number + "\n"
	
		msg.send output


	robot.respond /confrooms/i, (msg) ->
		output = "Conference Rooms: \n===========================\n";
		for room in rooms()
			output += "(" + room.location + ") " + room.name + ": " + room.number + "\n"
	
		msg.send output
