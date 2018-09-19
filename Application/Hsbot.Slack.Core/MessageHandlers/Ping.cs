using System;
using System.Collections.Generic;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public class Ping : IMessageHandler
    {
      public IEnumerable<CommandDescription> GetSupportedCommands()
      {
        return new[]
        {
          new CommandDescription()
          {
            Command = "ping",
            Description = "Replies to user who sent the message with 'Pong!'"
          }
        };
      }

      public bool DoesHandle(IncomingMessage message)
      {
        return message.BotIsMentioned &&
               message.TargetedText.StartsWith("ping", StringComparison.OrdinalIgnoreCase);
      }

      public IEnumerable<ResponseMessage> Handle(IncomingMessage message)
      {
        yield return message.ReplyToChannel("Pong!");
      }
    }
}
