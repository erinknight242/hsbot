# Description:
#   Let hubot help you brag about your awesome coworkers!
#
# Commands:
#   hubot brag @colleague Thanks for adding in bragging to hsbot


httpErrorBarks = [
  "I couldn't do that (sadpanda)",
  "Something bad happened",
  "I couldn't reach the Brag board, sorry (shrug)"
]

defaultBoard = "vb-test"

bragBoard = {
  "usn": "vishal.bardoloi@headspring.com",
  "pw" : "hello123!",
  "url": "http://test.brag.headspring.com/",
  "signin": "account/sign-in",
  "get": "api/boards/#{defaultBoard}/blocks?start=2015-06-14T00%3A00%3A00-05%3A00&end=2015-06-23T23%3A59%3A59-05%3A00"
}

loginData = {
  "email": bragBoard.usn,
  "password": bragBoard.pw
}

module.exports = (robot) ->

  signInUrl = "http://test.brag.headspring.com/account/sign-in"
  loginData = {"email": "vishal.bardoloi@headspring.com", "password": "hello123!", "time_zone_offset": "5"}
  theCookie = ""

  # hsbot brag <colleague> text-of-the-brag-here
  robot.respond /brag @([a-zA-Z0-9]+)? (.+)?/i, (msg) ->
    msg.http(signInUrl)
    .header("Content-Type", "application/json")
    .post(loginData) (err, res, body) ->

      console.log "step 2.1"
      if res.statusCode isnt 200
        console.log "step 2.2. Status code: " + res.statusCode                     
        console.log res.headers
        console.log "Houston, we have a problem"

      else
        console.log "Woohoo!"

        if "set-cookie" of res.headers and res.headers["set-cookie"].length > 0
          cookieStr = res.headers["set-cookie"][0].split("; ")
          theCookie = (x for x in cookieStr when x.slice(0, 12) is "connect.sid=")
          console.log theCookie
        else console.log "No cookie for you!"


    # login = new Promise((resolve, reject) ->
    #   console.log "step 2"
    #   msg.http(bragBoard.url + bragBoard.signin)
    #   .header("Content-Type", "application/json")
    #   .post(loginData) (err, res, body) ->

    #     console.log "step 2.1"
    #     if res.statusCode isnt 200
    #       console.log "step 2.2. Status code: " + res.statusCode                     
    #       reject "Whitney Houston, we have a problem"

    #     else
    #       console.log "Woohoo!"

    #       if "set-cookie" of res.headers and res.headers["set-cookie"].length > 0
    #         cookieStr = res.headers["set-cookie"][0].split("; ")
    #         theCookie = (x for x in cookieStr when x.slice(0, 12) is "connect.sid=")
    #         resolve theCookie
    #       else reject "No cookie for you!"
    # )

    # braggee = msg.match[1]
    # bragText = msg.match[2]
    # bragger = msg.message.user.name


    # console.log "step 1"
    # Promise.all([login])
    #   .then ->
    #     msg.http(bragBoard.url + bragBoard.get)
    #     .header("Accept", "application/json")
    #     .header("Content-Type", "text/html,application/json")
    #     .header("Cookie", theCookie)
    #     .get() (err, res, body) ->
    #       console.log "I got here, that's good"
    #   .catch (error) ->
    #     console.log "this is an exception: " + error




    








