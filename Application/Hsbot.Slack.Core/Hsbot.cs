using SlothBot;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core
{
  public class Hsbot : SlothBot.SlothBot
  {
    public Hsbot(ISlackConfig slackConfig,
      ISlothLog log,
      IMessageHandler[] messageHandlers = null,
      IPlugin[] plugins = null)
      : base(slackConfig, log, messageHandlers, plugins)
    {
    }
  }
}
