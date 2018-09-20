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
        services.AddLogging();
        services.AddHsbot(new HsbotConfig {SlackApiKey = _config["slack:apiKey"]});

        //This registration is what will actually run hsbot as a background
        //process within the website.  We'll need an external keep-alive to
        //make sure the site doesn't shut down when no HTTP requests are coming in.
        services.AddSingleton<IHostedService, HsbotHostedService>();
      }

      public void Configure(IApplicationBuilder app, IHostingEnvironment env)
      {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        //We're not actually serving up any web content at present.
        //This website is only acting as a host for the hsbot service,
        //so no need to wire up anything other than a static reply.
        app.Run(async (context) =>
        {
            await context.Response.WriteAsync("Beep boop bop");
        });
      }
    }
}
