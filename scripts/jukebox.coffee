# Description:
#   Let hubot tell you about the office Jukebox.
#
# Commands:
#   hubot dallas what's playing - what's on the jukebox right now
#   hubot dallas pause music - pause playback
#   hubot dallas resume music - resume playback
#   hubot dallas next song|track - skip to next track
#   hubot dallas history - list the last 5 tracks played
#   hubot dallas shuffle music - shuffle the songs in the current queue
#   hubot dallas search|find|artist|play (some) <artist> - add tracks by artist to the bottom of the queue

httpErrorBarks = [
  "I couldn't do that (sadpanda)",
  "Something bad happened",
  "I couldn't reach the Jukebox, sorry (shrug)"
]

dataErrorBarks = [
  "Whitney Houston, we have a problem",
  "Ruh-roh raggy",
  "Task failed successfully"
]

defaultOffice = "dallas"

getRequestJson = (method = undefined, params = undefined) ->
  requestJson = {"jsonrpc": "2.0", "id": 1, "method": method, "params": params}
  JSON.stringify(requestJson)

getMopidyUrl = (office = defaultOffice) ->
  switch office.toLowerCase()
    # todo: add other office urls when they come online; for now it's only Dallas
    when "dallas" then process.env.HUBOT_JUKEBOX_DALLAS_URL or "http://localhost:6680/mopidy/rpc"
    else process.env.HUBOT_JUKEBOX_DALLAS_URL

getArtistsNames = (track) ->
  (artist.name for artist in track.artists).reduce (x, y) -> x + ', ' + y


module.exports = (robot) ->

  # error handling
  robot.error (err, res) ->
    robot.logger.error "Jukebox choked on #{err}"  

    if res?
      res.reply "Jukebox could not compute"

  # error checking
  foundErrors = (err, res) ->
    if err          
      robot.emit 'error', err, res
      return true

    if res? and res.statusCode isnt 200
      res.send "Got an HTTP #{res.statusCode} error."
      return true

    return false


  getCurrentTrackTlid = (mopidyUrl, msg) ->
    data = getRequestJson("core.playback.get_current_tl_track")

    msg.http(mopidyUrl)
      .post(data) (err, res, body) ->

        if foundErrors(err, res) 
          msg.send msg.random httpErrorBarks
          return

        answer = JSON.parse(body)

        return if answer.result is null then 0 else parseInt(answer.tlid, 10)


  # hsbot <office> what's playing?
  robot.respond /(?:(austin|houston|dallas)[ ])?what[']?s playing([- ](.+))?/i, (msg) ->
    office = msg.match[1] or defaultOffice
    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.playback.get_current_tl_track")
  
    msg.http(mopidyUrl)
      .post(data) (err, res, body) ->

        if foundErrors(err, res) 
          msg.send msg.random httpErrorBarks
          return

        try 
          tlTrack = JSON.parse(body).result
          msg.send "#{tlTrack.track.name} by #{getArtistsNames(tlTrack.track)} is playing right now"
        catch error
          msg.send msg.random dataErrorBarks
          return

  # hsbot <office> pause music
  robot.respond /(?:(austin|houston|dallas)[ ])?pause music/i, (msg) ->
    office = msg.match[1] or defaultOffice
    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.playback.pause")

    msg.http(mopidyUrl)
      .post(data) (err, res, body) ->

        if foundErrors(err, res) 
          msg.send msg.random httpErrorBarks
          return

        msg.send "#{office} jukebox paused."


  # hsbot <office> resume music
  robot.respond /(?:(austin|houston|dallas)[ ])?resume music/i, (msg) ->
    office = msg.match[1] or defaultOffice
    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.playback.resume")

    msg.http(mopidyUrl)
      .post(data) (err, res, body) ->

        if foundErrors(err, res) 
          msg.send msg.random httpErrorBarks
          return

        msg.send "#{office} jukebox resumed."


  # hsbot <office> next song
  # hsbot <office> next track
  robot.respond /(?:(austin|houston|dallas)[ ])?next (song|track)/i, (msg) ->
    office = msg.match[1] or defaultOffice
    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.playback.next")

    msg.http(mopidyUrl)
      .post(data) (err, res, body) ->

        if foundErrors(err, res) 
          msg.send msg.random httpErrorBarks
          return

        msg.send "Next song playing on #{office} jukebox."


  # hsbot <office> shuffle music
  robot.respond /(?:(austin|houston|dallas)[ ])?shuffle music([- ](.+))?/i, (msg) ->
    office = msg.match[1] or defaultOffice
    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.tracklist.shuffle")

    msg.http(mopidyUrl)
    .post(data) (err, res, body) ->

      if foundErrors(err, res) 
        msg.send msg.random httpErrorBarks
        return

      msg.send "I shook things up (awyeah)"


  # hsbot <office> history
  robot.respond /(?:(austin|houston|dallas)[ ])?history/i, (msg) ->
    office = msg.match[1] or defaultOffice
    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.history.get_history")

    msg.http(mopidyUrl)
    .post(data) (err, res, body) ->

      if foundErrors(err, res) 
        msg.send msg.random httpErrorBarks
        return

      try 
        history = JSON.parse(body).result.slice(0, 5)

        if history.length == 0
          msg.send "No track history found."
          return

        names = (obj[1].name for obj in history).join(", ")
        msg.send "Here are the last " + history.length + " songs:"
        msg.send names
      catch error
        msg.send msg.random dataErrorBarks
        return


  # hsbot <office> search michael jackson
  # hsbot <office> find michael jackson
  # hsbot <office> artist michael jackson
  # hsbot <office> play michael jackson
  # hsbot <office> play some michael jackson
  robot.respond /(?:(austin|houston|dallas)[ ])?(search|find|artist|play( some)?)[ ](.+)/i, (msg) ->
    office = msg.match[1] or defaultOffice
    searchToken = msg.match[4]

    if !searchToken
      msg.send "Which artist was that again?"
      return

    mopidyUrl = getMopidyUrl(office)
    data = getRequestJson("core.library.search", {"artist": [searchToken]})

    msg.send "Seeing what I can find for " + searchToken

    msg.http(mopidyUrl)
      .post(data) (err, res, body) ->

        if foundErrors(err, res) 
          msg.send msg.random httpErrorBarks
          return

        atPosition = 0
        uris = []

        try 
          resultsFromAllBackends = JSON.parse(body).result
          tracks = (result.tracks for result in resultsFromAllBackends when 'tracks' of result) #remove empty results
                    .reduce (x, y) -> [x..., y...] # join the track arrays into one

          # topTracks = (track for track in tracks when getArtistsNames(track).toLowerCase.match searchToken)
          topTracks = tracks[0...3]

          if topTracks.length == 0
            msg.send "Found no matching tracks."
            return

          names = ("#{track.name} by #{getArtistsNames(track)}" for track in topTracks).join(", ")
          msg.send "I found these fine selections for #{searchToken}:"
          msg.send names

          uris = (track.uri for track in topTracks)

        catch error
          msg.send msg.random dataErrorBarks
          return

        addRequest = getRequestJson("core.tracklist.add", {"uris": uris})

        msg.http(mopidyUrl)
          .post(addRequest) (err, res, body) ->

            if foundErrors(err, res) 
              msg.send msg.random httpErrorBarks
              return

            msg.send "Those songs have been added to the bottom of the queue"


