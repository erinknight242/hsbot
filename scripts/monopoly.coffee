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
#   hsbot monopoly start new game - starts a new game from scratch
#

# Original Monopoly $ amounts will be multiplied by the scale factor to adjust 
# for our game's extra money rewards

_ = require 'underscore'

SCALE_FACTOR = 1.5

roll = () =>
  total = 0
  rolls = for number in [1..2]
    result = Math.floor(Math.random() * 6) + 1
    total += result
    result

  total: total
  rolls: rolls

module.exports = (robot) ->

  setNextPlayer = () -> 
    players = robot.brain.get 'monopolyPlayers'
    turn = robot.brain.get 'monopolyTurn'
    turn++
    if (turn == players.length)
      turn = 0
    robot.brain.set 'monopolyTurn', turn

  updatePlayer = (players, playerIndex, roll) ->
    current = players[playerIndex]
    current.location += roll
    passedGo = false
    if (current.location > 39)
      current.location = current.location - 40
      passedGo = true

    robot.brain.set 'monopolyPlayers', players
    
    current: current
    passedGo: passedGo

  robot.respond /monopoly help$/i, (msg) ->
    msg.send "\thsbot monopoly - commands are coming!"

  robot.respond /monopoly start new game$/i, (msg) ->
    robot.brain.set 'monopolyBoard', [
      { name: "GO! (go)", rent: 0 }
      { name: "Teakwood Avenue", rent: 4, house1: 20, house2: 60, house3: 180, house4: 320, hotel: 450, mortgage: 30, houseCost: 50, owner: null, houses: 0, mortgaged: false }
      { name: "Community Chest", rent: 0 }
      { name: "Mizzou Avenue", rent: 4, house1: 20, house2: 60, house3: 180, house4: 320, hotel: 450, mortgage: 30, houseCost: 50, owner: null, houses: 0, mortgaged: false }
      { name: "Income Tax", rent: '10% or $200', owner: 'the Bank' }
      { name: "Austin Railroad", rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "HFSC Avenue", rent: 6, house1: 30, house2: 90, house3: 270, house4: 400, hotel: 550, mortgage: 50, houseCost: 50, owner: null, houses: 0, mortgaged: false }
      { name: "Chance", rent: 0 }
      { name: "InfraSource Avenue", rent: 6, house1: 30, house2: 90, house3: 270, house4: 400, hotel: 550, mortgage: 50, houseCost: 50,  owner: null, houses: 0, mortgaged: false }
      { name: "Parallax Consulting Avenue", rent: 8, house1: 40, house2: 100, house3: 300, house4: 450, hotel: 600, mortgage: 60, houseCost: 50, owner: null, houses: 0, mortgaged: false }
      { name: "Visiting Jail", rent: 0 }
      { name: "Jabil Place", rent: 10, house1: 50, house2: 150, house3: 450, house4: 625, hotel: 750, mortgage: 70, houseCost: 100, owner: null, houses: 0, mortgaged: false }
      { name: "Time Copter", rent: '4x dice roll, or 10x dice roll', owner: null, mortgage: 75, mortgaged: false }
      { name: "Global Resale Avenue", rent: 10, house1: 50, house2: 150, house3: 450, house4: 625, hotel: 750, mortgage: 70, houseCost: 100, owner: null, houses: 0, mortgaged: false }
      { name: "Thermon Avenue", rent: 12, house1: 60, house2: 180, house3: 500, house4: 700, hotel: 900, mortgage: 80, houseCost: 100, owner: null, houses: 0, mortgaged: false }
      { name: "Houston Railroad", rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "Modern Woodmen Place", rent: 14, house1: 70, house2: 200, house3: 550, house4: 750, hotel: 950, mortgage: 90, houseCost: 100, owner: null, houses: 0, mortgaged: false }
      { name: "Community Chest", rent: 0 }
      { name: "Koch S&T Avenue", rent: 14, house1: 70, house2: 200, house3: 550, house4: 750, hotel: 950, mortgage: 90, houseCost: 100, owner: null, houses: 0, mortgaged: false }
      { name: "Grifols Avenue", rent: 16, house1: 80, house2: 220, house3: 600, house4: 800, hotel: 1000, mortgage: 100, houseCost: 100, owner: null, houses: 0, mortgaged: false }
      { name: "Free Parking", rent: 0 }
      { name: "Crate & Barrel Avenue", rent: 18, house1: 90, house2: 250, house3: 700, house4: 875, hotel: 1050, mortgage: 110, houseCost: 150, owner: null, houses: 0, mortgaged: false }
      { name: "Chance", rent: 0 }
      { name: "Emerson Avenue", rent: 18, house1: 90, house2: 250, house3: 700, house4: 875, hotel: 1050, mortgage: 110, houseCost: 150, owner: null, houses: 0, mortgaged: false }
      { name: "Yeti Avenue", rent: 20, house1: 100, house2: 300, house3: 750, house4: 925, hotel: 1100, mortgage: 120, houseCost: 150, owner: null, houses: 0, mortgaged: false }
      { name: "Dallas Railroad", rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "Udell Avenue", rent: 22, house1: 110, house2: 330, house3: 800, house4: 975, hotel: 1150, mortgage: 130, houseCost: 150, owner: null, houses: 0, mortgaged: false }
      { name: "USAC Avenue", rent: 22, house1: 110, house2: 330, house3: 800, house4: 975, hotel: 1150, mortgage: 130, houseCost: 150, owner: null, houses: 0, mortgaged: false }
      { name: "hsbot", rent: '4x dice roll, or 10x dice roll', mortgage: 75, owner: null, mortgaged: false }
      { name: "USBC Gardens", rent: 24, house1: 120, house2: 360, house3: 850, house4: 1025, hotel: 1200, mortgage: 140, houseCost: 150, owner: null, houses: 0, mortgaged: false }
      { name: "GO TO JAIL! (jail)", rent: 0 }
      { name: "Ed-Fi Avenue", rent: 26, house1: 130, house2: 390, house3: 900, house4: 1100, hotel: 1275, mortgage: 150, houseCost: 200, owner: null, houses: 0, mortgaged: false }
      { name: "eMoney Avenue", rent: 26, house1: 130, house2: 390, house3: 900, house4: 1100, hotel: 1275, mortgage: 150, houseCost: 200, owner: null, houses: 0, mortgaged: false }
      { name: "Community Chest", rent: 0 }
      { name: "3M Avenue", rent: 28, house1: 150, house2: 450, house3: 1000, house4: 1200, hotel: 1400, mortgage: 160, houseCost: 200, owner: null, houses: 0, mortgaged: false }
      { name: "Monterrey Railroad", rent: 25, mortgage: 100, owner: null, mortgaged: false }
      { name: "Chance", rent: 0 }
      { name: "Ortho Kinematics Place", rent: 35, house1: 175, house2: 500, house3: 1100, house4: 1300, hotel: 1500, mortgage: 175, houseCost: 200, owner: null, houses: 0, mortgaged: false }
      { name: "Luxury Tax", rent: 75, owner: 'the Bank' }
      { name: "SLTX", rent: 50, house1: 200, house2: 600, house3: 1400, house4: 1700, hotel: 2000, mortgage: 200, houseCost: 200, owner: null, houses: 0, mortgaged: false }
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

  robot.respond /monopoly roll$/i, (msg) =>
    data = robot.brain.get 'monopolyBoard'
    playerIndex = robot.brain.get 'monopolyTurn'
    players = robot.brain.get 'monopolyPlayers'

    if data
      currentRoll = roll()
      playerData = updatePlayer(players, playerIndex, currentRoll.total)
      player = playerData.current
      msg.send players[playerIndex].name + ' rolls ' + currentRoll.total + ' (' + currentRoll.rolls[0] + ', ' + currentRoll.rolls[1] + '), advances to ' + data[player.location].name + '.'
      if playerData.passedGo
        msg.send 'You passed Go, collect $200! (go)'
      setNextPlayer()
      if _.contains([2, 17, 33], player.location)
        # TODO: Community Chest
      else if _.contains([7, 22, 36], player.location)
        # TODO: Chance
      else if player.location == 0
        # TODO: Go
      else if player.location == 30
        # TODO: Go to Jail
      else if _.contains([5, 15, 25, 35], player.location)
        # TODO: Railroad
      else if _.contains([12, 28], player.location)
        # TODO: Utility
      else if player.location == 4
        # TODO: Income Tax
      else if player.location == 38
        # TODO: Luxury Tax
      else if player.location == 20
        # TODO: Free Parking
      else 
        # TODO: Regular property
    else
      msg.send 'There is no game in progress! (doh)'