using System.Collections.Generic;
using MediatR;

namespace HS.Bot.Requests
{
    public class GetConferenceRoomsRequest : IRequest<IEnumerable<Models.ConferenceRoom>>
    {
        public string Location { get; set; }
    }
}
