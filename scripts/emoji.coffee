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
    
    key = msg.message.text.match(/:+\w*:+/)[0].match(/[^:]\w*[^:]/).toString().toLowerCase();
    
    if textEmojis[key]
      msg.send textEmojis[key]
    else      
      msg.send 'http://givemeemoji.herokuapp.com/' + key
