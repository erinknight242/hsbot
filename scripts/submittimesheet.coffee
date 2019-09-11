# Description:
#   Submit your time on time everyone!  Just a friendly image to add when a certain someone reminds everyone

rooms = [
  process.env.HUBOT_ROOM_HEADSPRING
]


odds  = [1...100]

pics = [
  "https://media.giphy.com/media/A5RlxnMGaf5h6bBdsz/giphy.gif", # Danny DeVito
  "https://media.giphy.com/media/QNv4mKyspa8j6/giphy.gif", # Mad Men
  "https://media.giphy.com/media/mD6u5lgvneVag/giphy.gif", # Terry Tate
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
  "https://photo-invivo.com/wp-content/uploads/2019/03/submit-timesheet-meme-great-time-sheet-meme-heartpulsar-of-submit-timesheet-meme.jpg", # Brady Bunch
  "https://i.pinimg.com/236x/bb/e5/20/bbe52050a7550351e4e66d4c56595ced--meme-batman-work-memes.jpg", # Batman hero
  "https://i.imgflip.com/urgdm.jpg", # 99 problems but a timesheet ain't one
  "https://i.imgur.com/mA7ELwI.jpg", # Star Wars
  "http://m.quickmeme.com/img/85/85a715b42634892b459abb4352eb5314030d546fdca072e11154012d10a3544d.jpg", # Evil Raccoon
  "https://photo-invivo.com/wp-content/uploads/2019/03/timesheets-due-meme-lovely-timesheet-reminder-meme-to-pin-on-pinterest-of-timesheets-due-meme.jpg", # Matrix
  "https://photo-invivo.com/wp-content/uploads/2019/03/timesheets-due-meme-beautiful-oh-sith-timesheets-are-due-today-timesheet-boyega-of-timesheets-due-meme.jpg", # Finn
  "https://www.memecreator.org/static/images/memes/4059437.jpg", # Timesheets in yo timesheets
  "https://photo-invivo.com/wp-content/uploads/2019/03/submit-timesheet-meme-new-wants-your-timesheet-by-friday-wont-look-at-it-till-next-of-submit-timesheet-meme.jpg" # Lumberg
]

module.exports = (robot) ->
  robot.hear /submit .*time/i, (msg) ->
    room = msg.envelope.user.reply_to
    if room in rooms
      val = msg.random odds
      if val > 33
        msg.send "#{pics[val % pics.length]}"
