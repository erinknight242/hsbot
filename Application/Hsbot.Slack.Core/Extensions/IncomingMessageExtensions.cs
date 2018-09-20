using System;
using System.Text.RegularExpressions;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Core.Extensions
{
    public static class IncomingMessageExtensions
    {
      /// <summary>
      /// Determines if message.TargetedText starts with supplied string, subject to string comparison rules (case insensitive by default)
      /// </summary>
      /// <returns>True if message.TargetedText starts with the supplied string, false otherwise</returns>
      public static bool StartsWith(this IncomingMessage message, string start, StringComparison compareType = StringComparison.OrdinalIgnoreCase)
      {
        return message.TargetedText.StartsWith(start, compareType);
      }

      /// <summary>
      /// Applies regular expression to message.TargetedText to determine if message matches
      /// </summary>
      /// <returns>True if message.TargetedText is matched by regex, false otherwise</returns>
      public static bool IsMatch(this IncomingMessage message, Regex matchRegex)
      {
        return matchRegex.IsMatch(message.TargetedText);
      }

      /// <summary>
      /// Applies regular expression to message.TargetedText to determine if message matches
      /// </summary>
      /// <returns>Match object with first match in message.TargetedText</returns>
      public static Match Match(this IncomingMessage message, Regex matchRegex)
      {
        return matchRegex.Match(message.TargetedText);
      }
    }
}
