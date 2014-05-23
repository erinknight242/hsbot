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
#   seanbiefeld

fs = require('fs');

`textEmojis = {
  finn: '| (•□•) |',
  jake: '(❍ᴥ❍ ʋ)'  
}`

module.exports = (robot) ->
  robot.respond /:+\w*:+/i, (msg) ->
    
    keys = msg.message.text.match(/:([a-zA-Z_0-9-]+):/gi)#[0].match(/[^:]\w*[^:]/).toString().toLowerCase()
    
    for key in keys
      strippedKey = key.match(/[^:][a-zA-Z_0-9-]+[^:]/).toString().toLowerCase()
      if textEmojis[strippedKey]
        msg.send textEmojis[strippedKey]
      else      
        msg.send 'http://givemeemoji.herokuapp.com/' + strippedKey
