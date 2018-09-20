using Microsoft.Extensions.Logging;
using SlothBot;

namespace Hsbot.Slack.Web
{
    public class HsbotLog : ISlothLog
    {
      private readonly ILogger _logger;

      public HsbotLog(ILogger<HsbotLog> logger)
      {
        _logger = logger;
      }

      public void Info(string message, params object[] args)
      {
        _logger.LogInformation(message, args);
      }

      public void Error(string message, params object[] args)
      {
        _logger.LogError(message, args);
      }

      public void Warn(string message, params object[] args)
      {
        _logger.LogWarning(message, args);
      }
    }
}
