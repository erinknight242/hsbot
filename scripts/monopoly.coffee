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
#
# Admin commands:
#   hsbot monopoly start new game - starts a new game from scratch
#   hsbot monopoly board - rough dump of Board object
#   hsbot 
#
# TODO:
# - Chance
# - Community Chest
# - Go to Jail
# - Rolling 3 doubles -> Jail
# - Get out of jail (pay $50, roll doubles)
# - Buy houses/hotels (limited to 32)
# - Sell houses/hotels
# - mortgage property (and no rent while mortgaged; houses sold off at half price)
# - unmortgage property (pay back mortgaged value + 60)
# - prevent invalid commands
# - Trade/barter (monopoly update Property Owner)
# - Sell back property to the bank (half cost), can't have houses on any of that color
# - Bankruptcy (transfer to new owner, pay 10% for mortgages, sell back houses/hotels)
# - Bankrupt to the bank; auction off properties
# - monopoly status (who owns what, where are they, how many houses)
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

roll = () =>
  total = 0
  rolls = for number in [1..2]
    result = Math.floor(Math.random() * 6) + 1
    total += result
    result

  total: total
  rolls: rolls
  doubles: rolls[0] == rolls[1]

module.exports = (robot) ->

  setNextPlayer = () -> 
    players = robot.brain.get 'monopolyPlayers'
    turn = robot.brain.get 'monopolyTurn'
    if !players[turn].doubles
      turn++
    if (turn == players.length)
      turn = 0
    robot.brain.set 'monopolyTurn', turn
    turn

  updatePlayer = (players, playerIndex, roll) ->
    current = players[playerIndex]
    current.location += roll.total
    current.location = 12
    current.doubles = roll.doubles
    passedGo = false
    if (current.location > 39)
      current.location = current.location - 40
      passedGo = true

    robot.brain.set 'monopolyPlayers', players
    
    current: current
    passedGo: passedGo

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

  robot.respond /monopoly help$/i, (msg) ->
    msg.send '\thsbot monopoly - commands are coming!'

  # undocumented intentionally, since this would wipe the game's progress
  robot.respond /monopoly start new game$/i, (msg) ->
    robot.brain.set 'monopolyBoard', [
      { name: "GO! (go)", rent: 0 }
      { name: "Teakwood Avenue", cost: 60, rent: 4, house1: 20, house2: 60, house3: 180, house4: 320, hotel: 450, mortgage: 30, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Community Chest", rent: 0 }
      { name: "Mizzou Avenue", cost: 60, rent: 4, house1: 20, house2: 60, house3: 180, house4: 320, hotel: 450, mortgage: 30, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Income Tax", rent: '10% or $200', owner: 'the Bank' }
      { name: "Austin Railroad", cost: 200, mortgage: 100, owner: null, mortgaged: false }
      { name: "HFSC Avenue", cost: 100, rent: 6, house1: 30, house2: 90, house3: 270, house4: 400, hotel: 550, mortgage: 50, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Chance", rent: 0 }
      { name: "InfraSource Avenue", cost: 100, rent: 6, house1: 30, house2: 90, house3: 270, house4: 400, hotel: 550, mortgage: 50, houseCost: 50,  owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Parallax Consulting Avenue", cost: 120, rent: 8, house1: 40, house2: 100, house3: 300, house4: 450, hotel: 600, mortgage: 60, houseCost: 50, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Visiting Jail", rent: 0 }
      { name: "Jabil Place", cost: 140, rent: 10, house1: 50, house2: 150, house3: 450, house4: 625, hotel: 750, mortgage: 70, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Time Copter", owner: 'DMZ', mortgage: 75, mortgaged: false }
      { name: "Global Resale Avenue", cost: 140, rent: 10, house1: 50, house2: 150, house3: 450, house4: 625, hotel: 750, mortgage: 70, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Thermon Avenue", cost: 160, rent: 12, house1: 60, house2: 180, house3: 500, house4: 700, hotel: 900, mortgage: 80, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Houston Railroad", cost: 200, rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "Modern Woodmen Place", cost: 180, rent: 14, house1: 70, house2: 200, house3: 550, house4: 750, hotel: 950, mortgage: 90, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Community Chest", rent: 0 }
      { name: "Koch S&T Avenue", cost: 180, rent: 14, house1: 70, house2: 200, house3: 550, house4: 750, hotel: 950, mortgage: 90, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Grifols Avenue", cost: 200, rent: 16, house1: 80, house2: 220, house3: 600, house4: 800, hotel: 1000, mortgage: 100, houseCost: 100, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Free Parking", rent: 0 }
      { name: "Crate & Barrel Avenue", cost: 220, rent: 18, house1: 90, house2: 250, house3: 700, house4: 875, hotel: 1050, mortgage: 110, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Chance", rent: 0 }
      { name: "Emerson Avenue", cost: 220, rent: 18, house1: 90, house2: 250, house3: 700, house4: 875, hotel: 1050, mortgage: 110, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Yeti Avenue", cost: 240, rent: 20, house1: 100, house2: 300, house3: 750, house4: 925, hotel: 1100, mortgage: 120, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Dallas Railroad", cost: 200, rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "Udell Avenue", cost: 260, rent: 22, house1: 110, house2: 330, house3: 800, house4: 975, hotel: 1150, mortgage: 130, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "USAC Avenue", cost: 260, rent: 22, house1: 110, house2: 330, house3: 800, house4: 975, hotel: 1150, mortgage: 130, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "hsbot", mortgage: 75, owner: 'DMZ', mortgaged: false }
      { name: "USBC Gardens", cost: 280, rent: 24, house1: 120, house2: 360, house3: 850, house4: 1025, hotel: 1200, mortgage: 140, houseCost: 150, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "GO TO JAIL! (jail)", rent: 0 }
      { name: "Ed-Fi Avenue", cost: 300, rent: 26, house1: 130, house2: 390, house3: 900, house4: 1100, hotel: 1275, mortgage: 150, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "eMoney Avenue", cost: 300, rent: 26, house1: 130, house2: 390, house3: 900, house4: 1100, hotel: 1275, mortgage: 150, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Community Chest", rent: 0 }
      { name: "3M Avenue", cost: 320, rent: 28, house1: 150, house2: 450, house3: 1000, house4: 1200, hotel: 1400, mortgage: 160, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Monterrey Railroad", cost: 200, rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "Chance", rent: 0 }
      { name: "Ortho Kinematics Place", cost: 350, rent: 35, house1: 175, house2: 500, house3: 1100, house4: 1300, hotel: 1500, mortgage: 175, houseCost: 200, owner: null, houses: 0, mortgaged: false, monopoly: false }
      { name: "Luxury Tax", rent: 75, owner: 'the Bank' }
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

  # undocumented until this is prettier
  robot.respond /monopoly board$/i, (msg) ->
    console.log robot.brain.get 'monopolyBoard'

  robot.respond /monopoly roll$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    if data
      # Roll dice for current player & update board
      currentRoll = roll()
      playerData = updatePlayer(players, playerIndex, currentRoll)
      player = playerData.current
      doubles = ', a'
      if currentRoll.doubles
        doubles = ', doubles! A'
      msg.send players[playerIndex].name + ' rolls ' + currentRoll.total + 
        doubles + 'dvances to ' + data[player.location].name + '.'
      if playerData.passedGo
        msg.send 'You passed Go, collect $200! (go)'
      
      # Present player with options
      if _.contains([2, 17, 33], player.location)
        # TODO: Community Chest
        setNextPlayer()
      else if _.contains([7, 22, 36], player.location)
        # TODO: Chance
        setNextPlayer()
      else if player.location == 0
        # Go
        setNextPlayer()
      else if player.location == 30
        # TODO: Go to Jail
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

    else
      msg.send 'There is no game in progress! (doh)'

  robot.respond /monopoly buy$/i, (msg) ->
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

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
    msg.send players[buyerIndex].name  + ' pays the bank $' + soldPrice + ' for ' + data[players[playerIndex].location].name + bankerInstuctions
    updateProperty(data, players, playerIndex, buyerIndex)
    setNextPlayer()