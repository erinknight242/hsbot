using Hsbot.Slack.Core.Random;

namespace Hsbot.Slack.Core.MessageHandlers
{
    public abstract class DirectMentionMessageHandler : MessageHandlerBase
    {
      protected DirectMentionMessageHandler(IRandomNumberGenerator randomNumberGenerator) : base(randomNumberGenerator)
      {
      }

      public override bool DirectMentionOnly => true;
    }
}
