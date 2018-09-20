using System.Collections.Generic;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.MessageHandlers
{
  public abstract class NoMentionMessageHandler : IMessageHandler
  {
    public bool DoesHandle(IncomingMessage message)
    {
      return !message.BotIsMentioned && ShouldHandle(message);
    }

    protected abstract bool ShouldHandle(IncomingMessage message);
    public abstract IEnumerable<CommandDescription> GetSupportedCommands();
    public abstract IEnumerable<ResponseMessage> Handle(IncomingMessage message);
  }
}
