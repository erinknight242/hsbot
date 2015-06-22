# Description:
#   Let hubot tell you about the office Jukebox.

# Commands:
#   hubot promise chaining commands together

request_payload = JSON.stringify({"jsonrpc": "2.0", "id": 1, "method": "{0}"})

get_mopidy_url = (office = "dallas") ->
  # todo: add other office urls when they come online; for now it's only Dallas
  process.env.HUBOT_JUKEBOX_DALLAS_URL or "http://localhost:6680/mopidy/rpc"

module.exports = (robot) ->
  robot.respond /promise[- ](.+)/i, (msg) ->
    artist = msg.match[1]
    artistBlank = JSON.stringify({"jsonrpc": "2.0", "id": 1, "method": "core.library.search", "params" : {"artist" : ["{0}"]}})
    getArtist = artistBlank.replace("{0}", artist)
    console.log getArtist

    getCurrent = request_payload.replace("{0}", "core.playback.get_current_tl_track")

    trackId = -1
    trackUris = []
    mopidy_url = "http://localhost:6680/mopidy/rpc"

    artistsTracks = new Promise((resolve, reject) ->
          msg.http(mopidy_url)
            .post(getArtist) (err, res, body) ->
              if res.statusCode isnt 200
                reject "Whitney Houston, we have a problem"
              else
                console.log "artistTracks"
                console.log body
                result = JSON.parse(body).result
                topTracks = result[0].tracks.slice(0,3)
                names = ( obj.name for obj in topTracks).join(", ")
                trackUris = (obj.uri for obj in topTracks);
                msg.send "I found these fine selections for " + artist
                msg.send names
                resolve trackUris
      )

    current = new Promise((resolve, reject) ->
          msg.http(mopidy_url)
            .post(getCurrent) (err, res, body) ->
             if res.statusCode isnt 200 or body.result is null
                reject "Ruh-roh raggy"
              else
                answer = JSON.parse(body)
                if answer.result is null
                  reject "Whitney Houston, we have a problem"
                  return 0
                else
                  trackId = parseInt(answer.result.tlid, 10)
                  resolve trackId
    )

    # historyCall = new Promise((resolve, reject) ->
    #   payload = request_payload.replace("{0}", "core.history.get_history")
    #   msg.http(mopidy_url)
    #   .post(payload) (err, res, body) ->
    #     if res.statusCode isnt 200
    #       reject "I couldn't get the history"
    #     else
    #       history = JSON.parse(body).result.slice(0,5)
    #       names = (obj[1].name for obj in history).join(", ")
    #       msg.send "Here are the last " + history.length + " songs"
    #       msg.send names
    #       resolve names
    # )

    Promise.all([artistsTracks, current])
      .then ->
        console.log "All calls completed"
        console.log "artistsTracks ==>"
        console.log trackUris
        console.log "current ==>"
        console.log trackId
        addRequest = {"jsonrpc": "2.0","id": 1,"method" : "core.tracklist.add","params":{"at_postion": trackId + 1, "uris": uris}}
        addMessage = JSON.stringify(addRequest)

        addCall = new Promise ((resolve, reject) ->
          msg.http(mopidy_url)
          .post(addMessage) (err, res, body) ->
            if res.statusCode isnt 200
              msg.send "That was a little embarassing, couldn't add tracks to the queue"
              reject "something baaaaad happened"
            else
              msg.send "those songs are up next in the queue"
              resolve "Situation nominal!"
        ).then ->
          console.log "add to queue finished"
