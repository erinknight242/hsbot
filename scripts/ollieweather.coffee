# Description:
#   ..and now lets go to Ollie Williams for our forecast
#
# Commands:
#   hubot weather - get your forecast
#   hubot houston weather - get your forecast for a specific city

austinId = 4671654
houstonId = 4699066
dallasId = 4684888

module.exports = (robot) ->
  robot.respond /(?:(austin|houston|dallas)[- ])?weather([- ](.+))?/i, (msg) ->
    q = units: 'imperial'
    
    if msg.match[1] == 'dallas'
      q.id = dallasId
    else if msg.match[1] == 'houston'
      q.id = houstonId
    else
      q.id = austinId
    
    robot.http("http://api.openweathermap.org/data/2.5/forecast")
      .query(q)
      .get() (err, res, body) ->
        forecast = JSON.parse(body).list[0];
        main = forecast.weather[0].main;
        wind = forecast.wind.speed;
        
        if(main == 'Rain' && wind > 10)
          msg.send "It's rainin sideways!";
        else if(main == 'Rain')
          msg.send "It's gon rain";
        else
          msg.send main;
