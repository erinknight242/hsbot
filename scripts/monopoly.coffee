# Description:
#   Interactive Monopoly game
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hsbot monopoly help
#   hsbot monopoly roll
#   hsbot monopoly buy
#   hsbot monopoly auction
#   hsbot monopoly sold (delta city|detroit|dmz|monterrey|houston|dallas) amount
#   hsbot monopoly status
#   hsbot monopoly jail pay
#   hsbot monopoly jail roll
#   hsbot monopoly continue (for after jail rolls failed)
#
# Admin commands:
#   hsbot monopoly start new game - starts a new game from scratch
#   hsbot monopoly board - rough dump of Board object
#   hsbot 
#
# TODO:
# - Chance/Community Chest actions
# - Buy houses/hotels (limited to 32)
# - Sell houses/hotels
# - mortgage property (and no rent while mortgaged; houses sold off at half price)
# - unmortgage property (pay back mortgaged value + 60)
# - prevent invalid commands
# - Trade/barter (monopoly update Property Owner)
# - Sell back property to the bank (half cost), can't have houses on any of that color
# - Bankruptcy (transfer to new owner, pay 10% for mortgages, sell back houses/hotels)
# - Bankrupt to the bank; auction off properties
# - sell get out of jail free cards
# - 10% for income tax (once money is tracked)
# - use SCALE_FACTOR
# - only respond in Monopoly room
# - Free Parking

# Original Monopoly $ amounts will be multiplied by the scale factor to adjust 
# for our game's extra money rewards

_ = require 'underscore'

SCALE_FACTOR = 1.5
bankerInstuctions = '. Theme Team: once account is updated, "hsbot monopoly roll"'

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
    if deckName == 'monopolyChance' && drawnCardIndex == 1 && chanceOwner
      drawnCardIndex = cardIndexArray.pop()
    else if deckName == 'monopolyCommunityChest' && drawnCardIndex == 15 && communityChestOwner
      drawnCardIndex = cardIndexArray.pop()

    if drawnCardIndex == undefined
      newDeck = shuffle(deckName)
      drawnCardIndex = newDeck.pop()
      robot.brain.set deckName, newDeck
    else
      robot.brain.set deckName, cardIndexArray
    drawnCardIndex

  setNextPlayer = () -> 
    players = robot.brain.get 'monopolyPlayers'
    turn = robot.brain.get 'monopolyTurn'
    if !players[turn].doubles
      turn++
    if (turn == players.length)
      turn = 0
    robot.brain.set 'monopolyTurn', turn
    turn

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

  checkForMonopoly = (board, set) ->
    owner = board[set[0]].owner
    monopoly = true
    if (owner == null)
     return false
    for property in set
      if board[property].owner != owner
        monopoly = false
    if monopoly
      for property in set
        board[property].monopoly = true

  updateProperty = (board, players, playerIndex, buyerIndex) ->
    currentIndex = players[playerIndex].location
    current = board[currentIndex]
    current.owner = players[buyerIndex].name
    if (_.contains([1, 3], currentIndex))
      checkForMonopoly(board, [1, 3])
    else if (_.contains([6, 8, 9], currentIndex))
      checkForMonopoly(board, [6, 8, 9])
    else if (_.contains([11, 13, 14], currentIndex))
      checkForMonopoly(board, [11, 13, 14])
    else if (_.contains([16, 18, 19], currentIndex))
      checkForMonopoly(board, [16, 18, 19])
    else if (_.contains([21, 23, 24], currentIndex))
      checkForMonopoly(board, [21, 23, 24])
    else if (_.contains([26, 27, 29], currentIndex))
      checkForMonopoly(board, [26, 27, 29])
    else if (_.contains([31, 32, 34], currentIndex))
      checkForMonopoly(board, [31, 32, 34])
    else if (_.contains([37, 39], currentIndex))
      checkForMonopoly(board, [37, 39])

    robot.brain.set 'monopolyBoard', board

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

  playTurn = (data, players, playerIndex, playerData, currentRoll, msg) ->
    player = players[playerIndex]
    doubles = ', a'
    if currentRoll.doubles
      doubles = ', **DOUBLES**! A'
    msg.send players[playerIndex].name + ' rolls ' + currentRoll.total + 
      doubles + 'dvances to ' + data[player.location].name + '.'
    if playerData.passedGo
      msg.send 'You passed Go, collect $200! (go)'
    
    # Present player with options
    if _.contains([2, 17, 33], player.location)
      # Community Chest
      cardIndex = drawCard('monopolyCommunityChest')
      msg.send communityChestCards[cardIndex].message
      if communityChestCards[cardIndex].action
        msg.send 'TODO: do the action'
      setNextPlayer()
    else if _.contains([7, 22, 36], player.location)
      # Chance
      cardIndex = drawCard('monopolyChance')
      msg.send chanceCards[cardIndex].message
      if chanceCards[cardIndex].action
        msg.send 'TODO: do the action'
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
      msg.send 'Pay $200 to the bank' + bankerInstuctions
      setNextPlayer()
    else if player.location == 38
      # Luxury Tax
      msg.send 'Vasudha needs a new pair of shoes. Pay $75' + bankerInstuctions
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
        msg.send 'This property is available. Buy it for $' + data[player.location].cost + '? ("hsbot monopoly buy" or "hsbot monopoly auction")'
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
          message = owner + ' owns ' + numberOwned + ' railroads. '
        else if _.contains(utilitySet, player.location)
          # Utilities
          numberOwned = 0;
          for utility in utilitySet
            if data[utility].owner == owner
              numberOwned += 1
          owes = 4 * currentRoll.total
          message = owner + ' owns 1 utilitity. '
          if numberOwned == 2
            owes = 10 * currentRoll.total
            message = owner + ' owns 2 utilities. '
        else
          owes = data[player.location].rent
          if data[player.location].houses
            owes = data[player.location]['house' + data[player.location].houses]
          else if data[player.location].monopoly
            owes *= 2
        
        if (data[player.location].owner == player.name)
          msg.send 'You own it! Enjoy your stay. "hsbot monopoly roll" to continue.'
        else
          msg.send message + 'Pay ' + data[player.location].owner + ' $' + owes + bankerInstuctions
        setNextPlayer()
    

  robot.respond /monopoly help$/i, (msg) ->
    msg.send '\thsbot monopoly - commands are coming!'

  robot.respond /monopoly roll$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    if data
      if players[playerIndex].inJail
        msg.send players[playerIndex].name + ', you\'re in jail. You can pay $50 with "hsbot monopoly jail pay" or "hsbot monopoly jail roll" to try your luck'
      else
        # Roll dice for current player & update board
        currentRoll = roll()
        playerData = updatePlayer(players, playerIndex, currentRoll)
        player = playerData.current
        if player.doublesCount == 3
          msg.send players[playerIndex].name + ' rolls ' + currentRoll.total + ', **DOUBLES**! Oh no! You rolled doubles 3 times. Go to Jail. (jail)'
          sendToJail(players, playerIndex)
          setNextPlayer()
        else
          playTurn(data, players, playerIndex, playerData, currentRoll, msg)
    else
      msg.send 'There is no game in progress! (doh)'

  robot.respond /monopoly buy$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    owner = data[players[playerIndex].location].owner
    if owner
      msg.send 'You can\'t buy ' + data[players[playerIndex].location].name + ', ' + owner + ' owns it. Try rolling instead.'
    else if owner == undefined
      msg.send 'You can\'t buy ' + data[players[playerIndex].location].name + ', try rolling instead.'
    else
      msg.send players[playerIndex].name  + ' pays the bank $' + data[players[playerIndex].location].cost + ' for ' +  data[players[playerIndex].location].name + bankerInstuctions
      updateProperty(data, players, playerIndex, playerIndex)
      setNextPlayer()

  robot.respond /monopoly auction$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    msg.send data[players[playerIndex].location].name + ' is up for sale! Discuss your bids below. Once the highest bid has been placed, end by e.g. "hsbot monopoly sold Dallas 150"'

  robot.respond /monopoly sold (delta city|detroit|dmz|monterrey|houston|dallas) \$*(\d+)$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    buyerName = msg.match[1]
    soldPrice = msg.match[2]

    buyerIndex = _.findIndex(players, (player) ->
      player.name.toLowerCase() == buyerName.toLowerCase() 
    )
    msg.send players[buyerIndex].name  + ' pays $' + soldPrice + ' for ' + data[players[playerIndex].location].name + bankerInstuctions
    updateProperty(data, players, playerIndex, buyerIndex)
    setNextPlayer()

  robot.respond /monopoly jail pay$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    freeFromJail(players, playerIndex)
    msg.send players[playerIndex].name + ' pays $50 to exit jail' + bankerInstuctions

  robot.respond /monopoly jail roll$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    currentRoll = roll()
    jailRolls = updatePlayerInJail(players, playerIndex, currentRoll)
    if currentRoll.doubles
      msg.send 'You rolled ' + currentRoll.total + ', **DOUBLES**! You are free!'
      playTurn(data, players, playerIndex, { current: players[playerIndex], passedGo: false }, { total: currentRoll.total, doubles: false }, msg)
    else if jailRolls < 3
      msg.send 'You rolled ' + currentRoll.total + ', not doubles. Better luck next time.'
      setNextPlayer()
    else if jailRolls == 3
      msg.send 'You rolled ' + currentRoll.total + ', not doubles. Pay $50 to exit jail. Theme Team, once account is updated, "hsbot monopoly continue"'
      robot.brain.set 'jailRoll', currentRoll.total

  robot.respond /monopoly continue$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'
    currentRoll = robot.brain.get 'jailRoll'
    advancePlayer(players, playerIndex, currentRoll)
    playTurn(data, players, playerIndex, { current: players[playerIndex], passedGo: false }, { total: currentRoll, doubles: false }, msg)


  robot.respond /monopoly status$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'
    playerSummary = ''
    playerLocations = ''

    for player in players
      ownedProperties = _.where(data, { owner: player.name })
      playerSummary += '\n' + player.name + ' owns: '
      locationName = data[player.location].name
      if locationName == 'Visiting Jail' && player.inJail
        playerLocations += '\n' + player.name + ' is in Jail'
      else 
        playerLocations += '\n' + player.name + ' is on ' + locationName
      for property in ownedProperties
        playerSummary += '\n\t' + property.name
        if property.houses == 5
          playerSummary += ' (hotel) '
        else if property.monopoly
          playerSummary += ' (monopoly, ' + property.houses + ' houses) '
        if property.mortgaged
          playerSummary += '(mortgaged)'
      if !ownedProperties.length
        playerSummary += '0 properties'

    msg.send 'Game Status:\n' + playerSummary
    
    msg.send '\nCurrent Position:' + playerLocations

    msg.send '\nCurrent turn: ' + players[playerIndex].name

  # undocumented intentionally, since this would wipe the game's progress
  robot.respond /monopoly start new game$/i, (msg) ->
    robot.brain.set 'monopolyBoard', [
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
    robot.brain.set 'monopolyPlayers', [
      { name: 'Delta City', location: 0, inJail: false }
      { name: 'Gotham', location: 0, inJail: false }
      { name: 'DMZ', location: 0, inJail: false }
      { name: 'Houston', location: 0, inJail: false }
      { name: 'Dallas', location: 0, inJail: false }
      { name: 'Monterrey', location: 0, inJail: false }
    ]
    robot.brain.set 'monopolyTurn', 0
    robot.brain.set 'monopolyChanceJailOwner', null
    robot.brain.set 'monopolyCommunityChestJailOwner', null

    shuffle('monopolyChance')
    shuffle('monopolyCommunityChest')

  # undocumented until this is prettier
  robot.respond /monopoly board$/i, (msg) ->
    console.log robot.brain.get 'monopolyBoard'

  goToNearestUtility = () ->
    todo = ''

  assignJailCard = () ->
    todo = ''

  goToLocation = (index) ->
    todo = ''

  goBackThree = () ->
    todo = ''

  goToNearestRailroad = () ->
    todo = ''

  sendToJailCard = () ->
    todo = ''

  chanceCards = [
    { message: 'Advance token to nearest utility. If unowned, you may buy it from the bank. If owned, throw dice and pay owner 10 times the amount thrown.', action: goToNearestUtility }
    { message: 'GET OUT OF JAIL FREE. This card may be kept until needed, or sold.', action: assignJailCard }
    { message: 'Take a Ride on the Austin Railroad. If you pass GO, collect $200.', action: goToLocation, value: 5 }
    { message: 'Kathy pays you dividend of $50' }
    { message: 'Go back 3 spaces', action: goBackThree }
    { message: 'Make general repairs on all of your property. For each house, pay $25. For each hotel, $100.' }
    { message: 'Pay poor tax of $15.' }
    { message: 'Take a walk on the boardwalk. Advance token to SLTX.', action: goToLocation, value: 39 }
    { message: 'Advance token to Jabil Place. If you pass GO, collect $200.', action: goToLocation, value: 0 }
    { message: 'Advance token to the nearest Railroad and pay owner twice the rental to which they are otherwise entitled. If Railroad is unowned, you may buy it from the bank.', action: goToNearestRailroad }
    { message: 'Your building and loan matures, collect $150' }
    { message: 'Advance to Yeti Avenue.', action: goToLocation, value: 24 }
    { message: 'Advance token to the nearest Railroad and pay owner twice the rental to which they are otherwise entitled. If Railroad is unowned, you may buy it from the bank.', action: goToNearestRailroad }
    { message: 'Advance to GO. Collect $200. (go)', action: goToLocation, value: 0 }
    { message: 'You have been elected Chairman of the Startup Games. Pay each player $50.' }
    { message: '(siren) Go directly TO JAIL. Do not pass GO, do not collect $200. (jail)', action: sendToJailCard }
  ]

  communityChestCards = [
    { message: 'Xmas fund matures, collect $100' }
    { message: '(siren) Go to Jail. Go directly to Jail. Do not pass GO, do not collect $200. (jail)', action: sendToJailCard }
    { message: 'Pay Hospital $100.' }
    { message: 'Deran won second prize in a beauty contest. Collect $10.' }
    { message: 'Grand Opera Opening. Collect $50 from every player for opening night seats.' }
    { message: 'From sale of Workify you get $45.' }
    { message: 'Doctor\'s Fee: pay $50' }
    { message: 'You are assessed for street repairs. $40 per house, $115 per hotel.' }
    { message: 'Income Tax refund, collect $20.' }
    { message: 'Bank Error in your favor, collect $200.' }
    { message: 'Advance to GO, collect $200. (go)', action: goToLocation, value: 0 }
    { message: 'Life Insurance matures, collect $100' }
    { message: 'Pay school tax of $150' }
    { message: 'You inherit $100' }
    { message: 'Receive for services $25' }
    { message: 'GET OUT OF JAIL FREE. This card may be kept until needed, or sold.', action: assignJailCard }
  ]