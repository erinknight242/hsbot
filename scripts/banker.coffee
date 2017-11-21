# Description:
#   Banker commands to manage monopoly balances
#
# Commands:
#
#  hsbot bank set teamName balance (to) amount
#  hsbot bank transfer amount from teamName to teamName
#  hsbot bank add amount (to) teamName
#  hsbot bank subtract (from) teamName
#  hsbot bank balance (teamName)
#  hsbot bank help

_ = require 'underscore'

allowedRooms = ['Shell', 'monopoly_admins']
monopolyRoom = '18483_monopoly@conf.hipchat.com'

module.exports = (robot) ->

  getAccount = (name, accounts) ->
    _.find accounts, (account) => account.name.toLowerCase() == name.toLowerCase()

  robot.respond /bank help$/i, (msg) ->
    msg.send '~Bank Help~\n
      \thsbot bank balance (teamName) - public command\n
      \thsbot bank transfer amount from teamName to teamName\n
      \thsbot bank add amount (to) teamName\n
      \thsbot bank subtract amount (from) teamName\n
      \thsbot bank set teamName balance (to) amount\n'

  robot.respond /bank subtract \$*(\d+) (from )?(delta city|gotham|dmz|monterrey|houston|dallas)( for)?( .+)?$/i, (msg) ->
    if _.contains allowedRooms, msg.envelope.room
      accounts = robot.brain.get 'monopolyAccounts'
      amount = parseInt msg.match[1]
      accountName = msg.match[3]
      account = getAccount(accountName, accounts)
      if account
        originalBalance = parseInt account.balance
        balance = originalBalance
        if balance >= amount
          balance -= amount
          account.balance = balance
          memo = ''
          if msg.match[5] then memo = " for#{msg.match[5]}"
          msg.send "$#{amount} subtracted from #{account.name}#{memo}."
          robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "#{account.name} account updated from $#{originalBalance} to $#{balance}#{memo}."
          robot.brain.set 'monopolyAccounts', accounts
        else 
          msg.send "#{account.name} doesn't have enough money to do that! Balance: $#{account.balance}"
      else
        msg.send "I don't know #{team}."
        

  robot.respond /bank add \$*(\d+) (to )?(delta city|gotham|dmz|monterrey|houston|dallas)( for)?( .+)?$/i, (msg) ->
    if _.contains allowedRooms, msg.envelope.room
      accounts = robot.brain.get 'monopolyAccounts'
      amount = parseInt msg.match[1]
      accountName = msg.match[3]
      account = getAccount(accountName, accounts)
      if account
        originalBalance = parseInt account.balance
        balance = originalBalance
        balance += amount
        account.balance = balance
        memo = ''
        if msg.match[5] then memo = " for#{msg.match[5]}"
        robot.brain.set 'monopolyAccounts', accounts
        msg.send "$#{amount} added to #{account.name}. (coin)"
        robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "#{account.name} account updated from $#{originalBalance} to $#{balance}#{memo}. (coin)"
      else
        msg.send "I don't know #{team}."

  robot.respond /bank transfer \$*(\d+) from (delta city|gotham|dmz|monterrey|houston|dallas) to (delta city|gotham|dmz|monterrey|houston|dallas)( for)?( .+)?$/i, (msg) ->
    if _.contains allowedRooms, msg.envelope.room
      amount = parseInt msg.match[1]
      fromName = msg.match[2].toLowerCase()
      toName = msg.match[3].toLowerCase()
      if fromName == toName
        msg.send '(unacceptable)'
      else
        accounts = robot.brain.get 'monopolyAccounts'
        fromAccount = getAccount(fromName, accounts)
        toAccount = getAccount(toName, accounts)
        if !(fromAccount && toAccount)
          msg.send 'Double check your account names; both must exist.'
        else
          fromBalance = parseInt fromAccount.balance
          toBalance = parseInt toAccount.balance
          if fromBalance < amount
            msg.send "#{fromAccount.name} doesn't have enough money to do that! Balance: $#{fromAccount.balance}"
          else
            fromBalance -= amount
            toBalance += amount
            fromAccount.balance = fromBalance
            toAccount.balance = toBalance
            memo = ''
            if msg.match[5] then memo = " for#{msg.match[5]}"
            robot.brain.set 'monopolyAccounts', accounts
            msg.send "$#{amount} sent from #{fromAccount.name} to #{toAccount.name}."
            robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "$#{amount} sent from #{fromAccount.name} to #{toAccount.name}#{memo}."

  robot.respond /bank set (delta city|gotham|dmz|monterrey|houston|dallas) balance (to )?\$*(\d+)( for)?( .+)?$/i, (msg) ->
    if _.contains allowedRooms, msg.envelope.room
      accounts = robot.brain.get 'monopolyAccounts'
      accountName = msg.match[1]
      newBalance = msg.match[3]
      account = getAccount(accountName, accounts)
      message = ''
      if !account
        accounts = accounts || []
        accounts.push { name: accountName, balance: newBalance }
        message = "Account created for #{accountName} with a balance of $#{newBalance}"
      else
        memo = ''
        if msg.match[5] then memo = " for#{msg.match[5]}"
        message = "#{accountName} balance set from $#{account.balance} to $#{newBalance}#{memo}."
        account.balance = newBalance
      robot.brain.set 'monopolyAccounts', accounts
      msg.send message
      robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, message


  robot.respond /bank balance( delta city| gotham| dmz| monterrey| houston| dallas)?/i, (msg) ->
    accounts = robot.brain.get 'monopolyAccounts'
    if !accounts then msg.send 'There aren\'t any accounts.'
    else
      team = msg.match[1]
      message = ''
      if team
        account = getAccount(team.trim(), accounts)
        if account
          msg.send "#{account.name}: $#{account.balance}"
        else
          msg.send "I don't know #{team}."
      else
        for account in accounts
          message += "#{account.name}: $#{account.balance}\n"
        msg.send message

  robot.respond /bank initialize accounts \$*(\d+)$/i, (msg) ->
    amount = msg.match[1]
    accounts = [
      { name: 'Delta City', balance: amount }
      { name: 'Gotham', balance: amount }
      { name: 'DMZ', balance: amount }
      { name: 'Houston', balance: amount }
      { name: 'Dallas', balance: amount }
      { name: 'Monterrey', balance: amount }
    ]
    robot.brain.set 'monopolyAccounts', accounts
    msg.send "All accounts set to $#{amount}."
