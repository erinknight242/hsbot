# Description:
#   Submit your time on time everyone!  Just a friendly image to add when a certain someone reminds everyone

rooms = [
  process.env.HUBOT_ROOM_HEADSPRING,
  process.env.HUBOT_ROOM_BOTTEST
]


odds  = [1...100]

pics = [
  "https://media.giphy.com/media/A5RlxnMGaf5h6bBdsz/giphy.gif", # Danny DeVito
  "https://media.giphy.com/media/QNv4mKyspa8j6/giphy.gif", # Mad Men
  "https://imgflip.com/gif/2ipx84", # Elf Elevator
  "https://makeagif.com/i/cOFbWG", # Steve Ballmer
  "https://i.imgur.com/V1gXxhL.gif", # Kid dancing on table
  "https://i.imgflip.com/372a6i.jpg", # Ash Ketchem!
  "https://i.imgflip.com/2zdpz4.jpg", # Traffic Cop, Dumb & Dumber
  "https://clockify.me/blog/wp-content/uploads/2019/01/timesheet-meme-20.jpg", # Oprah timesheet
  "https://i.imgflip.com/34h1my.jpg", # Keanu Reeves breathtaking
  "https://i.pinimg.com/originals/f1/30/c9/f130c97120ee10d752ce3b87435c6dcf.png", # The Beek
  "https://clockify.me/blog/wp-content/uploads/2019/01/timesheet-meme-51.jpg", # Braveheart
  "https://www.memesmonkey.com/images/memesmonkey/b3/b373da7676bdb1452b0f699580bf8587.jpeg", # Tennis
  "https://memecrunch.com/meme/4GV8G/bill-murray-timesheet/image.jpg?w=400&c=1", # Bill Murray
  "https://clockify.me/blog/wp-content/uploads/2019/01/timesheet-meme-33.jpg", # most interesting timesheet in the world
  "https://i.imgur.com/0PtfuRw.png", # Zoolander, so hot right now
  "https://i.pinimg.com/236x/bb/e5/20/bbe52050a7550351e4e66d4c56595ced--meme-batman-work-memes.jpg", # Batman hero
  "https://i.imgflip.com/urgdm.jpg", # 99 problems but a timesheet ain't one
  "https://i.imgur.com/mA7ELwI.jpg", # Star Wars
  "http://m.quickmeme.com/img/85/85a715b42634892b459abb4352eb5314030d546fdca072e11154012d10a3544d.jpg", # Evil Raccoon
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxrS5kv5Bo85Dz-1W2FMXX6Sk7CeQDiORgPxwvo3nXUDeE14J6&s", # Finn
  "https://www.memecreator.org/static/images/memes/4059437.jpg", # Timesheets in yo timesheets
  "https://memecreator.org/static/images/memes/4150884.jpg", # Lumberg
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/4.0.0-2.jpg", # Rocky Horror
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/fill-out-your-x83yh5-1-768x432.jpg", # The Office
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/images-1.jpeg", # Geico Camel
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/2.0.0.8.jpg", # Mission Impossible
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/2.0.0.7.jpg", # Dumbledore
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/3b2rz0.jpg", # if you submit, you won't get reminders
  "https://blog-cdn.everhour.com/blog/wp-content/uploads/2019/09/39j0o1-2.jpg", # Drake
  "http://puppy-meme.com/wp-content/uploads/2016/08/1471311487258.png", # Puppy
  "https://preview.redd.it/u0llpg6x3sn41.png?width=500&format=png&auto=webp&s=e4ef8f3414f3a9c3b9ae34710aa3d7a067799d73", # Feel the Bern
  "https://clockify.me/blog/wp-content/uploads/2019/01/timesheet-meme-24-1.jpg", # I'm not saying it's aliens... but it's aliens
  "https://clockify.me/blog/wp-content/uploads/2019/01/timesheet-meme-66.jpg", # Alright alright alright
  "https://www.timecamp.com/blog/wp-content/uploads/2018/10/fill-in-timesheets.jpg", # Darth Vader
  "https://i.pinimg.com/originals/11/7a/be/117abe92096613b88f845d05ae36a643.jpg", # The North remembers
  "http://www.quickmeme.com/img/84/841d5e51ea29e70586a490b891adad4e2bed54c231ff824e75e7241c88139e3b.jpg" # by nap time
]

module.exports = (robot) ->
  robot.hear /submit .*time/i, (msg) ->
    room = msg.envelope.room
    if room in rooms
      val = msg.random odds
      if val > 33
        msg.send "#{pics[val % pics.length]}"
