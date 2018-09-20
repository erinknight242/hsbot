using System.Collections.Generic;
using Hsbot.Slack.Core.Random;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public abstract class MessageHandlerBase : IMessageHandler
    {
      protected readonly IRandomNumberGenerator RandomNumberGenerator;

      public static string[] FunChannels = {"#general", "#developers", "#austin", "#houston", "#dallas", "#monterrey"};

      /// <summary>
      /// Odds that a handler will run - should be between 0.0 and 1.0.
      /// If less than 1.0, a random roll will happen for each incoming message
      /// to the handler to determine if the handler will actually return any message.
      /// </summary>
      public virtual double GetHandlerOdds(IncomingMessage message)
      {
        //there's a 110% chance this handler will run by default!
        //in other words, we avoid the whole floating-point-error
        //thing by returning a value much greater than 1 to ensure
        //the handler always runs in the default case
        return 1.1;
      }

      public abstract IEnumerable<CommandDescription> GetSupportedCommands();
      public abstract bool DoesHandle(IncomingMessage message);

      protected MessageHandlerBase(IRandomNumberGenerator randomNumberGenerator)
      {
        RandomNumberGenerator = randomNumberGenerator;
      }

      public IEnumerable<ResponseMessage> Handle(IncomingMessage message)
      {
        var handlerOdds = GetHandlerOdds(message);
        if (handlerOdds < 1.0 && RandomNumberGenerator.Generate() > handlerOdds) yield break;

        foreach (var responseMessage in HandleCore(message))
        {
          yield return responseMessage;
        }
      }

      protected abstract IEnumerable<ResponseMessage> HandleCore(IncomingMessage message);
    }
}
