# Description:
#   Let hubot flip stuff for you.
#
# Commands:
#   hubot flip X - hubot will flip X

flipChar = (cha) =>
  switch cha
    when 'a' then return '\u0250'
    when 'b' then return 'q'
    when 'c' then return '\u0254'
    when 'd' then return 'p'
    when 'e' then return '\u01DD'
    when 'f' then return '\u025F'
    when 'g' then return 'b'
    when 'h' then return '\u0265'
    when 'i' then return '\u0131'
    when 'j' then return '\u0638'
    when 'k' then return '\u029E'
    when 'l' then return '\u05DF'
    when 'm' then return '\u026F'
    when 'n' then return 'u'
    when 'o' then return 'o'
    when 'p' then return 'd'
    when 'q' then return 'b'
    when 'r' then return '\u0279'
    when 's' then return 's'
    when 't' then return '\u0287'
    when 'u' then return 'n'
    when 'v' then return '\u028C'
    when 'w' then return '\u028D'
    when 'x' then return 'x'
    when 'y' then return '\u028E'
    when 'z' then return 'z'
    when 'z' then return 'z'
    when '[' then return ']'
    when ']' then return '['
    when '(' then return ')'
    when ')' then return '('
    when '{' then return '}'
    when '}' then return '{'
    when '?' then return '\u00BF'
    when '\u00BF' then return '?'
    when "\'" then return ','
    when '.' then return '\u02D9'
    when '_' then return '\u203E'
    when ';' then return '\u061B'
    when '9' then return '6'
    when '6' then return '9'
    when '\u0250' then return 'a'
    when '\u0254' then return 'c'
    when '\u01DD' then return 'e'
    when '\u025F' then return 'f'
    when '\u0265' then return 'h'
    when '\u0131' then return 'i'
    when '\u0638' then return 'j'
    when '\u029E' then return 'k'
    when '\u05DF' then return 'l'
    when '\u026F' then return 'm'
    when '\u0279' then return 'r'
    when '\u0287' then return 't'
    when '\u028C' then return 'v'
    when '\u028D' then return 'w'
    when '\u028E' then return 'y'
    when ',' then return "\'"
    when '\u02D9' then return '.'
    when '\u203E' then return '_'
    when '\u061B' then return ';'
    else return cha

module.exports = (robot) ->
  robot.respond /flip(.+)?/i, (msg) ->
    flipee = msg.match[1];
    flipped = ""
    for cha in flipee by -1 then do (cha) =>
      flipped = flipped + flipChar(cha)
    msg.send "(╯°□°）╯︵" + flipped