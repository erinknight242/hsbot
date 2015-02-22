using System.Threading;
using AutoMapper;
using HS.Bot.Requests.Models;

namespace HS.Bot.Core
{
    public class CoreProfile : Profile
    {
        protected override void Configure()
        {
            CreateMap<Entities.ConferenceRoom, ConferenceRoom>()
                .ForMember(dest => dest.Location, src => src.MapFrom(e => Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(e.PartitionKey)))
                .ForMember(dest => dest.Name, src => src.MapFrom(e => Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(e.RowKey)));

            CreateMap<ConferenceRoom, Entities.ConferenceRoom>()
                .ForMember(dest => dest.PartitionKey, src => src.MapFrom(m => m.Location.ToLower()))
                .ForMember(dest => dest.RowKey, src => src.MapFrom(m => m.Name.ToLower()));

        }
    }
}
