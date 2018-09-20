using System;
using System.Collections.Generic;
using System.Linq;
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
      /// Determines if message.TargetedText contains the supplied string (case insensitive)
      /// </summary>
      /// <returns>True if message.TargetedText contains the supplied string, false otherwise</returns>
      public static bool Contains(this IncomingMessage message, string text)
      {
        return message.TargetedText.ToLowerInvariant().Contains(text.ToLowerInvariant());
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

      /// <summary>
      /// Checks if a message was sent to a specific channel
      /// </summary>
      /// <returns>True if message was sent to target channel, false otherwise</returns>
      public static bool IsForChannel(this IncomingMessage message, string channel)
      {
        return message.Channel.Equals(channel, StringComparison.OrdinalIgnoreCase);
      }

      /// <summary>
      /// Checks if a message was sent to a specific channel
      /// </summary>
      /// <returns>True if message was sent to any of the given target channels, false otherwise</returns>
      public static bool IsForChannel(this IncomingMessage message, IEnumerable<string> channels)
      {
        return channels.Any(channel => message.IsForChannel(channel));
      }
    }
}
