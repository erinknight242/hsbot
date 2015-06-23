# Description:
#   Let hubot help you brag about your awesome coworkers!
#
# Commands:
#   hubot brag @colleague Thanks for adding in bragging to hsbot

hsBoard = "headspring"

helpText = "hsbot brag @braggee your brag text here"

httpErrorBarks = [
  "I couldn't do that (sadpanda)",
  "Something bad happened",
  "I couldn't reach the Brag board, sorry (shrug)"
]

bragBoard = {
  "usn": "vishal.bardoloi@headspring.com",
  "pw" : "hello123",
  "url": "http://test.brag.headspring.com/"
  "signin": "account/sign-in"
  "get": "api/boards/#{hsBoard}/blocks?start=2015-06-14T00%3A00%3A00-05%3A00&end=2015-06-20T23%3A59%3A59-05%3A00"
}


module.exports = (robot) ->

  # error handling
  robot.error (err, res) ->
    robot.logger.error "Brag board choked on #{err}"  

    if res?
      res.reply "Brag board could not compute"

  # error checking
  foundErrors = (err, res) ->
    if err          
      robot.emit 'error', err, res
      return true

    if res? and res.statusCode isnt 200
      res.send "Got an HTTP #{res.statusCode} error."
      return true

    return false


  # hsbot brag <colleague> text-of-the-brag-here
  robot.respond /brag @([a-zA-Z0-9]+)? (.+)?/i, (msg) ->

    braggee = msg.match[1]
    msg.send "Braggee is #{braggee}"

    bragText = msg.match[2]
    msg.send "Text is #{bragText}"

    bragger = msg.message.user.name
    msg.send "Bragger is #{bragger}"

    data = {
      "email": bragBoard.usn,
      "password": bragBoard.pw
    }

    msg.http(bragBoard.url + bragBoard.signin)
    .header("Content-Type", "application/json")
    .post(data) (err, res, body) ->

        msg.send err
        msg.send res.status
        msg.send res.headers

        # if foundErrors(err, res) 
        #   msg.send msg.random httpErrorBarks
        #   return

        # try 
        #   msg.send "Testing 1"
        #   tlTrack = JSON.parse(body).result
        #   msg.send "Testing 2"
        #   msg.send "#{tlTrack.track.name} by #{getArtistsNames(tlTrack.track)} is playing right now"
        # catch error
        #   msg.send msg.random dataErrorBarks
        #   return

  # hsbot brag <colleague> text-of-the-brag-here
  robot.respond /bragtest/i, (msg) ->
    msg.http(bragBoard.url + bragBoard.get)
    .header("Content-Type", "application/json")
    .header("Cookie", "connect.sid=s%3AeuXSnYNncTBZpHAdHgAFwBn3.77jy2yF5YHc5fMhbgDKS5JMAO19U9orjjnqV6HPDFmY")
    .post(data) (err, res, body) ->

      msg.send err
      msg.send res.status
      msg.send res.headers
      msg.send body







