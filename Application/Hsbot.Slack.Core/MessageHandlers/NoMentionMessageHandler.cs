using Hsbot.Slack.Core.Random;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
  public abstract class NoMentionMessageHandler : MessageHandlerBase
  {
    protected NoMentionMessageHandler(IRandomNumberGenerator randomNumberGenerator) : base(randomNumberGenerator)
    {
    }

    public override bool DoesHandle(IncomingMessage message)
    {
      return !message.BotIsMentioned && ShouldHandle(message);
    }

    protected abstract bool ShouldHandle(IncomingMessage message);
  }
}
