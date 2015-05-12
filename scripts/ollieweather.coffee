# Description:
#   Let hubot tell you where to go for lunch.
#
# Commands:
#   hubot lunch me - find a place to eat
#   hubot lunch me tacos - find what you are in the mood for
#   hubot houston lunch me - find a place in Houston, too!

austinId = 4671654
houstonId = 4699066
dallasId = 4684888

barks = [
  "How about {0}?",
  "Are you in the mood for {0}?",
  "When's the last time you had {0}?",
  "If I were not an artificial intellegence, I would eat at {0}.",
  "You should get {0}. (awyeah)",
  "Perhaps you would like something from {0}.",
  "Have you ever tried {0}?"
]

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
