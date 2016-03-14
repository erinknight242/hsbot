# Description:
#   Get a stock price
#   Will automatically post the Dow Jones market close in the HipChat Stocks room
#
# Dependencies:
#   node-schedule
#
# Configuration:
#   None
#
# Commands:
#   hsbot stock [info|quote|price] [for|me] <ticker> [1d|5d|2w|1mon|1y] - Get a stock price
#
# Author:
#   eliperkins
#   maddox
#   johnwyles
#   danmalagari

schedule = require('node-schedule')

# Set the scheduled job to only run during weekdays, at market close
rule = new schedule.RecurrenceRule()
rule.dayOfWeek = [new schedule.Range(1,5)]
rule.hour = 20
rule.minute = 16

module.exports = (robot) ->
  robot.respond /stock (?:info|price|quote)?\s?(?:for|me)?\s?@?([A-Za-z0-9.-_]+)\s?(\d+\w+)?/i, (msg) ->
    ticker = escape(msg.match[1])
    time = msg.match[2] || '1d'
    msg.http('http://finance.google.com/finance/info?client=ig&q=' + ticker)
    .get() (err, res, body) ->
      result = JSON.parse(body.replace(/\/\/ /, ''))
      msg.send "http://chart.finance.yahoo.com/z?s=#{ticker}&t=#{time}&q=l&l=on&z=l&a=v&p=s&lang=en-US&region=US#.png"
      msg.send result[0].l_cur + " (#{result[0].c})"

  marketClose = schedule.scheduleJob(rule, ->
    robot.http('http://finance.google.com/finance/info?client=ig&q=.DJI')
      .get() (err, res, body) ->
        result = JSON.parse(body.replace(/\/\/ /, ''))
        robot.messageRoom process.env.HUBOT_ROOM_STOCKS, "http://chart.finance.yahoo.com/z?s=^DJI&t=1d&q=l&l=on&z=l&a=v&p=s&lang=en-US&region=US#.png"
        robot.messageRoom process.env.HUBOT_ROOM_STOCKS, "Market closed! " + result[0].l_cur + " (#{result[0].c})"
  )
