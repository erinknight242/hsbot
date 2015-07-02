# Description:
#   Let hubot help you nominate coworkers.
#
# Commands:
#   hubot brag on <coworker> [because] <reason>
#   hubot nominate <coworker> [for] <awardType> [because] <reason>

defaultNominationType = "brag"
errorBarks = [
  "My time circuits must be shorting out, I couldn't do that (sadpanda), please don't let me get struck by lightning (build)",
  "What you requested should have worked, BUT it didn't (shrug)",
  "Bad news: it didn't work (boom); good news: I'm alive! I'm alive! (awesome) Wait, no...that is Johhny # 5, there is no good news (evilburns)"
]
jiraBaseUrl = "https://headspring.atlassian.net/rest/api/2/"
authToken = "Basic #{process.env.HUBOT_JIRA_AUTH}"

getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

getIssueType = (nomType) ->
  switch nomType.toLowerCase()
    when "hva" then { "id": "11303" }
    else { "id": "11304" }

getRequestJson = (nominee, description, nominationType, awardType) ->
  issueType = getIssueType(nominationType)
  requestJson = {
    "fields": {
       "project": { "key": "NOMTEST", "id": "14700" },
       "issuetype": issueType,
       "customfield_12100": { "name": nominee },
       "description": description,
       "summary": "this brag was automagically created by hsbot"
    }
  }
  if awardType?
    requestJson.fields.awardType = awardType 
  JSON.stringify(requestJson)

module.exports = (robot) ->
  # error checking
  foundErrors = (err, res) ->
    if err          
      robot.emit 'error', err, res
      return true
    console.log(res.statusCode)
    if res? and (res.statusCode > 201 or res.statusCode < 200)
      robot.emit "Got an HTTP #{res.statusCode} error."
      return true
    return false

  robot.hear /brag (on )?(@)?([a-zA-Z0-9]+)? (because )?(.+)?/i, (msg) ->
    console.log("robot name: " + robot.name)
    sender = msg.message.user.name.toLowerCase()
    console.log("sender: " + sender)
    usedAtMention = msg.match[2] == '@'
    console.log("usedAtMention: " + usedAtMention)
    colleagueName = msg.match[3].toLowerCase()
    console.log("colleagueName: " + colleagueName)
    reason = msg.match[5]
    console.log("reason: " + reason)

    if colleagueName is robot.name
      msg.send "(embarrassed) Honored, truly, but an Artificial Inteligence does not have a desk to put the award on"
      return

    if usedAtMention
      console.log("used the @ mention, trying to locate userName and emailAddress")
      for userId, user of robot.brain.users()
        #console.log("user in brain: " + JSON.stringify(user))
        if user.mention_name.toLowerCase()==colleagueName
          console.log("found mentioned user: " + JSON.stringify(user))
          userName = user.name.toLowerCase()
          emailAddress = user.email_address.toLowerCase()
          console.log("userName: #{userName}, email: #{emailAddress}")
    else
      matchingUsers = robot.brain.usersForFuzzyName(colleagueName)
      if not matchingUsers?
        msg.send "#{colleagueName}? Never heard of 'em, cannot nominate"
        return
      if matchingUsers.length != 1
        msg.send getAmbiguousUserText matchingUsers
        return
      else
        console.log("found fuzzy user: " + JSON.stringify(matchingUsers[0]))
        userName = matchingUsers[0].name.toLowerCase()
        emailAddress = matchingUsers[0].email_address.toLowerCase()
        console.log("userName: #{userName}, email: #{emailAddress}")
    if not userName?
      msg.send "Could not locate a valid user name for #{colleagueName}, cannot nominate"
      return
    if sender == userName
      msg.send "(disapproval) nominating yourself is not allowed!"
      return
    if not emailAddress?
      msg.send "Could not locate a valid email address for #{colleagueName}, cannot nominate"
      return

    jiraUserUrl = jiraBaseUrl + "user/picker"
    q = query: emailAddress
    msg.http(jiraUserUrl)
      .query(q)
      .header("Authorization", authToken)
      .get() (err, res, body) ->
        if foundErrors(err, res)
          msg.send msg.random errorBarks
          return
        result = JSON.parse(body)
        if not result? or not result.users? or result.users.length == 0
          msg.send "#{colleagueName}? JIRA doesn't have record of 'em, cannot nominate"
          return
        else if result.users.length != 1
          msg.send "JIRA found more than one #{colleagueName}?! Please be more spcific for nomination"
          return
        
        console.log("woot, found the user in JIRA: " + JSON.stringify(result.users[0]))
        requestJson = getRequestJson(result.users[0].name, reason, "brag", null)
        console.log("requestJson: " + JSON.stringify(requestJson))

        jiraIssueUrl = jiraBaseUrl + "issue"
        msg.http(jiraIssueUrl)
          .header("Authorization", authToken)
          .header("Content-Type", "application/json")
          .post(requestJson) (err, res, body) ->
            if foundErrors(err, res)
              msg.send msg.random errorBarks
              return
            console.log("body after create: " + body)
            msg.send "Your brag for #{colleagueName} was successfuly retreived and processed!"


