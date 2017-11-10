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

allowedRooms = ['Shell', 'monopoly admin']
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

  robot.respond /bank subtract \$*(\d+) (from )?(delta city|gotham|dmz|monterrey|houston|dallas)$/i, (msg) ->
    if _.contains allowedRooms, msg.envelope.room
      accounts = robot.brain.get 'monopolyAccounts'
      amount = parseInt msg.match[1]
      accountName = msg.match[3]
      account = getAccount(accountName, accounts)
      if account
        balance = parseInt account.balance
        if balance > amount
          balance -= amount
          account.balance = balance
          robot.brain.set 'monopolyAccounts', accounts
          msg.send "$#{amount} subtracted from #{account.name}."
          robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "$#{amount} subtracted from #{account.name}."
        else 
          msg.send "#{account.name} doesn't have enough money to do that! Balance: $#{account.balance}"
      else
        msg.send "I don't know #{team}."
        

  robot.respond /bank add \$*(\d+) (to )?(delta city|gotham|dmz|monterrey|houston|dallas)$/i, (msg) ->
    if _.contains allowedRooms, msg.envelope.room
      accounts = robot.brain.get 'monopolyAccounts'
      amount = parseInt msg.match[1]
      accountName = msg.match[3]
      account = getAccount(accountName, accounts)
      if account
        balance = parseInt account.balance
        balance += amount
        account.balance = balance
        robot.brain.set 'monopolyAccounts', accounts
        msg.send "$#{amount} added to #{account.name}. (coin)"
        robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "$#{amount} added to #{account.name}. (coin)"
      else
        msg.send "I don't know #{team}."

  robot.respond /bank transfer \$*(\d+) from (delta city|gotham|dmz|monterrey|houston|dallas) to (delta city|gotham|dmz|monterrey|houston|dallas)$/i, (msg) ->
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
            robot.brain.set 'monopolyAccounts', accounts
            msg.send "$#{amount} sent from #{fromAccount.name} to #{toAccount.name}."
            robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "$#{amount} sent from #{fromAccount.name} to #{toAccount.name}."

  robot.respond /bank set (delta city|gotham|dmz|monterrey|houston|dallas) balance (to )?\$*(\d+)$/i, (msg) ->
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
        message = "#{accountName} balance set from $#{account.balance} to $#{newBalance}"
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

