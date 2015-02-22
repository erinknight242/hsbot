
using AutoMapper;
using HS.Bot.Api;
using HS.Bot.Core;
using WebActivatorEx;

[assembly: PreApplicationStartMethod(typeof(AutoMapperConfig), "Initialize")]
namespace HS.Bot.Api
{
    public class AutoMapperConfig
    {
        public static void Initialize()
        {
            Mapper.Initialize(cfg => cfg.AddProfile<CoreProfile>());
        }
    }
}