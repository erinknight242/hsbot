# Description:
#   Interacts with the Yahoo API to pull stock quotes.
#
# Commands:
#   hubot stock quote <query> - Returns quotes for the space delimited stock symbol(s) in the query


getUrl = (stock_symbols) ->
  url = 'http://query.yahooapis.com/v1/public/yql?format=json&env=http://datatables.org/alltables.env&q=select * from yahoo.finance.quotes where symbol in ("{0}")'
  url.replace("{0}", stock_symbols.join('", "').toUpperCase())


toFriendlyText = (quote) ->
  "#{quote.Name} (#{quote.Symbol}) is at $#{quote.LastTradePriceOnly} (#{quote.Change}, #{quote.PercentChange}) - http://finance.yahoo.com/q?s=#{quote.Symbol}"


pullQuotes = (data) ->
  quotes = if data.query.count > 1 then data.query.results.quote else [data.query.results.quote]
  (toFriendlyText(quote) for quote in quotes)


module.exports = (robot) ->

  robot.respond /stock quote (.+)/i, (msg) ->
    stock_symbols = (item for item in msg.match[1].replace(/\./, "-").split ' ' when item.length > 0)
    
    msg.http(getUrl(stock_symbols))
      .get() (err, res, body) ->
        if err          
          robot.logger.error err
          msg.send "I have failed you (sadpanda)"
          return

        try           
          msg.send item for item in pullQuotes(JSON.parse body)
        catch error
          robot.logger.error error
          msg.send "I have failed you (sadpanda)"


