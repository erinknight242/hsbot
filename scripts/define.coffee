# Description:
#   Get the definition of a word
#
# Commands:
#   hubot define <text> - Replies with definition and pronounciation

_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require("htmlparser")

module.exports = (robot) ->
  robot.respond /DEFINE (.*)$/i, (msg) ->
    word = msg.match[1]
    url = "http://simpledefine.com/#{word}"
    robot.http(url)
      .get() (err, res, body) ->
        
        lists = parseHTML(body, "ul")

        if lists.length > 0
          title = parseHTML(body, "h1")[0].children[0].raw + '\n'
          pronounce = parseHTML(body, "h2")[0].children[0].raw + '\n'
          msg.send title + pronounce + getDefinitions(lists)
          msg.send url
        else
          msg.send 'I know nothing about ' + word

parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector

childrenOfType = (root, nodeType) ->
  return [root] if root?.type is nodeType

  if root?.children?.length > 0
    return (childrenOfType(child, nodeType) for child in root.children)

  []

getDefinitions = (paragraphs) ->
  return null if paragraphs.length is 0

  children = _.flatten childrenOfType(paragraphs[0], 'text')

  text = (textNode.data for textNode in children).join '\n'
  text = _s.unescapeHTML(text)
