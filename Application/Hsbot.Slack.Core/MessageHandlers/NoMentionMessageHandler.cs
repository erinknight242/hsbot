using Hsbot.Slack.Core.Random;

namespace Hsbot.Slack.Core.MessageHandlers
{
  public abstract class NoMentionMessageHandler : MessageHandlerBase
  {
    protected NoMentionMessageHandler(IRandomNumberGenerator randomNumberGenerator) : base(randomNumberGenerator)
    {
    }

    public override bool DirectMentionOnly => false;
  }
}
