# Description:
# unicode emoticons  
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot _smiley
#      outputs: ☺
#
# Notes:
#   unicode emoticons from http://unicodeemoticons.com/
#
# Author:
#   seanbiefeld

`unicodeemoticons = {
  a: '65',
  smiley: '1F600',
  house: '1f3e0'
}`

module.exports = (robot) ->
  robot.respond /_+\w*_+/i, (msg) ->
    description = msg.message.text.match(/_+\w*_+/)[0].match(/[^_]\w*[^_]/).toString().toLowerCase();
    chars = []
    charValue = parseInt(unicodeemoticons[description], 16)
    if (charValue < 0x10000)
      chars.push(String.fromCharCode(charValue));
    else
      high = Math.floor((charValue - 0x10000) / 0x400) + 0xD800
      low = (charValue - 0x10000) % 0x400 + 0xDC00
      chars.push(String.fromCharCode(high, low))
    msg.send chars