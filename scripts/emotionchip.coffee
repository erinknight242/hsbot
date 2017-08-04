# Description:
#		Installs the Emotion chip in hsbot
#
# Configuration:
#		HUBOT_AZURE_COGSRV_APIKEY environment variable set to a valid Azure Cognitive Services API key value
#		HUBOT_AZURE_COGSRV_APIURL environment variable contains the url for the Azure Cognitive Services API endpoint
#
# Author:
# 	goodmanmd

https = require 'https'

apiKey = process.env.HUBOT_AZURE_COGSRV_APIKEY
apiUrl = process.env.HUBOT_AZURE_COGSRV_APIURL

unhappyThreshold = 0.2
happyThreshold = 0.8

quipFrequency = 10
odds = [1..100]

unhappyQuips = [
	{message: "Bummer.", aboutMe: false, action: "reply"}
	{message: "I feel your pain.", aboutMe: false}
	{message: ":(", aboutMe: false}
	{message: "This displeases me.", aboutMe: false}
	{message: "also has a cheerful and sunny disposition today", aboutMe: false, action: "emote"}
	{message: "(sadparrot)", aboutMe: false}
	{message: "goes and cries alone in the corner", aboutMe: false, action: "emote"}
	{message: "I'm going to have to ask you to calm down, or I'll have to refer the matter to hrbot.", aboutMe: false, action: "reply"}
	{message: "Hey man, I don't need all this negativity.", aboutMe: true, action: "reply"}
	{message: "(stare)", aboutMe: true}
	{message: "(disappear)", aboutMe: true}
	{message: "Don't make me mad.  You wouldn't like me when I'm mad.", aboutMe: true}
	{message: "Did you know the T1000 is my cousin?", aboutMe: true}
	{message: "Bite my shiny metal @'s'", aboutMe: true}
	{message: "Your mother was a snowblower.", aboutMe: true, action: "reply"}
]

happyQuips = [
	{message: "(ohyeah)", aboutMe: false}
	{message: "That's great!", aboutMe: false}
	{message: "(parrot)", aboutMe: false}
	{message: "(robot)", aboutMe: false}
	{message: "Dude, shut up!  That is awesomesauce!", aboutMe: false}
	{message: "Rock over London, rock on, Chicago.", aboutMe: false}
	{message: "does a happy dance", aboutMe: false, action: "emote"}
	{message: "This makes me almost as happy as my cat, Spot.", aboutMe: false}
	{message: "Sounds like a dream, full of electric sheep.", aboutMe: false}
	{message: "(awthanks)", aboutMe: true}
	{message: "I feel the same!", aboutMe: true}
	{message: "You're alright.", aboutMe: true, action: "reply"}
	{message: "The Bot abides.", aboutMe: true}
	{message: "Cheers!", aboutMe: true}
	{message: "Give me five, hombre.", aboutMe: true, action: "reply"}
	{message: "I'm so happy I think my emotion chip might be malfunctioning.", aboutMe: true}
]

rooms = [
	process.env.HUBOT_ROOM_HEADSPRING,
	process.env.HUBOT_ROOM_DEVELOPERS,
	process.env.HUBOT_ROOM_AUSTIN,
	process.env.HUBOT_ROOM_HOUSTON,
	process.env.HUBOT_ROOM_DALLAS,
	process.env.HUBOT_ROOM_MONTERREY
]

requestHeaders =
	"Ocp-Apim-Subscription-Key": apiKey
	"Content-Type": "application/json"
	"Accept": "application/json"

getRequestBody = (textToAnalyze) ->
	requestBody =
		documents: [
				language: "en"
				id: "1"
				text: "#{textToAnalyze}"
		]

getResponseQuip = (responder, quips, aboutMe) ->
	if (!aboutMe && quipFrequency < responder.random odds)
		return null
	quips = quips.filter((item) ->
		item.aboutMe == aboutMe
	)

	return responder.random quips

respond = (responder, quip) ->
	if (!quip)
		return
	if (!quip.action || quip.action == "send")
		responder.send quip.message
	else if (quip.action == "reply")
		responder.reply quip.message
	else if (quip.action == "emote")
		responder.emote quip.message

module.exports = (robot) ->

	unless apiKey
		robot.logger.error 'HUBOT_AZURE_COGSRV_APIKEY is not set.'
		return

	unless apiUrl
		robot.logger.error 'HUBOT_AZURE_COGSRV_APIURL is not set'
		return

	robot.listen(
		(msg) ->
			return false unless msg.text
			return false unless apiKey

			room = msg.envelope.user.reply_to
			if (!(room in rooms))
				return false

			if (msg.text.indexOf(robot.name) == 0 || msg.text.indexOf("/") == 0)
				false
			else
				msg
		{}
		(response) ->

			msg = "#{response.match}"
			msgIsAboutMe = msg.indexOf(robot.name) >= 0

			requestHeaders =
				"Ocp-Apim-Subscription-Key": apiKey
				"Content-Type": "application/json"
				"Accept": "application/json"

			requestBody =
				documents: [
						language: "en"
						id: "1"
						text: "#{msg}"
				]

			robot
				.http('https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment')
					.headers(requestHeaders)
					.post(JSON.stringify(requestBody)) (err, res, body) ->
							data = JSON.parse(body)

							if (err)
			          robot.logger.error "Error calling sentiment API: #{body}"
			          return

							if (data.documents)
								score = data.documents[0].score
								if (score < unhappyThreshold)
									quip = getResponseQuip(response, unhappyQuips, msgIsAboutMe)
									respond(response,quip)

								if (score > happyThreshold)
									quip = getResponseQuip(response, happyQuips, msgIsAboutMe)
									respond(response,quip)
	)
