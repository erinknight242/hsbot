using System.Collections.Generic;
using Hsbot.Slack.Core.Extensions;
using Hsbot.Slack.Core.Random;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public class DeranMessageHandler : MessageHandlerBase
    {
      public DeranMessageHandler(IRandomNumberGenerator randomNumberGenerator) : base(randomNumberGenerator)
      {
      }

      public override string[] TargetedChannels => FunChannels;
      public override bool DirectMentionOnly => false;

      public override double GetHandlerOdds(IncomingMessage message)
      {
        return 0.1;
      }

      public override IEnumerable<CommandDescription> GetSupportedCommands()
      {
        yield break;
      }

      public override IEnumerable<ResponseMessage> Handle(IncomingMessage message)
      {
        yield return message.ReplyToChannel("http://i.imgur.com/reDPhBx.jpg");
      }

      protected override bool ShouldHandle(IncomingMessage message)
      {
        return message.Contains("deran");
      }
    }
}
