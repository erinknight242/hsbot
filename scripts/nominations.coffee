# Description:
#   Let hubot help you nominate coworkers.
#
# Commands:
#   hubot brag on <coworker> <reason>
#   hubot nominate <coworker> [for] <awardType> <reason>

bragHelpText = "/quote example: hsbot brag [on|about] @coworker bragText\nrules:\tbragText and at least one @coworker are required\n\tmultiple @coworker's can be bragged simultaneously when separated by spaces, and, &, or commas (Oxford or otherwise)\n\t[on or about] is optional\nbomb:\thsbot brag bomb [#]\n\t[#] is optional and must be between 1 and 10"
nominateHelpText = "/quote example: hsbot hva [to|for] @coworker for awardAcronym nominationText\nrules:\tcoworker and nominationText are required, awardAcronym must be one of:\n\tDFE (Drive for Excellence)\n\tPAV (People are Valued)\n\tCOM (Honest Communication)\n\tPLG (Passion for Learning and Growth)\nbomb:\thsbot hva bomb [#]\n\t[#] is optional and must be between 1 and 10"

defaultNominationType = "brag"
errorBarks = [
  "My time circuits must be shorting out, I couldn't do that (sadpanda), please don't let me get struck by lightning (build)",
  "What you requested should have worked, BUT it didn't (shrug)",
  "Bad news: it didn't work (boom); good news: I'm alive! I'm alive! (awesome) Wait, no...that is Johnny # 5, there is no good news (evilburns)"
]
jiraBragRoomId = 1720638
jiraBaseUrl = "https://headspring.atlassian.net/rest/api/2/"
hipChatApiV1BaseUrl = "https://headspring.hipchat.com/v1/"
hipChatApiV2BaseUrl = "https://headspring.hipchat.com/v2/"
jiraAuthToken = "Basic #{process.env.HUBOT_JIRA_AUTH}"
hipChatApiV1AuthToken = process.env.HUBOT_HIPCHAT_V1_AUTHTOKEN
hipChatApiV2AuthToken = process.env.HUBOT_HIPCHAT_AUTHTOKEN

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
  summaryType = `nominationType.toLowerCase() == "hva" ? "nominates" : "brags about"`
  nomDate = Date.today().toString("MMM dd, yyyy")
  requestJson = {
    "fields": {
       "project": { "key": "NOM", "id": "14701" }
       "issuetype": issueType,
       "customfield_12100": { "name": nominee.name },
       "description": description,
       "summary": "#{nominator.displayName} #{summaryType} #{nominee.displayName} on #{nomDate}",
       "reporter": {"name": nominator.name }
    }
  }
  if awardType?
    requestJson.fields.customfield_12101 = { "value": getAwardTypeFromAcronym(awardType) }
  JSON.stringify(requestJson)

getQueryJson = (nominationType, count) ->
  issueTypeId = getIssueType(nominationType).id
  queryJson = {
    "jql": "project = 14701 AND issuetype = #{issueTypeId} ORDER BY CreatedDate DESC",
    "maxResults": count
  }
  JSON.stringify(queryJson)

getBragNotificationJson = (bragTo, bragText, bragFrom) ->
  bragText = bragText.replace /(^|\s)((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/gi, ->
    uri = arguments[2]
    uri = "http://#{uri}" if not arguments[3]?
    " <a href=\"#{uri}\" target=\"_blank\">#{uri}</a>"
  bragJson = {
    "message": "<span>Kudos to <span style=\"font-weight: 700\">#{bragTo}</span></span><p>#{bragText}</p><span style=\"text-transform:uppercase;\">bragged by: <em>#{bragFrom}</em></span>",
    "message_format": "html",
    "color": "purple"
  }
  JSON.stringify(bragJson)

getHvaNotificationJson = (nominee, awardType, nominationText, nominator) ->
  notificationJson = {
    "message": "<span style=\"font-weight: 700\">#{nominee}</span><span> exhibits </span><span style=\"font-weight: 700\"><em>#{awardType}</em></span><p>#{nominationText}</p><span>nominated by: <em>#{nominator}</em></span>",
    "message_format": "html",
    "color": "green"
  }
  JSON.stringify(notificationJson)

module.exports = (robot) ->
  # error checking
  foundErrors = (err, res) ->
    if err
      robot.emit 'error', err, res
      return true
    #console.log(res.statusCode)
    if res? and (res.statusCode > 204 or res.statusCode < 200)
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
        #console.log("found mentioned user: " + JSON.stringify(user))
        if user.name? and user.email_address?
          userName = user.name.toLowerCase()
          emailAddress = user.email_address.toLowerCase()
          #console.log("userName: #{userName}, email: #{emailAddress}")
          return { "userName": userName, "emailAddress": emailAddress }
    return null

  getEmployeeByName = (fuzzyName) ->
    matchingUsers = robot.brain.usersForFuzzyName(fuzzyName)
    if not matchingUsers?
      return { "error": "#{fuzzyName}? Never heard of 'em, cannot proceed" }

    if matchingUsers.length != 1
      return { "error": getAmbiguousUserText(matchingUsers) }

    #console.log("found fuzzy user: " + JSON.stringify(matchingUsers[0]))
    if matchingUsers[0].name? and matchingUsers[0].email_address?
      userName = matchingUsers[0].name.toLowerCase()
      emailAddress = matchingUsers[0].email_address.toLowerCase()
      #console.log("userName: #{userName}, email: #{emailAddress}")
    return { "userName": userName, "emailAddress": emailAddress }

  parseJiraUser = (err, res, body, colleagueName) ->
    if foundErrors(err, res)
      return { "error": errorBarks[Math.floor(Math.random() * errorBarks.length)] }
    result = JSON.parse(body)
    if not result? or not result.users? or result.users.length == 0
      return { "error": "#{colleagueName}? JIRA doesn't have record of 'em, cannot proceed" }
    if result.users.length != 1
      return { "error": "JIRA found more than one #{colleagueName}?! Please be more specific to proceed" }
    if not result.users[0]? or not result.users[0].name? or not result.users[0].displayName?
      return { "error": "JIRA does not have the proper user information for #{colleagueName}! Please make sure the user is correctly configured in JIRA to continue" }
    #console.log("woot, found the user in JIRA: " + JSON.stringify(result.users[0]))
    return result.users[0]

  parseJiraIssues = (err, res, body) ->
    if foundErrors(err, res)
      return { "error": errorBarks[Math.floor(Math.random() * errorBarks.length)] }
    #console.log("body after search: " + body)
    jiraResult = JSON.parse(body)
    if not jiraResult? or not jiraResult.issues? or jiraResult.issues.length == 0
      return { "error": "ERROR! could not find any jira issues to bomb you with" }
    return jiraResult.issues

  parseRoomId = (err, res, body, roomJid) ->
    #console.log("room Jid: #{roomJid}")
    if foundErrors(err, res)
      return { "error": errorBarks[Math.floor(Math.random() * errorBarks.length)] }
    #console.log("room results:\n#{body}")
    roomsResult = JSON.parse(body)
    if not roomsResult? or not roomsResult.rooms? or roomsResult.rooms.length == 0
      return { "error": "ERROR! could not locate room to notify with jid: #{roomJid}" }
    matchingRooms = (r for r in roomsResult.rooms when r.xmpp_jid == roomJid)
    if not matchingRooms? or matchingRooms.length == 0
      return { "error": "ERROR! could not locate room to notify with jid: #{roomJid}" }
    if matchingRooms.length > 1
      return { "error": "ERROR! found mulitple matching rooms for jid: #{roomJid} - #{(room.name for room in matchingRooms).join(", ")}" }
    roomId = matchingRooms[0].room_id
    #console.log(roomId)
    return roomId

  parseColleagueNames = (nameString) ->
    cleanString = nameString.replace /( and |[, &])/g, ""
    names = cleanString.split '@'
    names.shift()

    index = 1 #remove any duplicate names so the same person can't receive multiple brags from one statement
    while index < names.length
      num = 0
      while num < index
        if names[num].toLowerCase() is names[index].toLowerCase()
          names.splice index, 1
          index--
          break
        num++
      index++
    return names

  processNomination = (msg, resolve, sender, colleagueName, reason) ->
    #console.log "Processing nomination for " + colleagueName
    nominationResult = { colleagueName: colleagueName, success: false, errorText: 'Unknown error; did not reach valid exit point' }
    if isNomineeRobot(colleagueName)
      nominationResult.errorText = "(embarrassed) Honored, truly, but an Artificial Intelligence does not need your bragging"
      resolve nominationResult
      return

    if not reason?.length
      nominationResult.errorText = "(disapproval), you should supply a reason for your brag"
      resolve nominationResult
      return

    nominee = getEmployeeByMention(colleagueName)
    if not nominee?
      nominee = getEmployeeByName(colleagueName)
      if nominee.error?
        nominationResult.errorText = nominee.error
        resolve nominationResult
        return

    if not nominee.userName?
      nominationResult.errorText = "Could not locate a valid user name for #{colleagueName}, cannot brag"
      resolve nominationResult
      return
    if isNomineeSelf(nominee.userName, sender)
      nominationResult.errorText = "(disapproval) bragging on yourself is not allowed!"
      resolve nominationResult
      return
    if not nominee.emailAddress?
      nominationResult.errorText = "Could not locate a valid email address for #{colleagueName}, cannot brag"
      resolve nominationResult
      return

    nominator = getEmployeeByName(sender)
    if nominator.error?
      nominationResult.errorText = nominator.error
      resolve nominationResult
      return

    jiraUserUrl = jiraBaseUrl + "user/picker"
    q = query: nominee.emailAddress
    msg.http(jiraUserUrl)
      .query(q)
      .header("Authorization", jiraAuthToken)
      .get() (err, res, body) ->
        jiraNominee = parseJiraUser(err, res, body, colleagueName)
        if jiraNominee.error?
          #email lookup between HipChat/JIRA failed; try searching by name instead
          q = query: nominee.userName
          msg.http(jiraUserUrl)
            .query(q)
            .header("Authorization", jiraAuthToken)
            .get() (err, res, body) ->
              jiraNominee = parseJiraUser(err, res, body, colleagueName)
              if jiraNominee.error?
                nominationResult.errorText = "Nominee " + jiraNominee.error
                resolve nominationResult
                return
        nominationResult.nominee = jiraNominee

        q = query: nominator.emailAddress
        msg.http(jiraUserUrl)
          .query(q)
          .header("Authorization", jiraAuthToken)
          .get() (err, res, body) ->
            jiraNominator = parseJiraUser(err, res, body)
            if jiraNominator.error?
              #email lookup between HipChat/JIRA failed; try searching by name instead
              q = query: nominator.userName
              msg.http(jiraUserUrl)
                .query(q)
                .header("Authorization", jiraAuthToken)
                .get() (err, res, body) ->
                  jiraNominator = parseJiraUser(err, res, body)
                  if jiraNominator.error?
                    nominationResult.errorText = "Nominator " + jiraNominator.error
                    resolve nominationResult
                    return
            nominationResult.nominator = jiraNominator;

            requestJson = getRequestJson(jiraNominator, jiraNominee, reason, "brag", null)
            #console.log("requestJson: " + JSON.stringify(requestJson))
            jiraIssueUrl = jiraBaseUrl + "issue"
            msg.http(jiraIssueUrl)
              .header("Authorization", jiraAuthToken)
              .header("Content-Type", "application/json")
              .post(requestJson) (err, res, body) ->
                if foundErrors(err, res)
                  nominationResult.errorText = msg.random errorBarks
                  resolve nominationResult
                  return
                jiraResult = JSON.parse(body)
                nominationResult.id = jiraResult.id
                nominationResult.success = true
                nominationResult.errorText = ''
                resolve nominationResult
                return

  robot.respond /brag help$/i, (msg) ->
    msg.send bragHelpText

  robot.respond /hva help$/i, (msg) ->
    msg.send nominateHelpText

  robot.respond /brag (about |on )?((@[a-z0-9]+(, and |, & |, | and | & | )?)+)(.+)/i, (msg) ->
    #console.log("robot name: " + robot.name)
    sender = msg.message.user.name
    #console.log("sender: " + sender)
    colleagueNames = msg.match[2].trim()
    #console.log("colleagueNames: " + colleagueNames)
    reason = msg.match[5].trim()
    #console.log("reason: " + reason)
    nameArray = parseColleagueNames colleagueNames
    bragResults = []

    for colleagueName in nameArray
      do ->
        bragResults.push new Promise((resolve) ->
            nominationResult = processNomination(msg, resolve, sender, colleagueName, reason)
          )
    Promise.all(bragResults)
      .then (results) ->
        #console.log results
        successNames = ""
        errorReasons = ""
        successCount = 0;
        for brag in results
          do ->
            if brag.success
              if successNames isnt ""
                successNames += ", @"
              successNames += brag.colleagueName
              ++successCount;
            else
              if errorReasons isnt ""
                errorReasons += "\n"
              errorReasons += "Brag about #{brag.colleagueName} failed: #{brag.errorText}"
        if successNames isnt ""
          msg.send "Your brag about @#{successNames} was successfully retrieved and processed!"
        if errorReasons isnt ""
          msg.send errorReasons
        if successCount == 0
          return

        queryJson = getQueryJson("brag", successCount)
        jiraSearchUrl = jiraBaseUrl + "search"
        msg.http(jiraSearchUrl)
          .header("Authorization", jiraAuthToken)
          .header("Content-Type", "application/json")
          .post(queryJson) (err, res, body) ->
            issues = parseJiraIssues(err, res, body)
            if (issues.error?)
              msg.send issues.error
              return

            hipChatNotificationUrl = hipChatApiV2BaseUrl + "room/#{jiraBragRoomId}/notification"
            q2 = auth_token: hipChatApiV2AuthToken
            nomineeNames = ""
            jiraDescription = ""
            jiraReporter = ""
            showConfirmation = true
            for issue in issues
              issueMatches = false
              name = issue.fields.customfield_12100.displayName
              for brag in results
                if brag.id? and brag.id is issue.id
                  issueMatches = true
              if nomineeNames is ""
                nomineeNames = name
                jiraDescription = issue.fields.description
                jiraReporter = issue.fields.reporter.displayName
              else
                nomineeNames += ", " + name
                if not issueMatches
                  showConfirmation = false
            if showConfirmation
              notifyBody = getBragNotificationJson(nomineeNames, jiraDescription, jiraReporter)
              #console.log(notifyBody)
              msg.http(hipChatNotificationUrl)
                .query(q2)
                .header("Content-Type", "application/json")
                .post(notifyBody) (err, res, body) ->
                  if foundErrors(err, res)
                    msg.send msg.random errorBarks
                    return
            else
              msg.send "Unable to match brag(s) with Jira results. Check the Jira HVA project to confirm success."

  robot.respond /hva (to |for )@([a-zA-Z0-9]+) for (DFE|PAV|COM|PLG)(.+)/i, (msg) ->
    #console.log("robot name: " + robot.name)
    sender = msg.message.user.name
    #console.log("sender: " + sender)
    colleagueName = msg.match[2].trim()
    #console.log("colleagueName: " + colleagueName)
    awardType = msg.match[3].trim()
    #console.log("awardType: " + awardType)
    reason = msg.match[4].trim()
    #console.log("reason: " + reason)

    if not reason?.length
      msg.send "(disapproval), you should supply a reason for your nomination"
      return

    if isNomineeRobot(colleagueName)
      msg.send "(embarrassed) Honored, truly, but an Artificial Intelligence does not have a desk to put the award on"
      return

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
      .header("Authorization", jiraAuthToken)
      .get() (err, res, body) ->
        jiraNominee = parseJiraUser(err, res, body)
        if jiraNominee.error?
          msg.send jiraNominee.error
          return

        q = query: nominator.emailAddress
        msg.http(jiraUserUrl)
          .query(q)
          .header("Authorization", jiraAuthToken)
          .get() (err, res, body) ->
            jiraNominator = parseJiraUser(err, res, body)
            if jiraNominator.error?
              msg.send jiraNominator.error
              return

            requestJson = getRequestJson(jiraNominator, jiraNominee, reason, "hva", awardType)
            #console.log("requestJson: " + JSON.stringify(requestJson))
            jiraIssueUrl = jiraBaseUrl + "issue"
            msg.http(jiraIssueUrl)
              .header("Authorization", jiraAuthToken)
              .header("Content-Type", "application/json")
              .post(requestJson) (err, res, body) ->
                if foundErrors(err, res)
                  msg.send msg.random errorBarks
                  return
                #console.log("body after create: " + body)
                hva = getAwardTypeFromAcronym(awardType)
                if not (msg.message.room? and msg.message.room.toLowerCase().match("\/^brags\\w*\/i")) #don't send confirm message in brags and awards room
                  msg.send "Your nomination of @#{colleagueName} for #{hva} was successfully retrieved and processed!"
                queryJson = getQueryJson("hva", 1)
                jiraSearchUrl = jiraBaseUrl + "search"
                msg.http(jiraSearchUrl)
                  .header("Authorization", jiraAuthToken)
                  .header("Content-Type", "application/json")
                  .post(queryJson) (err, res, body) ->
                    issues = parseJiraIssues(err, res, body)
                    if (issues.error?)
                      msg.send issues.error
                      return

                    hipChatNotificationUrl = hipChatApiV2BaseUrl + "room/#{jiraBragRoomId}/notification"
                    q2 = auth_token: hipChatApiV2AuthToken
                    for issue in issues
                      notifyBody = getHvaNotificationJson(issue.fields.customfield_12100.displayName, issue.fields.customfield_12101.value, issue.fields.description, issue.fields.reporter.displayName)
                      #console.log(notifyBody)
                      msg.http(hipChatNotificationUrl)
                        .query(q2)
                        .header("Content-Type", "application/json")
                        .post(notifyBody) (err, res, body) ->
                          if foundErrors(err, res)
                            msg.send msg.random errorBarks
                            return

  robot.respond /brag bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 5
    if (count > 10) #max
      count = 10
    if (count < 1) #min
      count = 1
    queryJson = getQueryJson("brag", count)
    #console.log("queryJson: " + JSON.stringify(queryJson))
    jiraSearchUrl = jiraBaseUrl + "search"
    msg.http(jiraSearchUrl)
      .header("Authorization", jiraAuthToken)
      .header("Content-Type", "application/json")
      .post(queryJson) (err, res, body) ->
        issues = parseJiraIssues(err, res, body)
        if (issues.error?)
          msg.send issues.error
          return

        #console.log("msg.message.user: #{JSON.stringify(msg.message.user)}")
        if msg.message.user? and msg.message.user.reply_to?
          hipChatRoomUrl = hipChatApiV1BaseUrl + "rooms/list"
          roomQ = { format: 'json', auth_token: hipChatApiV1AuthToken }
          msg.http(hipChatRoomUrl)
            .query(roomQ)
            .get() (err, res, body) ->
              roomId = parseRoomId(err, res, body, msg.message.user.reply_to)
              if (roomId.error?)
                msg.send roomId.error
                return

              hipChatNotificationUrl = hipChatApiV2BaseUrl + "room/#{roomId}/notification"
              notifyQ = auth_token: hipChatApiV2AuthToken
              for issue in issues
                notifyBody = getBragNotificationJson(issue.fields.customfield_12100.displayName, issue.fields.description, issue.fields.reporter.displayName)
                #console.log(notifyBody)
                msg.http(hipChatNotificationUrl)
                  .query(notifyQ)
                  .header("Content-Type", "application/json")
                  .post(notifyBody) (err, res, body) ->
                    if foundErrors(err, res)
                      msg.send msg.random errorBarks
                      return
        else
          for issue in issues
            notifyBody = getBragNotificationJson(issue.fields.customfield_12100.displayName, issue.fields.description, issue.fields.reporter.displayName)
            msg.send notifyBody

  robot.respond /hva bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 5
    if (count > 10) #max
      count = 10
    if (count < 1) #min
      count = 1
    queryJson = getQueryJson("hva", count)
    #console.log("queryJson: " + JSON.stringify(queryJson))
    jiraSearchUrl = jiraBaseUrl + "search"
    msg.http(jiraSearchUrl)
      .header("Authorization", jiraAuthToken)
      .header("Content-Type", "application/json")
      .post(queryJson) (err, res, body) ->
        issues = parseJiraIssues(err, res, body)
        if (issues.error?)
          msg.send issues.error
          return

        if msg.message.user? and msg.message.user.reply_to?
          hipChatRoomUrl = hipChatApiV1BaseUrl + "rooms/list"
          roomQ = { format: 'json', auth_token: hipChatApiV1AuthToken }
          msg.http(hipChatRoomUrl)
            .query(roomQ)
            .get() (err, res, body) ->
              roomId = parseRoomId(err, res, body, msg.message.user.reply_to)
              if (roomId.error?)
                msg.send roomId.error
                return

              hipChatNotificationUrl = hipChatApiV2BaseUrl + "room/#{roomId}/notification"
              notifyQ = auth_token: hipChatApiV2AuthToken
              for issue in issues
                notifyBody = getHvaNotificationJson(issue.fields.customfield_12100.displayName, issue.fields.customfield_12101.value, issue.fields.description, issue.fields.reporter.displayName)
                #console.log(notifyBody)
                msg.http(hipChatNotificationUrl)
                  .query(notifyQ)
                  .header("Content-Type", "application/json")
                  .post(notifyBody) (err, res, body) ->
                    if foundErrors(err, res)
                      msg.send msg.random errorBarks
                      return
        else
          for issue in issues
            notifyBody = getHvaNotificationJson(issue.fields.customfield_12100.displayName, issue.fields.customfield_12101.value, issue.fields.description, issue.fields.reporter.displayName)
            msg.send notifyBody
