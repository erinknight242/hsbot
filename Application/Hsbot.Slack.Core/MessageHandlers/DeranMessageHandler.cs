using System.Collections.Generic;
using Hsbot.Slack.Core.Extensions;
using Hsbot.Slack.Core.Random;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public class DeranMessageHandler : NoMentionMessageHandler
    {
      public DeranMessageHandler(IRandomNumberGenerator randomNumberGenerator) : base(randomNumberGenerator)
      {
      }

      public override double GetHandlerOdds(IncomingMessage message)
      {
        return 0.1;
      }

      public override IEnumerable<CommandDescription> GetSupportedCommands()
      {
        yield break;
      }

      protected override IEnumerable<ResponseMessage> HandleCore(IncomingMessage message)
      {
        yield return message.ReplyToChannel("http://i.imgur.com/reDPhBx.jpg");
      }

      protected override bool ShouldHandle(IncomingMessage message)
      {
        return message.Contains("deran") && message.IsForChannel(FunChannels);
      }
    }
}
