# Description:
#   Generate past HVA statistics to help the selection committee when selecting
#   new award recipients
#
# Commands:
#   hsbot hva info || hsbot hva info Q1 2017

moment = require('moment-timezone')

jiraBaseUrl = "https://headspring.atlassian.net/rest/api/2/"
jiraAuthToken = "Basic #{process.env.HUBOT_JIRA_AUTH}"

getSearchRequestJson = (nominee) ->
  requestJson = {
    "jql": "project = HVA AND issuetype = \"Headspring Value Award Nomination\" AND status in (Awarded, Acknowledged) AND Nominee in (" + nominee + ") ORDER BY created DESC"
  }
  JSON.stringify(requestJson)

getStartDate = (quarter, year) ->
  startDate = switch
    when quarter == '1' then year + '-01-01'
    when quarter == '2' then year + '-04-01'
    when quarter == '3' then year + '-07-01'
    when quarter == '4' then year + '-10-01'

getEndDate = (quarter, year) ->
  endDate = switch
    when quarter == '1' then year + '-03-31'
    when quarter == '2' then year + '-06-30'
    when quarter == '3' then year + '-09-30'
    when quarter == '4' then year + '-12-31'

getNominationsJson = (quarter, year) ->
  requestJson = {
    "jql": "project = HVA AND issuetype = \"Headspring Value Award Nomination\" AND status in (\"Current Nomination\", Awarded, Acknowledged) AND created >= " + getStartDate(quarter, year) + " AND created <= " + getEndDate(quarter, year) + " ORDER BY created DESC"
  }
  JSON.stringify(requestJson)

module.exports = (robot) ->
  foundErrors = (err, res) ->
    if err
      robot.emit 'error', err, res
      return true
    if res? and (res.statusCode > 204 or res.statusCode < 200)
      robot.emit "Got an HTTP #{res.statusCode} error."
      console.log("Got an HTTP #{res.statusCode} error.")
      return true
    return false

  robot.respond /hva info( q)?(?:(1|2|3|4)[ ]?)?(\d*)/i, (msg) ->
    quarter = msg.match[2]
    year = msg.match[3]
    if !(quarter && year)
      today = new Date()
      month = today.getMonth()
      year = today.getFullYear()
      if month < 3
        quarter = '4'
        year -= 1
      else if month < 6
        quarter = '1'
      else if month < 9
        quarter = '2'
      else
        quarter = '3'

    # Get the list of nominations for the specified quarter and year
    requestJson = getNominationsJson(quarter, year)
    msg.http(jiraBaseUrl + 'search')
      .header("Authorization", jiraAuthToken)
      .header("Content-Type", "application/json")
      .post(requestJson) (err, res, body) ->
        if foundErrors(err, res)
          msg.send err
        jiraResult = JSON.parse(body)
        msg.send jiraResult.total + ' HVA nominations in Q' + quarter + ' ' + year
        nominations = jiraResult.issues

        msg.send "Nominees:"
        for nomination in nominations
          # Query each nomination for additional details
          msg.http(jiraBaseUrl + 'issue/' + nomination.id)
            .header("Authorization", jiraAuthToken)
            .get() (err, res, body) ->
              if foundErrors(err, res)
                msg.send err
              jiraResult = JSON.parse(body)
              name = jiraResult.fields.customfield_12100.name
              value = jiraResult.fields.customfield_12101.value
              date = moment(jiraResult.fields.created).format('l')
              description = jiraResult.fields.description
              # Query this person's past nominations
              historyRequestJson = getSearchRequestJson(name)
              msg.http(jiraBaseUrl + 'search')
                .header("Authorization", jiraAuthToken)
                .header("Content-Type", "application/json")
                .post(historyRequestJson) (err, res, body) ->
                  if foundErrors(err, res)
                    msg.send err
                  jiraResult = JSON.parse(body)
                  awarded = 0
                  for previousAward in jiraResult.issues
                    # Count the awarded nominations
                    if previousAward.fields.status.name == 'Awarded' then awarded++
                  msg.send '\n' + name + ' - ' + date + ' - Nominated for ' + value
                  msg.send '\n' + description
                  plural = if jiraResult.total != 1 then 's' else ''
                  msg.send '\nPreviously nominated for ' + jiraResult.total + ' HVA' + plural + ', and received ' + awarded + '.'
                  for previousAward in jiraResult.issues
                    # Log each previous nomination details
                    awardedLabel = if previousAward.fields.status.name == 'Awarded' then '**Awarded**' else ''
                    msg.send '\t- ' + moment(previousAward.fields.created).format('l') + ' ' + previousAward.fields.customfield_12101.value + ' ' + awardedLabel
                  msg.send '----------------------------------------------------------'
