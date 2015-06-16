# Description:
#   Let hubot tell you about the office Jukebox.
#
# Commands:
#   hubot dallas whats playing - what's on the jukebox right now

mopidy_url = "http://localhost:6680/mopidy/rpc"

payload = JSON.stringify({"jsonrpc": "2.0", "id": 1, "method": "core.playback.get_current_track"})

module.exports = (robot) ->
  robot.respond /(?:(austin|houston|dallas)[- ])?whats playing([- ](.+))?/i, (msg) ->
    msg.http(mopidy_url)
      .post(payload) (err, res, body) ->
        song = JSON.parse(body).result.name;
        if song.length == 0
          msg.send "I can't tell what's playing on the Jukebox. (shrug)"
        else
          msg.send song
