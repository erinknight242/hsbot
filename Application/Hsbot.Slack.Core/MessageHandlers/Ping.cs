using System.Collections.Generic;
using Hsbot.Slack.Core.Extensions;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public class Ping : DirectMentionMessageHandler
    {
      private const string CommandText = "ping";

      public override IEnumerable<CommandDescription> GetSupportedCommands()
      {
        return new[]
        {
          new CommandDescription
          {
            Command = CommandText,
            Description = "Replies to user who sent the message with 'Pong!'"
          }
        };
      }

      protected override bool ShouldHandle(IncomingMessage message)
      {
        return message.StartsWith(CommandText);
      }

      public override IEnumerable<ResponseMessage> Handle(IncomingMessage message)
      {
        yield return message.ReplyToChannel("Pong!");
      }
    }
}
