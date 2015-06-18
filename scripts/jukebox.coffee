# Description:
#   Let hubot tell you about the office Jukebox.
#
# Commands:
#   hubot dallas whats playing - what's on the jukebox right now
#   hubot dallas pause music - pause playback
#   hubot dallas resume music - resume playback
#   hubot dallas play next - skip to next track
#   hubot dallas history - list the last 5 tracks played
#   hubot dallas shuffle - shuffle the songs in the current queue
#   hubot dallas search|find|artist <artist> add tracks by artist to the bottom of the queue

request_payload = JSON.stringify({"jsonrpc": "2.0", "id": 1, "method": "{0}"})

get_mopidy_url = (office = "dallas") ->
  # todo: add other office urls when they come online; for now it's only Dallas
  process.env.HUBOT_JUKEBOX_DALLAS_URL or "http://localhost:6680/mopidy/rpc"

get_current_tl_trackId = (mopidy_url, msg) ->
  console.log "get tl track"
  data = request_payload.replace("{0}", "core.playback.get_current_tl_track")
  msg.http(mopidy_url)
  .post(data) (err, res, body) ->
   if res.statusCode isnt 200 or body.result is null
      msg.send "Ruh-roh raggy"
    else
      answer = JSON.parse(body)
      console.log answer
      if answer.result is null
        console.log 'get_current_tl_track returned a null'
        return 0
      else
        trackId = parseInt(answer.tlid, 10) is 10
        console.log 'trackId ' & trackId
        return trackId

module.exports = (robot) ->
  robot.respond /(?:(austin|houston|dallas)[- ])?what[']?s playing([- ](.+))?/i, (msg) ->
    mopidy_url = get_mopidy_url(msg.match[1])
    data = request_payload.replace("{0}", "core.playback.get_current_tl_track")

    msg.http(mopidy_url)
      .post(data) (err, res, body) ->
        tl_track = JSON.parse(body).result

        if tl_track.length == 0
          msg.send "I can't tell what's playing on the Jukebox. (shrug)"
          return
        artist_names = (artist.name for artist in tl_track.track.artists)
        msg.send "Now playing #{tl_track.track.name} by #{artist_names.reduce (x, y) -> x + ', ' + y}"


  robot.respond /(?:(austin|houston|dallas)[- ])?pause music/i, (msg) ->
    office = msg.match[1]
    mopidy_url = get_mopidy_url(office)
    data = request_payload.replace("{0}", "core.playback.pause")

    msg.http(mopidy_url)
      .post(data) (err, res, body) ->
        if res.statusCode isnt 200
          msg.send "I can't pause the #{office} jukebox. (shrug)"

        msg.send "#{office} jukebox paused."


  robot.respond /(?:(austin|houston|dallas)[- ])?resume music/i, (msg) ->
    office = msg.match[1]
    mopidy_url = get_mopidy_url(office)
    data = request_payload.replace("{0}", "core.playback.resume")

    msg.http(mopidy_url)
      .post(data) (err, res, body) ->
        if res.statusCode isnt 200
          msg.send "I can't resume the #{office} jukebox. (shrug)"

        msg.send "#{office} jukebox resumed."


  robot.respond /(?:(austin|houston|dallas)[- ])?play next/i, (msg) ->
    office = msg.match[1]
    mopidy_url = get_mopidy_url(office)
    data = request_payload.replace("{0}", "core.playback.next")

    msg.http(mopidy_url)
      .post(data) (err, res, body) ->
        if res.statusCode isnt 200
          msg.send "I can't play next on the #{office} jukebox. (shrug)"

        msg.send "Next song playing on #{office} jukebox."

  robot.respond /(?:(austin|houston|dallas)[- ])?shuffle([- ](.+))?/i, (msg) ->
    office = msg.match[1]
    mopidy_url = get_mopidy_url(office)
    data = request_payload.replace("{0}", "core.tracklist.shuffle")

    msg.http(mopidy_url)
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "I couldn't shake things up"
      else
        msg.send "I shook things up"

  robot.respond /(?:(austin|houston|dallas)[- ])?history/i, (msg) ->
    office = msg.match[1]
    mopidy_url = get_mopidy_url(office)
    data = request_payload.replace("{0}", "core.tracklist.get_tracks")

    msg.http(mopidy_url)
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "I couldn't get the history"
      else
        history = JSON.parse(body).result.slice(0,5)
        names = ( obj.name for obj in history).join(", ")
        msg.send "Here are the last " + history.length + " songs"
        msg.send names

  robot.respond /(?:(austin|houston|dallas)[- ])?(search|find|artist)[- ](.+)/i, (msg) ->
    msg.send "search"
    office = msg.match[1]
    verb = msg.match[2]
    artist = msg.match[3]
    mopidy_url = get_mopidy_url(office)
    dataBlank = JSON.stringify({"jsonrpc": "2.0", "id": 1, "method": "core.library.search", "params" : {"artist" : ["{0}"]}})
    data = dataBlank.replace("{0}", artist)
    uris =[]
    atPosition = 0
    msg.send "Seeing what I can dig up for " + artist


    msg.http(mopidy_url)
      .post(data) (err, res, body) ->
        if res.statusCode isnt 200
          msg.send "Houston, we have a problem"
        else
          result = JSON.parse(body).result
          topTracks = result[0].tracks.slice(0,3)
          names = ( obj.name for obj in topTracks).join(", ")
          uris = (obj.uri for obj in topTracks);
          msg.send "I found these fine selections for " + artist
          msg.send names

        addRequest = {"jsonrpc": "2.0","id": 1,"method" : "core.tracklist.add","params":{"uris": uris}}
        addMessage = JSON.stringify(addRequest)

        msg.http(mopidy_url)
        .post(addMessage) (err, res, body) ->
          if res.statusCode isnt 200
            msg.send "That was a little embarassing, couldn't add tracks to the queue"
          else
            msg.send "those songs are up next in the queue"
