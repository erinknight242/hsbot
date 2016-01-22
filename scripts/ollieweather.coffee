# Description:
#   ..and now lets go to Ollie Williams for our forecast
#
# Commands:
#   hubot weather - get your forecast
#   hubot houston weather - get your forecast for a specific city

austinId = 4671654
houstonId = 4699066
dallasId = 4684888
monterreyId = 3995465

apiKey = process.env.HUBOT_OPENWEATHERMAP_KEY

module.exports = (robot) ->
  robot.respond /(?:(austin|houston|dallas|monterrey)[- ])?weather([- ](.+))?/i, (msg) ->
    q =
      units: 'imperial'
      APPID: apiKey

    if msg.match[1] == 'dallas'
      q.id = dallasId
    else if msg.match[1] == 'houston'
      q.id = houstonId
    else if msg.match[1] == 'monterrey'
      q.id = monterreyId
    else
      q.id = austinId

    robot.http("http://api.openweathermap.org/data/2.5/forecast")
      .query(q)
      .get() (err, res, body) ->
        forecast = JSON.parse(body).list[0];
        main = forecast.weather[0].main;
        wind = forecast.wind.speed;

        if(main == 'Rain' && wind > 10)
          msg.send "(ollie) It's rainin sideways!";
        else if(main == 'Rain')
          msg.send "(ollie) It's gon rain";
        else
          msg.send main;
