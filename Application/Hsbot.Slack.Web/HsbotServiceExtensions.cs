using System.Linq;
using System.Reflection;
using Hsbot.Slack.Core;
using Microsoft.Extensions.DependencyInjection;
using SlothBot;
using SlothBot.MessagingPipeline;

namespace Hsbot.Slack.Web
{
    public static class HsbotServiceExtensions
    {
      public static IServiceCollection AddHsbot(this IServiceCollection services, HsbotConfig config)
      {
        RegisterMessageHandlers(services);

        services.AddSingleton<ISlackConfig>(svc => config);
        services.AddSingleton<Core.Hsbot>();

        return services;
      }

      private static void RegisterMessageHandlers(IServiceCollection services)
      {
        var handlerInterfaceType = typeof(IMessageHandler);
        var messageHandlerTypes = Assembly.GetAssembly(typeof(Core.Hsbot))
          .GetTypes()
          .Where(t => !t.IsAbstract && !t.IsInterface && handlerInterfaceType.IsAssignableFrom(t));

        foreach (var messageHandlerType in messageHandlerTypes)
        {
          services.Add(new ServiceDescriptor(handlerInterfaceType, messageHandlerType, ServiceLifetime.Transient));
        }
      }
    }
}
