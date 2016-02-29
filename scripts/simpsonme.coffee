# Description:
#   Utilizing frinkiac.com, to serve up everyones simpson image needs
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hsbot simpson me ___ - Get a simpsons image related to the quote you passed it
#
# Example:
#   hsbot simpson me where's the any key

module.exports = (robot) ->
  robot.respond /(simpson me) (.*)$/i, (msg) ->
    phrase = msg.match[2]
    phrase = phrase.replace(" ","+")
    url = "https://frinkiac.com/api/search?q=#{phrase}"
    robot.http(url)
      .get() (err, res, body) ->
          list = JSON.parse(body)

          if(list.length > 0)
            selectedImage = list[0]
            episode = selectedImage.Episode
            timestamp = selectedImage.Timestamp
            url = "http://frinkiac.com/img/#{episode}/#{timestamp}.jpg"
            msg.send url
          else
            msg.send "(doh) no images fit that quote"
