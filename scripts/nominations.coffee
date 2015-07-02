# Description:
#   Let hubot help you nominate coworkers.
#
# Commands:
#   hubot brag on <coworker> [because] <reason>
#   hubot nominate <coworker> [for] <awardType> [because] <reason>

bragHelpText = "/quote example: hsbot brag [on] [@]coworker [because] reason\nrules:\tcoworker and reason are required\n\t[on] [@] or [because] are optional"
nominateHelpText = "/quote example: hsbot nominate [@]coworker for awardAcronym [because] reason\nrules:\tcoworker, awardAcronym and reason are required\n\awardAcronym must be one of:\n\t\tDFE (Drive for Excellence)\tPAV (People are Valued)\n\t\tCOM (Honest Communication)\tPLG (Passion for Learning and Growth)\n\t[@] or [because] are optional"

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

getAwardTypeFromAcronym =  (acronym) ->
  switch acronym.toLowerCase()
    when "dfe" then "Drive for Excellence"
    when "pav" then "People are Valued"
    when "com" then "Honest Communication"
    when "plg" then "Passion for Learning and Growth"
    else null

getRequestJson = (nominator, nominee, description, nominationType, awardType) ->
  issueType = getIssueType(nominationType)
  requestJson = {
    "fields": {
       "project": { "key": "NOM", "id": "14701" }
       "issuetype": issueType,
       "customfield_12100": { "name": nominee },
       "description": description,
       "summary": "this #{nominationType} was automagically created by hsbot",
       "reporter": {"name": nominator }
    }
  }
  if awardType?
    requestJson.fields.customfield_12101 = { "value": getAwardTypeFromAcronym(awardType) }
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
      console.log("Got an HTTP #{res.statusCode} error.")
      return true
    return false

  isNomineeRobot = (nominee) ->
    return nominee.toLowerCase() is robot.name.toLowerCase()

  isNomineeSelf = (nominee, self) ->
    return nominee.toLowerCase() is self.toLowerCase()

  getEmployeeByMention = (mentionName) ->
    for userId, user of robot.brain.users()
      if user.mention_name? and user.mention_name.toLowerCase()==mentionName.toLowerCase()
        console.log("found mentioned user: " + JSON.stringify(user))
        userName = user.name.toLowerCase()
        emailAddress = user.email_address.toLowerCase()
        console.log("userName: #{userName}, email: #{emailAddress}")
        return { "userName": userName, "emailAddress": emailAddress }
    return

  getEmployeeByName = (fuzzyName) ->
    matchingUsers = robot.brain.usersForFuzzyName(fuzzyName)
    if not matchingUsers?
      return { "error": "#{fuzzyName}? Never heard of 'em, cannot nominate" }
    
    if matchingUsers.length != 1
      return { "error": getAmbiguousUserText(matchingUsers) }
    
    console.log("found fuzzy user: " + JSON.stringify(matchingUsers[0]))
    userName = matchingUsers[0].name.toLowerCase()
    emailAddress = matchingUsers[0].email_address.toLowerCase()
    console.log("userName: #{userName}, email: #{emailAddress}")
    return { "userName": userName, "emailAddress": emailAddress }

  parseJiraUser = (err, res, body) ->
    if foundErrors(err, res)
      return { "error": errorBarks }
    result = JSON.parse(body)
    if not result? or not result.users? or result.users.length == 0
      return { "error": "#{colleagueName}? JIRA doesn't have record of 'em, cannot nominate" }
    if result.users.length != 1
      return { "error": "JIRA found more than one #{colleagueName}?! Please be more spcific for nomination" }
    console.log("woot, found the user in JIRA: " + JSON.stringify(result.users[0]))
    return result.users[0]

  robot.respond /brag help$/i, (msg) ->
    msg.send bragHelpText

  robot.respond /nominate help$/i, (msg) ->
    msg.send nominateHelpText

  robot.hear /brag (on )?(@)?([a-zA-Z0-9]+)? (because |for )?(.+)?/i, (msg) ->
    console.log("robot name: " + robot.name)
    sender = msg.message.user.name
    console.log("sender: " + sender)
    usedAtMention = msg.match[2] == '@'
    console.log("usedAtMention: " + usedAtMention)
    colleagueName = msg.match[3]
    console.log("colleagueName: " + colleagueName)
    reason = msg.match[5]
    console.log("reason: " + reason)

    if isNomineeRobot(colleagueName)
      msg.send "(embarrassed) Honored, truly, but an Artificial Inteligence does not need your bragging"
      return

    if usedAtMention
      console.log("used the @ mention, trying to locate userName and emailAddress")
      nominee = getEmployeeByMention(colleagueName)

    if not nominee?
      nominee = getEmployeeByName(colleagueName)
      if nominee.error?
        msg.send nominee.error
        return
    
    if not nominee.userName?
      msg.send "Could not locate a valid user name for #{colleagueName}, cannot brag"
      return
    if isNomineeSelf(nominee.userName, sender)
      msg.send "(disapproval) bragging on yourself is not allowed!"
      return
    if not nominee.emailAddress?
      msg.send "Could not locate a valid email address for #{colleagueName}, cannot brag"
      return

    nominator = getEmployeeByName(sender)
    if nominator.error?
      msg.send nominator.error
      return

    jiraUserUrl = jiraBaseUrl + "user/picker"
    q = query: nominee.emailAddress
    msg.http(jiraUserUrl)
      .query(q)
      .header("Authorization", authToken)
      .get() (err, res, body) ->
        jiraNominee = parseJiraUser(err, res, body)
        if jiraNominee.error?
          msg.send msg.random jiraNominee.error
          return

        q = query: nominator.emailAddress
        msg.http(jiraUserUrl)
          .query(q)
          .header("Authorization", authToken)
          .get() (err, res, body) ->
            jiraNominator = parseJiraUser(err, res, body)
            if jiraNominator.error?
              msg.send msg.random jiraNominator.error
              return

            requestJson = getRequestJson(jiraNominator.name, jiraNominee.name, reason, "brag", null)
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
                atSign = `usedAtMention ? '@' : ''`
                msg.send "Your brag for #{atSign}#{colleagueName} was successfuly retreived and processed!"

  robot.hear /nominate (@)?([a-zA-Z0-9]+)? for (DFE|PAV|COM|PLG) (because )?(.+)?/i, (msg) ->
    console.log("robot name: " + robot.name)
    sender = msg.message.user.name
    console.log("sender: " + sender)
    usedAtMention = msg.match[1] == '@'
    console.log("usedAtMention: " + usedAtMention)
    colleagueName = msg.match[2]
    console.log("colleagueName: " + colleagueName)
    awardType = msg.match[3]
    console.log("awardType: " + awardType)
    reason = msg.match[5]
    console.log("reason: " + reason)

    if isNomineeRobot(colleagueName)
      msg.send "(embarrassed) Honored, truly, but an Artificial Inteligence does not have a desk to put the award on"
      return

    if usedAtMention
      console.log("used the @ mention, trying to locate userName and emailAddress")
      nominee = getEmployeeByMention(colleagueName)

    if not nominee?
      nominee = getEmployeeByName(colleagueName)
      if nominee.error?
        msg.send nominee.error
        return
    
    if not nominee.userName?
      msg.send "Could not locate a valid user name for #{colleagueName}, cannot nominate"
      return
    if isNomineeSelf(nominee.userName, sender)
      msg.send "(disapproval) nominating yourself is not allowed!"
      return
    if not nominee.emailAddress?
      msg.send "Could not locate a valid email address for #{colleagueName}, cannot nominate"
      return

    nominator = getEmployeeByName(sender)
    if nominator.error?
      msg.send nominator.error
      return

    jiraUserUrl = jiraBaseUrl + "user/picker"
    q = query: nominee.emailAddress
    msg.http(jiraUserUrl)
      .query(q)
      .header("Authorization", authToken)
      .get() (err, res, body) ->
        jiraNominee = parseJiraUser(err, res, body)
        if jiraNominee.error?
          msg.send msg.random jiraNominee.error
          return

        q = query: nominator.emailAddress
        msg.http(jiraUserUrl)
          .query(q)
          .header("Authorization", authToken)
          .get() (err, res, body) ->
            jiraNominator = parseJiraUser(err, res, body)
            if jiraNominator.error?
              msg.send msg.random jiraNominator.error
              return

            requestJson = getRequestJson(jiraNominator.name, jiraNominee.name, reason, "hva", awardType)
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
                atSign = `usedAtMention ? '@' : ''`
                hva = getAwardTypeFromAcronym(awardType)
                msg.send "Your nomination of #{atSign}#{colleagueName} for #{hva} was successfuly retreived and processed!"
