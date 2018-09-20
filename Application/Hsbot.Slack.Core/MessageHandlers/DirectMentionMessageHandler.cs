using Hsbot.Slack.Core.Random;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public abstract class DirectMentionMessageHandler : MessageHandlerBase
    {
      protected DirectMentionMessageHandler(IRandomNumberGenerator randomNumberGenerator) : base(randomNumberGenerator)
      {
      }

      public override bool DoesHandle(IncomingMessage message)
      {
        return message.BotIsMentioned && ShouldHandle(message);
      }

      protected abstract bool ShouldHandle(IncomingMessage message);
    }
}
