using Hsbot.Slack.Core;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using IHostingEnvironment = Microsoft.AspNetCore.Hosting.IHostingEnvironment;

namespace Hsbot.Slack.Web
{
    public class Startup
    {
      private readonly IConfiguration _config;

      public Startup(IConfiguration config)
      {
        _config = config;
      }

      public void ConfigureServices(IServiceCollection services)
      {
        services.AddHsbot(new HsbotConfig {SlackApiKey = _config["slack:apiKey"]});
        services.AddSingleton<IHostedService, HsbotHostedService>();
      }

      public void Configure(IApplicationBuilder app, IHostingEnvironment env)
      {
          if (env.IsDevelopment())
          {
              app.UseDeveloperExceptionPage();
          }

          app.Run(async (context) =>
          {
              await context.Response.WriteAsync("Beep boop bop");
          });
      }
    }
}
