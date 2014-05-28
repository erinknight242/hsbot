# Description:
# more emoticons  
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot :house:
#      => house.png
#
# Notes:
#   emoticons from http://www.emoji-cheat-sheet.com/
#
# Author:
#   Sean G. BSiefeld

fs = require('fs');

`textEmojis = {
  finn: '| (•□•) |',
  jake: '(❍ᴥ❍ ʋ)',
  smiling: '(ʘ‿ʘ)',
  disapprove: '(ಠ_ಠ)',
  "devious-smile": '(ಠ⌣ಠ)',
  devious: '(ಠ‿ಠ)',
  crying: '(ಥ﹏ಥ)',
  raging: 'ლ(ಠ益ಠლ)',
  "eye-rolling": '◔̯◔',
  shrugging: '¯\\(°_o)/¯'
}`

module.exports = (robot) ->

  robot.respond /emoji help$/i, (msg) ->
    msg.send "http://givemeemoji.herokuapp.com/help/"

  robot.respond /:+\w*:+/i, (msg) ->
    
    keys = msg.message.text.match(/:([a-zA-Z_0-9-]+):/gi)
    
    for key in keys
      strippedKey = key.match(/[^:][a-zA-Z_0-9-]+[^:]/).toString().toLowerCase()
      if textEmojis[strippedKey]
        msg.send textEmojis[strippedKey]
      else      
        msg.send 'http://givemeemoji.herokuapp.com/' + strippedKey
