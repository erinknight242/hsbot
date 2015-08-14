# Description:
#   Fetch the 'Back to School' theme scores.
#
# Commands:
#   hubot scores
_ = require 'underscore'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.respond /scores/ig, (msg) ->
    robot.http('https://docs.google.com/spreadsheets/d/1IwuxivCUKUdTq-lkY81wmRvtLIiTvrvfcMz734Akq1A/pub?gid=257855949&alt=html')
      .get() (err, res, body) ->
        [$, teams] = [cheerio.load(body), [{ },{ },{ },{ }]]
        for cell, index in $('td')
          team = teams[index % teams.length]
          team[if index < teams.length then 'name' else 'score'] = cell?.children?[0]?.data
        ranks = _.map(_.sortBy(teams, (t) -> -t.score), (t, i) -> "#{i}. #{t.name}: #{t.score}")
        ranks[0] = 'Current Back to School Scores:'
        msg.send ranks.join('\r\n')
