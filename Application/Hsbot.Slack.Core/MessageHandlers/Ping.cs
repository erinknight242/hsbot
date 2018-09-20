using System;
using System.Collections.Generic;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public class Ping : DirectMentionMessageHandler
    {
      public override IEnumerable<CommandDescription> GetSupportedCommands()
      {
        return new[]
        {
          new CommandDescription
          {
            Command = "ping",
            Description = "Replies to user who sent the message with 'Pong!'"
          }
        };
      }

      protected override bool ShouldHandle(IncomingMessage message)
      {
        return message.TargetedText.StartsWith("ping", StringComparison.OrdinalIgnoreCase);
      }

      public override IEnumerable<ResponseMessage> Handle(IncomingMessage message)
      {
        yield return message.ReplyToChannel("Pong!");
      }
    }
}
