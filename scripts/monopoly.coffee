# Description:
#   Interactive Monopoly game
#
# Commands:
#   hsbot monopoly help
#   hsbot monopoly roll
#   hsbot monopoly buy
#   hsbot monopoly auction
#   hsbot monopoly update propertyName (delta city|gotham|dmz|monterrey|houston|dallas)
#   hsbot monopoly sold (delta city|gotham|dmz|monterrey|houston|dallas) amount
#   hsbot monopoly status
#   hsbot monopoly board
#   hsbot monopoly details propertyName
#   hsbot monopoly mortgage propertyName
#   hsbot monopoly unmortgage propertyName
#   hsbot monopoly build propertyName
#   hsbot monopoly unbuild propertyName
#   hsbot monopoly jail pay
#   hsbot monopoly jail roll
#   hsbot monopoly jail card
#   hsbot monopoly continue (for after jail rolls failed)
#
# Admin commands:
#   hsbot monopoly start new game - starts a new game from scratch
#   hsbot monopoly dump log - rough dump of the Monopoly brain state
#   hsbot monopoly set scale factor number
#
# TODO:
# - admin commands to manually update the brain variables
# - Sell back property to the bank (half cost), can't have houses on any of that color
# - Bankruptcy (transfer to new owner, pay 10% for mortgages, sell back houses/hotels)
# - Bankrupt to the bank; auction off properties
# - sell get out of jail free cards
# - 10% for income tax (once money is tracked)
# - Free Parking?
#
# Original Monopoly $ amounts will be multiplied by the scale factor to adjust 
# for our game's extra money rewards

_ = require 'underscore'

bankerInstructions = 'Theme Team: once account is updated, "hsbot monopoly roll"'
allowedRooms = ['Shell', 'monopoly']
boardImage = 'https://i.imgur.com/2vyzOVR.png'

roll = () ->
  total = 0
  rolls = for number in [1..2]
    result = Math.floor(Math.random() * 6) + 1
    total += result
    result

  total: total
  rolls: rolls
  doubles: rolls[0] == rolls[1]

module.exports = (robot) ->
  shuffle = (deckName) ->
    cardIndexArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    i = cardIndexArray.length;

    while --i
      j = Math.floor(Math.random() * (i + 1))
      tempi = cardIndexArray[i]
      tempj = cardIndexArray[j]
      cardIndexArray[i] = tempj
      cardIndexArray[j] = tempi
    
    robot.brain.set deckName, cardIndexArray
    cardIndexArray

  drawCard = (deckName) ->
    cardIndexArray = robot.brain.get deckName
    chanceOwner = robot.brain.get 'monopolyChanceJailOwner'
    communityChestOwner = robot.brain.get 'monopolyCommunityChestJailOwner'
    drawnCardIndex = cardIndexArray.pop()
    cards = updateDeck(deckName, chanceOwner, communityChestOwner, cardIndexArray, drawnCardIndex)

    if cards.drawnCardIndex == undefined
      newDeck = shuffle(deckName)
      drawnCardIndex = newDeck.pop()
      cards = updateDeck(deckName, chanceOwner, communityChestOwner, newDeck, drawnCardIndex)
    robot.brain.set deckName, cards.deck
    cards.drawnCardIndex

  updateDeck = (deckName, chanceOwner, communityChestOwner, cards, drawnCardIndex) ->
    if deckName == 'monopolyChance' && drawnCardIndex == 1 && chanceOwner
      drawnCardIndex = cards.pop()
    else if deckName == 'monopolyCommunityChest' && drawnCardIndex == 15 && communityChestOwner
      drawnCardIndex = cards.pop()

    deck: cards
    drawnCardIndex: drawnCardIndex

  setNextPlayer = () -> 
    players = robot.brain.get 'monopolyPlayers'
    turn = robot.brain.get 'monopolyTurn'
    if !players[turn].doubles
      turn++
    if (turn == players.length)
      turn = 0
    robot.brain.set 'monopolyTurn', turn
    turn

    playerIndex = robot.brain.get 'monopolyTurn'
    turnState = robot.brain.get 'monopolyTurnState'
    robot.messageRoom process.env.HUBOT_ROOM_MONOPOLY, "\nCurrent turn is now: #{players[playerIndex].name} #{turnState}"

  updatePlayerInJail = (players, playerIndex, roll) ->
    current = players[playerIndex]

    if roll.doubles
      freeFromJail(players, playerIndex)
      current.location += roll.total
    else
      current.jailRolls += 1

    robot.brain.set 'monopolyPlayers', players
    
    current.jailRolls

  updatePlayer = (players, playerIndex, roll) ->
    current = players[playerIndex]
    current.location += roll.total
    current.doubles = roll.doubles
    if roll.doubles
      current.doublesCount += 1
    else 
      current.doublesCount = 0

    if current.doublesCount == 3
      passedGo = false
    else 
      passedGo = false
      if (current.location > 39)
        current.location = current.location - 40
        passedGo = true

    robot.brain.set 'monopolyPlayers', players
    
    current: current
    passedGo: passedGo

  advancePlayer = (players, playerIndex, rollTotal) ->
    current = players[playerIndex]
    current.location += rollTotal
    robot.brain.set 'monopolyPlayers', players

  sendPlayer = (players, playerIndex, locationIndex, msg, skipGo) ->
    current = players[playerIndex]
    if players[playerIndex].location > locationIndex && !skipGo
      msg.send 'You passed GO! Collect $200. (go)'
    current.location = locationIndex
    robot.brain.set 'monopolyPlayers', players
    current

  checkForMonopoly = (board, set) ->
    owner = board[set[0]].owner
    monopoly = true
    if (owner == null)
     return false
    for property in set
      if board[property].owner != owner
        monopoly = false

    for property in set
      board[property].monopoly = monopoly

  updateThisProperty = (board, players, propertyIndex, buyerIndex) ->
    property = board[propertyIndex]
    property.owner = players[buyerIndex].name

    for group in monopolyGroups
      if _.contains(group, propertyIndex)
        checkForMonopoly(board, group)

    robot.brain.set 'monopolyBoard', board

  updateProperty = (board, players, playerIndex, buyerIndex) ->
    currentIndex = players[playerIndex].location
    updateThisProperty(board, players, currentIndex, buyerIndex)

  getAccount = (name, accounts) ->
    _.find accounts, (account) => account.name.toLowerCase() == name.toLowerCase()

  updatePlayerAccount = (player, amount) ->
    accounts = robot.brain.get 'monopolyAccounts'
    account = getAccount(player, accounts)
    if account
      balance = parseInt account.balance
      if balance > amount
        balance -= amount
        account.balance = balance
        robot.brain.set 'monopolyAccounts', accounts
        robot.messageRoom process.env.HUBOT_ROOM_ADMIN_MONOPOLY, "$#{amount} subtracted from #{account.name}."

  sendToJail = (players, playerIndex) ->
    players[playerIndex].location = 10
    players[playerIndex].inJail = true
    players[playerIndex].jailRolls = 0
    players[playerIndex].doubles = false
    players[playerIndex].doublesCount = 0

    robot.brain.set 'monopolyPlayers', players

  freeFromJail = (players, playerIndex) ->
    players[playerIndex].inJail = false
    players[playerIndex].jailRolls = 0
    players[playerIndex].doubles = false
    players[playerIndex].doublesCount = 0

    robot.brain.set 'monopolyPlayers', players

  playTurn = (data, players, playerIndex, playerData, currentRoll, msg, hideRollMessage) ->
    player = players[playerIndex]
    doubles = ', a'
    if currentRoll.doubles
      doubles = ', **DOUBLES**! A'
    if !hideRollMessage
      msg.send "#{players[playerIndex].name} rolls #{currentRoll.total}#{doubles}dvances to #{data[player.location].name}."
    if playerData.passedGo
      msg.send 'You passed GO, collect $200! (go)'
    
    # Present player with options
    if _.contains([2, 17, 33], player.location)
      # Community Chest
      cardIndex = drawCard('monopolyCommunityChest')
      msg.send communityChestCards[cardIndex].message
      if communityChestCards[cardIndex].action
        communityChestCards[cardIndex].action(data, players, playerIndex, playerData, currentRoll, msg, communityChestCards[cardIndex].value)
      else
        setNextPlayer()
    else if _.contains([7, 22, 36], player.location)
      # Chance
      cardIndex = drawCard('monopolyChance')
      msg.send chanceCards[cardIndex].message
      if chanceCards[cardIndex].action
        chanceCards[cardIndex].action(data, players, playerIndex, playerData, currentRoll, msg, chanceCards[cardIndex].value)
      else
        setNextPlayer()
    else if player.location == 0
      # Go
      setNextPlayer()
    else if player.location == 30
      # Go to Jail
      sendToJail(players, playerIndex)
      setNextPlayer()
    else if player.location == 4
      # Income Tax
      msg.send "Stacy discovered you haven't submitted receipts for the past two months. Pay $200. #{bankerInstructions}"
      updatePlayerAccount(player.name, 200)
      setNextPlayer()
    else if player.location == 38
      # Luxury Tax
      msg.send "Vasudha needs a new pair of shoes. Pay $75. #{bankerInstructions}"
      updatePlayerAccount(player.name, 75)
      setNextPlayer()
    else if player.location == 20
      # Free Parking (until money tracked in game, no bonus for Free Parking)
      setNextPlayer()
    else if player.location == 10
      # Visiting Jail
      setNextPlayer()
    else 
      # Remaining properties
      owner = data[player.location].owner
      message = ''
      if !owner
        msg.send "This property is available. Buy it for $#{data[player.location].cost}? (\"hsbot monopoly buy\" or \"hsbot monopoly auction\")"
        robot.brain.set 'monopolyTurnState', 'buy'
      else if data[player.location].mortgaged
        msg.send 'This property is mortgaged. Your stay is free! "hsbot monopoly roll"'
        setNextPlayer()
      else
        railroadSet = [5, 15, 25, 35]
        utilitySet = [12, 28]
        if _.contains(railroadSet, player.location)
          # Railroad
          numberOwned = 0;
          for railroad in railroadSet
            if data[railroad].owner == owner
              numberOwned += 1
          switch
            when numberOwned == 1 then owes = 25
            when numberOwned == 2 then owes = 50
            when numberOwned == 3 then owes = 100
            when numberOwned == 4 then owes = 200
          message = "#{owner} owns #{numberOwned} railroad"
          if numberOwned == 1
            message += '. '
          else
            message += 's. '
        else if _.contains(utilitySet, player.location)
          # Utilities
          numberOwned = 0;
          for utility in utilitySet
            if data[utility].owner == owner
              numberOwned += 1
          owes = 4 * currentRoll.total
          message = "#{owner} owns 1 utilitity. "
          if numberOwned == 2
            owes = 10 * currentRoll.total
            message = "#{owner} owns 2 utilities. "
        else
          owes = data[player.location].rent
          if data[player.location].houses
            owes = data[player.location]['house' + data[player.location].houses]
          else if data[player.location].monopoly
            owes *= 2
        
        if (data[player.location].owner == player.name)
          msg.send 'You own it! Enjoy your stay. "hsbot monopoly roll" to continue.'
        else
          msg.send "#{message}Pay #{data[player.location].owner} $#{owes}. #{bankerInstructions}"
        setNextPlayer()

  goToNearestUtility = (data, players, playerIndex, playerData, currentRoll, msg) ->
    if players[playerIndex].location < 12 || players[playerIndex].location > 28
      current = sendPlayer(players, playerIndex, 12, msg)
    else
      current = sendPlayer(players, playerIndex, 28, msg)
    currentOwner = data[current.location].owner

    if currentOwner == players[playerIndex].name
      msg.send "You own it! Enjoy your stay at #{data[current.location].name}"
      setNextPlayer()
    else if currentOwner
      newRoll = roll()
      msg.send "You rolled #{newRoll.total}. Pay #{currentOwner} $#{10 * newRoll.total}. #{bankerInstructions}"
      setNextPlayer()
    else
      msg.send "#{data[current.location].name} is available for sale. Send \"hsbot monopoly buy\" or \"hsbot monopoly auction\"."
      robot.brain.set 'monopolyTurnState', 'buy'

  assignJailCard = (data, players, playerIndex, playerData, currentRoll, msg, cardName) ->
    robot.brain.set cardName, players[playerIndex].name
    setNextPlayer()

  goToLocation = (data, players, playerIndex, playerData, currentRoll, msg, locationIndex ) ->
    current = sendPlayer(players, playerIndex, locationIndex, msg, locationIndex == 0)
    playTurn(data, players, playerIndex, { current: current, passedGo: false }, currentRoll, msg, true)

  goBackThree = (data, players, playerIndex, playerData, currentRoll, msg) ->
    current = sendPlayer(players, playerIndex, players[playerIndex].location - 3, msg, true)
    playTurn(data, players, playerIndex, { current: current, passedGo: false }, currentRoll, msg, true)

  goToNearestRailroad = (data, players, playerIndex, playerData, currentRoll, msg) ->
    if players[playerIndex].location < 5 || players[playerIndex].location > 35
      current = sendPlayer(players, playerIndex, 5, msg)
    else if  players[playerIndex].location < 15
      current = sendPlayer(players, playerIndex, 15, msg)
    else if  players[playerIndex].location < 25
      current = sendPlayer(players, playerIndex, 25, msg)
    else
      current = sendPlayer(players, playerIndex, 35, msg)
    currentOwner = data[current.location].owner

    if currentOwner == players[playerIndex].name
      msg.send "You own it! Enjoy your ride on #{data[current.location].name}"
      setNextPlayer()
    else if currentOwner
      railroadSet = [5, 15, 25, 35]
      numberOwned = 0;
      for railroad in railroadSet
        if data[railroad].owner == currentOwner
          numberOwned += 1
      switch
        when numberOwned == 1 then owes = 50
        when numberOwned == 2 then owes = 100
        when numberOwned == 3 then owes = 200
        when numberOwned == 4 then owes = 400
      message = "#{currentOwner} owns #{numberOwned} railroad"
      if numberOwned == 1
        message += '. '
      else
        message += 's. '
      msg.send "#{message}Pay #{currentOwner.name} $#{owes}. #{bankerInstructions}"
      setNextPlayer()
    else
      msg.send "#{data[current.location].name} is available for sale. Send \"hsbot monopoly buy\" or \"hsbot monopoly auction\"."
      robot.brain.set 'monopolyTurnState', 'buy'

  sendToJailCard = (data, players, playerIndex, playerData, currentRoll, msg) ->
    sendToJail(players, playerIndex)
    msg.send '"hsbot monopoly roll" to continue.'
    setNextPlayer()

  checkIfCanBuild = (data, propertyIndex) ->
    if data[propertyIndex].monopoly && data[propertyIndex].houses < 5
      currentHouses = data[propertyIndex].houses
      canBuild = true
      for group in monopolyGroups
        if _.contains(group, propertyIndex)
          for index in group
            if currentHouses > data[index].houses then canBuild = false
      return canBuild
    else
      false

  checkIfCanSell = (data, propertyIndex) ->
    if data[propertyIndex].monopoly && data[propertyIndex].houses > 0
      currentHouses = data[propertyIndex].houses
      canSell = true
      for group in monopolyGroups
        if _.contains(group, propertyIndex)
          for index in group
            if currentHouses < data[index].houses then canSell = false
      return canSell
    else
      false

  build = (data, propertyIndex, msg) ->
    totalHouses = robot.brain.get 'monopolyHouses'
    totalHotels = robot.brain.get 'monopolyHotels'
    property = data[propertyIndex]
    property.houses += 1
    added = true
    if (property.houses < 5)
      type = 'house'
      totalHouses += 1
      if totalHouses > 32
        msg.send '32 houses are already in use, wait until some are replaced or sold.'
        added = false
      else
        robot.brain.set 'monopolyHouses', totalHouses
    else if (property.houses == 5)
      type = 'hotel'
      totalHotels += 1
      totalHouses -= 4
      if totalHotels > 12
        msg.send '12 hotels are already in use, wait until some are sold.'
        added = false
      else
        robot.brain.set 'monopolyHotels', totalHotels
        robot.brain.set 'monopolyHouses', totalHouses
    if added
      robot.brain.set 'monopolyBoard', data
      msg.send "#{property.owner} built a #{type}, pay $#{property.houseCost}. #{bankerInstructions}"

  removeHouse = (data, propertyIndex, msg) ->
    totalHouses = robot.brain.get 'monopolyHouses'
    totalHotels = robot.brain.get 'monopolyHotels'
    property = data[propertyIndex]
    if property.houses > 0
      property.houses -= 1
      robot.brain.set 'monopolyBoard', data
      if (property.houses == 4)
        type = 'hotel'
        totalHotels -= 1
        totalHouses += 4
        robot.brain.set 'monopolyHouses', totalHouses
        robot.brain.set 'monopolyHotels', totalHotels
      else
        type = 'house'
        totalHouses -= 1
        robot.brain.set 'monopolyHouses', totalHouses
      msg.send "#{property.owner} sold a #{type}, collect $#{property.houseCost / 2}. #{bankerInstructions}"

  robot.respond /monopoly help$/i, (msg) ->
    msg.send '\n~ Monopoly Help ~\n
      \thsbot monopoly board - Static image of the game board
      \thsbot monopoly roll - If you aren\'t sure what to do, try this one\n
      \thsbot monopoly buy - action for an unowned property\n
      \thsbot monopoly auction - action for an unowned property\n
      \thsbot monopoly sold (delta city|gotham|dmz|monterrey|houston|dallas) amount - ends an auction\n
      \thsbot monopoly update propertyName (delta city|gotham|dmz|monterrey|houston|dallas) - transfer property by trade or sale\n
      \thsbot monopoly details propertyName - lists the details/prices on the property card\n
      \thsbot monopoly build propertyName - if part of a monopoly, builds a house or hotel\n
      \thsbot monopoly unbuild propertyName - if part of a monopoly, sells a house or hotel for half value\n
      \thsbot monopoly mortgage propertyName - mortgages a property\n
      \thsbot monopoly unmortgage propertyName - unmortgages a property at value + 10%\n
      \thsbot monopoly status - who owns what, where they are, and whose turn it is\n
      \thsbot monopoly jail pay - way to get out of jail\n
      \thsbot monopoly jail roll - way to attempt to get out of jail\n
      \thsbot monopoly jail card - if you\'re lucky enough to have one of these to get out of jail\n
      \thsbot monopoly continue - after jail rolls failed and you have to pay anyway\n\n
      Game commands can only be used in the Monopoly room. Join in!'

  robot.respond /monopoly board$/i, (msg) ->
    msg.send boardImage

  robot.respond /monopoly roll$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'roll'
          msg.send "Sorry, expecting #{turnState} command."
        else if players[playerIndex].inJail
          robot.brain.set 'monopolyTurnState', 'jail'
          jailChanceCardOwner = robot.brain.get 'monopolyChanceJailOwner'
          jailCommunityChestCardOwner = robot.brain.get 'monopolyCommunityChestJailOwner'
          cardOption = ''
          if _.contains([jailChanceCardOwner, jailCommunityChestCardOwner], players[playerIndex].name)
            cardOption = ', use your Get Out of Jail Free card with "hsbot monopoly jail card,"'
          msg.send "#{players[playerIndex].name}, you're in jail. You can pay $50 with \"hsbot monopoly jail pay\"#{cardOption} or \"hsbot monopoly jail roll\" to try your luck."
        else
          # Roll dice for current player & update board
          currentRoll = roll()
          playerData = updatePlayer(players, playerIndex, currentRoll)
          player = playerData.current
          if player.doublesCount == 3
            msg.send "#{players[playerIndex].name} rolls #{currentRoll.total}, **DOUBLES**! Oh no! You rolled doubles 3 times. Go to Jail. (jail)"
            sendToJail(players, playerIndex)
            setNextPlayer()
          else
            playTurn(data, players, playerIndex, playerData, currentRoll, msg)
      else
        msg.send 'There is no game in progress! (doh)'

  robot.respond /monopoly buy$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'buy'
          msg.send "Sorry, expecting #{turnState} command."
        else
          owner = data[players[playerIndex].location].owner
          if owner
            msg.send "You can't buy #{data[players[playerIndex].location].name}, #{owner} owns it. Try rolling instead."
          else if owner == undefined
            msg.send "You can't buy #{data[players[playerIndex].location].name}, try rolling instead."
          else
            player = players[playerIndex].name
            amount = data[players[playerIndex].location].cost
            msg.send "#{player} pays the bank $#{amount} for #{data[players[playerIndex].location].name}. #{bankerInstructions}"
            updatePlayerAccount(player, amount)
            updateProperty(data, players, playerIndex, playerIndex)
            robot.brain.set 'monopolyTurnState', 'roll'
            setNextPlayer()

  robot.respond /monopoly auction$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'buy'
          msg.send "Sorry, expecting #{turnState} command."
        else
          robot.brain.set 'monopolyTurnState', 'auction'
          msg.send "#{data[players[playerIndex].location].name} is up for sale! Discuss your bids below. Once the highest bid has been placed, end by e.g. \"hsbot monopoly sold to Dallas for 150\""

  robot.respond /monopoly sold (to )?(delta city|gotham|dmz|monterrey|houston|dallas) (for )?\$*(\d+)$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'auction'
          msg.send "Sorry, expecting #{turnState} command."
        else
          buyerName = msg.match[2]
          soldPrice = msg.match[4]

          buyerIndex = _.findIndex(players, (player) ->
            player.name.toLowerCase() == buyerName.toLowerCase() 
          )

          player = players[buyerIndex].name
          msg.send "#{players[buyerIndex].name} pays $#{soldPrice} for #{data[players[playerIndex].location].name}. #{bankerInstructions}"
          updatePlayerAccount(player, soldPrice)
          updateProperty(data, players, playerIndex, buyerIndex)
          robot.brain.set 'monopolyTurnState', 'roll'
          setNextPlayer()

  robot.respond /monopoly update ([a-z &-]+) (Delta City|Gotham|DMZ|Monterrey|Houston|Dallas)$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      players = robot.brain.get 'monopolyPlayers'

      propertyName = msg.match[1]
      newOwner = msg.match[2]

      if data
        propertyIndex = _.findIndex(data, (property) => property.name.toLowerCase() == propertyName.toLowerCase())
        ownerIndex = _.findIndex(players, (player) => player.name.toLowerCase() == newOwner.toLowerCase())
        if propertyIndex < 0
          msg.send 'I don\'t know that property, check the spelling with "hsbot monopoly status"'
        else if !data[propertyIndex].owner
          msg.send 'No one owns that property! Someone must buy it first.'
        else
          updateThisProperty(data, players, propertyIndex, ownerIndex)
          msg.send "#{data[propertyIndex].name} has been transferred to #{players[ownerIndex].name}."

  robot.respond /monopoly build ([a-z &-]+)$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      propertyName = msg.match[1]
      if data
        propertyIndex = _.findIndex(data, (property) => property.name.toLowerCase() == propertyName.toLowerCase())
        if propertyIndex > -1 && data[propertyIndex].monopoly
          if checkIfCanBuild(data, propertyIndex)
            build(data, propertyIndex, msg)
          else if data[propertyIndex].houses == 5
            msg.send 'You already built a hotel here! Go build somewhere else!'
          else
            msg.send 'You have to build evenly on your monopoly. Build on other properties first.'
        else
          msg.send 'You can only build on properties that are part of a monopoly.'

  robot.respond /monopoly unbuild ([a-z &-]+)$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      propertyName = msg.match[1]
      if data
        propertyIndex = _.findIndex(data, (property) => property.name.toLowerCase() == propertyName.toLowerCase())
        if propertyIndex > -1 && data[propertyIndex].houses > 0
          if checkIfCanSell(data, propertyIndex)
            removeHouse(data, propertyIndex, msg)
          else
            msg.send 'You have to unbuild evenly on your monopoly. Sell your other buildings first.'
        else
          msg.send 'There aren\'t any houses built here.'

  robot.respond /monopoly mortgage ([a-z &-]+)$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      propertyName = msg.match[1]
      if data
        propertyIndex = _.findIndex(data, (property) => property.name.toLowerCase() == propertyName.toLowerCase())
        if propertyIndex > -1
          property = data[propertyIndex]
          if property.mortgaged
            msg.send 'This property is already mortaged!'
          else if property.houses > 0
            msg.send 'You need to sell your buildings first. "hsbot monopoly unbuild ' + property.name + '"'
          else
            property.mortgaged = true
            robot.brain.set 'monopolyBoard', data
            msg.send "#{property.owner} mortgaged #{property.name}, collect $#{property.mortgage}. #{bankerInstructions}"

  robot.respond /monopoly unmortgage ([a-z &-]+)$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      propertyName = msg.match[1]
      if data
        propertyIndex = _.findIndex(data, (property) => property.name.toLowerCase() == propertyName.toLowerCase())
        if propertyIndex > -1
          property = data[propertyIndex]
          if property.mortgaged
            property.mortgaged = false
            robot.brain.set 'monopolyBoard', data
            msg.send "#{property.owner} unmortgaged #{property.name}, pay $#{Math.round(property.mortgage * 1.1)}. #{bankerInstructions}"
          else
            msg.send 'This property isn\'t mortgaged. (smh)'

  robot.respond /monopoly details ([a-z &-]+)$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    if data
      match = _.find(data, (property) => property.name.toLowerCase() == msg.match[1].toLowerCase())
      if match
        message = match.name + '\n'
        if match.cost then message += "Cost: $#{match.cost}\n"
        if match.rent then message += "Rent: $#{match.rent}\n"
        if match.house1 then message += "Rent with 1 house: $#{match.house1}\n"
        if match.house2 then message += "Rent with 2 houses: $#{match.house2}\n"
        if match.house3 then message += "Rent with 3 houses: $#{match.house3}\n"
        if match.house4 then message += "Rent with 4 houses: $#{match.house4}\n"
        if match.hotel then message += "Rent with a hotel: $#{match.hotel}\n"
        if match.mortgage then message += "Mortgage value: $#{match.mortgage}\n"
        if match.houseCost then message += "Cost per house/hotel: $#{match.houseCost}\n"
        if match.owner then message += "Owner: #{match.owner}\n"
        if match.owner == null then message += "Not currently owned\n"
        if match.monopoly then message += "Part of a Monopoly\n"
        if match.monopoly && match.houses < 5 then message += "Current houses: #{match.houses}\n"
        if match.monopoly && match.houses == 5 then message += "Hotel"
        msg.send message
      else 
        msg.send "I don't know that property, check the spelling."
    else
      msg.send 'Start a game first!'


  robot.respond /monopoly jail pay$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'jail'
          msg.send "Sorry, expecting #{turnState} command."
        else
          freeFromJail(players, playerIndex)
          msg.send "#{players[playerIndex].name} pays $50 to exit jail. #{bankerInstructions}"
          robot.brain.set 'monopolyTurnState', 'roll'

  robot.respond /monopoly jail roll$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'jail'
          msg.send "Sorry, expecting #{turnState} command."
        else
          currentRoll = roll()
          jailRolls = updatePlayerInJail(players, playerIndex, currentRoll)
          if currentRoll.doubles
            msg.send "You rolled #{currentRoll.total}, **DOUBLES**! You are free!"
            playTurn(data, players, playerIndex, { current: players[playerIndex], passedGo: false }, { total: currentRoll.total, doubles: false }, msg)
          else if jailRolls < 3
            msg.send "You rolled #{currentRoll.total}, not doubles. Better luck next time."
            robot.brain.set 'monopolyTurnState', 'roll'
            setNextPlayer()
          else if jailRolls == 3
            msg.send "You rolled #{currentRoll.total}, not doubles. Pay $50 to exit jail. Theme Team, once account is updated, \"hsbot monopoly continue\""
            robot.brain.set 'jailRoll', currentRoll.total
            robot.brain.set 'monopolyTurnState', 'continue'

  robot.respond /monopoly continue$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'continue'
          msg.send "Sorry, expecting #{turnState} command."
        else
          rollTotal = robot.brain.get 'jailRoll'
          advancePlayer(players, playerIndex, rollTotal)
          playTurn(data, players, playerIndex, { current: players[playerIndex], passedGo: false }, { total: currentRoll, doubles: false }, msg)
          robot.brain.set 'monopolyTurnState', 'roll'

  robot.respond /monopoly jail card$/i, (msg) ->
    if _.contains(allowedRooms, msg.envelope.room)
      data = robot.brain.get 'monopolyBoard'
      playerIndex = robot.brain.get 'monopolyTurn'
      players = robot.brain.get 'monopolyPlayers'
      jailChanceCardOwner = robot.brain.get 'monopolyChanceJailOwner'
      jailCommunityChestCardOwner = robot.brain.get 'monopolyCommunityChestJailOwner'
      turnState = robot.brain.get 'monopolyTurnState'

      if data
        if turnState != 'jail'
          msg.send 'Sorry, expecting ' + turnState + ' command.'
        else if _.contains([jailChanceCardOwner, jailCommunityChestCardOwner], players[playerIndex].name) && players[playerIndex].inJail
          freeFromJail(players, playerIndex)
          msg.send "You're free!"
          if jailChanceCardOwner == players[playerIndex].name
            robot.brain.set 'monopolyChanceJailOwner', null
          else if jailCommunityChestCardOwner == players[playerIndex].name
            robot.brain.set 'monopolyCommunityChestJailOwner', null
          newRoll = roll()
          robot.brain.set 'monopolyTurnState', 'roll'
          advancePlayer(players, playerIndex, newRoll.total)
          playTurn(data, players, playerIndex, { current: players[playerIndex], passedGo: false }, newRoll, msg)
        else
          msg.send 'You don\'t have a card to use! "hsbot monopoly jail pay" or "hsbot monopoly jail roll"'

  robot.respond /monopoly status$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'
    jailChanceCardOwner = robot.brain.get 'monopolyChanceJailOwner'
    jailCommunityChestCardOwner = robot.brain.get 'monopolyCommunityChestJailOwner'
    turnState = robot.brain.get 'monopolyTurnState'
    accounts = robot.brain.get 'monopolyAccounts'
    playerSummary = ''
    playerLocations = ''

    if data
      if players
        for player in players
          ownedProperties = _.where(data, { owner: player.name })
          playerSummary += "\n#{player.name} owns: "
          locationName = data[player.location].name
          if locationName == 'Visiting Jail' && player.inJail
            playerLocations += "\n#{player.name} is in Jail"
          else 
            playerLocations += "\n#{player.name} is on #{locationName}"
          for property in ownedProperties
            playerSummary += "\n\t#{property.name}"
            if property.houses == 5
              playerSummary += ' (hotel) '
            else if property.monopoly
              plural = ''
              if property.houses != 1 then plural = 's'
              playerSummary += " (monopoly, #{property.houses} house#{plural}) "
            if property.mortgaged
              playerSummary += ' (mortgaged)'
          if !ownedProperties.length
            playerSummary += '0 properties'
          if jailChanceCardOwner == player.name
            playerSummary += '\n\tGet Out Of Jail Free (Chance)'
          if jailCommunityChestCardOwner == player.name
            playerSummary += '\n\tGet Out Of Jail Free (Community Chest)'

      msg.send "Game Status:\n#{playerSummary}"
      
      if accounts
        accountSummary = ''
        for account in accounts
          accountSummary += "\n#{account.name}: $#{account.balance}"
        msg.send "\nAccount Balances:#{accountSummary}"

      msg.send "\nCurrent Position:#{playerLocations}"

      msg.send "\nCurrent turn: #{players[playerIndex].name} #{turnState}"
    else
      msg.send 'No game in progress.'

  # undocumented intentionally, since this would wipe the current game's progress
  robot.respond /monopoly start new game$/i, (msg) ->
    scaleFactor = 1
    robot.brain.set 'monopolyBoard', scaleProperties baseValueProperties, scaleFactor
    robot.brain.set 'monopolyPlayers', [
      { name: 'Delta City', location: 0, inJail: false }
      { name: 'Gotham', location: 0, inJail: false }
      { name: 'DMZ', location: 0, inJail: false }
      { name: 'Houston', location: 0, inJail: false }
      { name: 'Dallas', location: 0, inJail: false }
      { name: 'Monterrey', location: 0, inJail: false }
    ]
    robot.brain.set 'monopolyTurn', 0
    robot.brain.set 'monopolyTurnState', 'roll'
    robot.brain.set 'monopolyChanceJailOwner', null
    robot.brain.set 'monopolyCommunityChestJailOwner', null
    robot.brain.set 'monopolyScaleFactor', scaleFactor
    robot.brain.set 'monopolyHouses', 0
    robot.brain.set 'monopolyHotels', 0

    shuffle 'monopolyChance'
    shuffle 'monopolyCommunityChest'

    msg.send 'Game is up! "hsbot monopoly roll" to begin.'

  # undocumented until this is prettier
  robot.respond /monopoly dump log$/i, (msg) ->
    console.log 'Board:\n', robot.brain.get 'monopolyBoard'
    console.log 'Players:\n', robot.brain.get 'monopolyPlayers'
    console.log 'Current Turn:\n', robot.brain.get 'monopolyTurn'
    console.log 'Turn State:\n', robot.brain.get 'monopolyTurnState'
    console.log 'Chance Jail Card:\n', robot.brain.get 'monopolyChanceJailOwner'
    console.log 'Community Chest Jail Card:\n', robot.brain.get 'monopolyCommunityChestJailOwner'
    console.log 'Jail Roll:\n', robot.brain.get 'monopolyJailRoll'
    console.log 'Chance Deck:\n', robot.brain.get 'monopolyChance'
    console.log 'Community Chest Deck:\n', robot.brain.get 'monopolyCommunityChest'
    console.log 'Scale factor:\n', robot.brain.get 'monopolyScaleFactor'
    console.log 'Houses in use:\n', robot.brain.get 'monopolyHouses'
    console.log 'Hotels in use:\n', robot.brain.get 'monopolyHotels'

  robot.respond /monopoly set scale factor (\d+(\.\d+)?)$/i, (msg) ->
    scaleFactor = msg.match[1]
    data = robot.brain.get 'monopolyBoard'
    if data
      robot.brain.set 'monopolyScaleFactor', scaleFactor
      robot.brain.set 'monopolyBoard', scaleProperties data, scaleFactor
      msg.send 'Scale factor updated.'
    else
      msg.send 'Start a game first!'

  clone = (obj) ->
    return obj  if obj is null or typeof (obj) isnt "object"
    temp = new obj.constructor()
    for key of obj
      temp[key] = clone(obj[key])
    temp

  scaleProperties = (data, scaleFactor) ->
    i = 0
    newData = clone data
    for property in newData
      if property.cost then property.cost = baseValueProperties[i].cost * scaleFactor
      if property.rent then property.rent = baseValueProperties[i].rent * scaleFactor
      if property.house1 then property.house1 = baseValueProperties[i].house1 * scaleFactor
      if property.house1 then property.house2 = baseValueProperties[i].house2 * scaleFactor
      if property.house1 then property.house3 = baseValueProperties[i].house3 * scaleFactor
      if property.house1 then property.house4 = baseValueProperties[i].house4 * scaleFactor
      if property.hotel then property.hotel = baseValueProperties[i].hotel * scaleFactor
      if property.mortgage then property.mortgage = baseValueProperties[i].mortgage * scaleFactor
      if property.houseCost then property.houseCost = baseValueProperties[i].houseCost * scaleFactor
      i++
    newData

  baseValueProperties = [
    { name: "GO! (go)"}
    { name: "Teakwood Avenue", cost: 60, rent: 4, house1: 20, house2: 60, house3: 180, house4: 320, hotel: 450, mortgage: 30, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Community Chest" }
    { name: "Mizzou Avenue", cost: 60, rent: 4, house1: 20, house2: 60, house3: 180, house4: 320, hotel: 450, mortgage: 30, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Income Tax" }
    { name: "Austin Railroad", cost: 200, mortgage: 100, owner: null, mortgaged: false }
    { name: "HFSC Avenue", cost: 100, rent: 6, house1: 30, house2: 90, house3: 270, house4: 400, hotel: 550, mortgage: 50, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Chance" }
    { name: "InfraSource Avenue", cost: 100, rent: 6, house1: 30, house2: 90, house3: 270, house4: 400, hotel: 550, mortgage: 50, houseCost: 50,  owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Parallax Consulting Avenue", cost: 120, rent: 8, house1: 40, house2: 100, house3: 300, house4: 450, hotel: 600, mortgage: 60, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Visiting Jail" }
    { name: "Jabil Place", cost: 140, rent: 10, house1: 50, house2: 150, house3: 450, house4: 625, hotel: 750, mortgage: 70, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Time Copter", cost: 150, owner: null, mortgage: 75, mortgaged: false }
    { name: "Global Resale Avenue", cost: 140, rent: 10, house1: 50, house2: 150, house3: 450, house4: 625, hotel: 750, mortgage: 70, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Thermon Avenue", cost: 160, rent: 12, house1: 60, house2: 180, house3: 500, house4: 700, hotel: 900, mortgage: 80, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Houston Railroad", cost: 200, rent: 25, mortgage: 100, owner: null, mortgaged: false }
    { name: "Modern Woodmen Place", cost: 180, rent: 14, house1: 70, house2: 200, house3: 550, house4: 750, hotel: 950, mortgage: 90, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Community Chest" }
    { name: "Koch S&T Avenue", cost: 180, rent: 14, house1: 70, house2: 200, house3: 550, house4: 750, hotel: 950, mortgage: 90, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Grifols Avenue", cost: 200, rent: 16, house1: 80, house2: 220, house3: 600, house4: 800, hotel: 1000, mortgage: 100, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Free Parking"}
    { name: "Crate & Barrel Avenue", cost: 220, rent: 18, house1: 90, house2: 250, house3: 700, house4: 875, hotel: 1050, mortgage: 110, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Chance" }
    { name: "Emerson Avenue", cost: 220, rent: 18, house1: 90, house2: 250, house3: 700, house4: 875, hotel: 1050, mortgage: 110, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Yeti Avenue", cost: 240, rent: 20, house1: 100, house2: 300, house3: 750, house4: 925, hotel: 1100, mortgage: 120, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Dallas Railroad", cost: 200, rent: 25, mortgage: 100, owner: null, mortgaged: false }
    { name: "Udell Avenue", cost: 260, rent: 22, house1: 110, house2: 330, house3: 800, house4: 975, hotel: 1150, mortgage: 130, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "USAC Avenue", cost: 260, rent: 22, house1: 110, house2: 330, house3: 800, house4: 975, hotel: 1150, mortgage: 130, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "hsbot", cost: 150, mortgage: 75, owner: null, mortgaged: false }
    { name: "USBC Gardens", cost: 280, rent: 24, house1: 120, house2: 360, house3: 850, house4: 1025, hotel: 1200, mortgage: 140, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "(siren) GO TO JAIL! (jail)" }
    { name: "Ed-Fi Avenue", cost: 300, rent: 26, house1: 130, house2: 390, house3: 900, house4: 1100, hotel: 1275, mortgage: 150, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "eMoney Avenue", cost: 300, rent: 26, house1: 130, house2: 390, house3: 900, house4: 1100, hotel: 1275, mortgage: 150, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Community Chest" }
    { name: "3M Avenue", cost: 320, rent: 28, house1: 150, house2: 450, house3: 1000, house4: 1200, hotel: 1400, mortgage: 160, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Monterrey Railroad", cost: 200, rent: 25, mortgage: 100, owner: null, mortgaged: false }
    { name: "Chance" }
    { name: "Ortho Kinematics Place", cost: 350, rent: 35, house1: 175, house2: 500, house3: 1100, house4: 1300, hotel: 1500, mortgage: 175, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
    { name: "Luxury Tax" }
    { name: "SLTX", cost: 400, rent: 50, house1: 200, house2: 600, house3: 1400, house4: 1700, hotel: 2000, mortgage: 200, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
  ]

  chanceCards = [
    { message: "Advance token to nearest utility. If unowned, you may buy it from the bank. If owned, throw dice and pay owner 10 times the amount thrown.", action: goToNearestUtility }
    { message: "GET OUT OF JAIL FREE. This card may be kept until needed, or sold.", action: assignJailCard, value: 'monopolyChanceJailOwner' }
    { message: "Take a Ride on the Austin Railroad. If you pass GO, collect $200. #{bankerInstructions}", action: goToLocation, value: 5 }
    { message: "Kathy pays you dividend of $50. #{bankerInstructions}" }
    { message: "Go back 3 spaces", action: goBackThree }
    { message: "Make general repairs on all of your property. For each house, pay $25. For each hotel, $100. #{bankerInstructions}" }
    { message: "Late to the Monday Morning Meeting. Pay $15. #{bankerInstructions}" }
    { message: "Take a walk on the boardwalk. Advance token to SLTX.", action: goToLocation, value: 39 }
    { message: "Advance token to Jabil Place. If you pass GO, collect $200.", action: goToLocation, value: 11 }
    { message: "Advance token to the nearest Railroad and pay owner twice the rental to which they are otherwise entitled. If Railroad is unowned, you may buy it from the bank.", action: goToNearestRailroad }
    { message: "Your building and loan matures, collect $150. #{bankerInstructions}" }
    { message: "Advance to Yeti Avenue.", action: goToLocation, value: 24 }
    { message: "Advance token to the nearest Railroad and pay owner twice the rental to which they are otherwise entitled. If Railroad is unowned, you may buy it from the bank.", action: goToNearestRailroad }
    { message: "Advance to GO. Collect $200. (go)", action: goToLocation, value: 0 }
    { message: "You have been elected Chairman of the Startup Games. Pay each player $50. #{bankerInstructions}" }
    { message: "(siren) Go directly TO JAIL. Do not pass GO, do not collect $200. (jail)", action: sendToJailCard }
  ]

  communityChestCards = [
    { message: "Xmas fund matures, collect $100. #{bankerInstructions}" }
    { message: "(siren) Go to Jail. Go directly to Jail. Do not pass GO, do not collect $200. (jail)", action: sendToJailCard }
    { message: "Pay Hospital $100. #{bankerInstructions}" }
    { message: "Deran won second prize in a beauty contest. Collect $10. #{bankerInstructions}" }
    { message: "Grand Opera Opening. Collect $50 from every player for opening night seats. #{bankerInstructions}" }
    { message: "From sale of Workify you get $45. #{bankerInstructions}" }
    { message: "Doctor's Fee: pay $50. #{bankerInstructions}" }
    { message: "You are assessed for street repairs. $40 per house, $115 per hotel. #{bankerInstructions}" }
    { message: "Income Tax refund, collect $20. #{bankerInstructions}" }
    { message: "Bank Error in your favor, collect $200. #{bankerInstructions}" }
    { message: "Advance to GO, collect $200. (go)", action: goToLocation, value: 0 }
    { message: "Life Insurance matures, collect $100. #{bankerInstructions}" }
    { message: "Pay school tax of $150. #{bankerInstructions}" }
    { message: "You inherit $100. #{bankerInstructions}" }
    { message: "Receive for services $25. #{bankerInstructions}" }
    { message: "GET OUT OF JAIL FREE. This card may be kept until needed, or sold.", action: assignJailCard, value: 'monopolyCommunityChestJailOwner' }
  ]

  monopolyGroups = [
    [1, 3]
    [6, 8, 9]
    [11, 13, 14]
    [16, 18, 19]
    [21, 23, 24]
    [26, 27, 29]
    [31, 32, 34]
    [37, 39]
  ]
