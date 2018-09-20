using System.Collections.Generic;
using System.Linq;
using SlothBot;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core
{
  public class Hsbot : SlothBot.SlothBot
  {
    public Hsbot(ISlackConfig slackConfig,
      ISlothLog log,
      IEnumerable<IMessageHandler> messageHandlers,
      IEnumerable<IPlugin> plugins = null)
      : base(slackConfig, log, messageHandlers?.ToArray(), plugins?.ToArray())
    {
    }
  }
}
