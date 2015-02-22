using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using HS.Bot.Requests;
using HS.Bot.Requests.Models;
using MediatR;

namespace HS.Bot.Api.Controllers
{
    public class RoomsController : ApiController
    {
        private readonly IMediator _mediator;

        public RoomsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        public IEnumerable<ConferenceRoom> Get([FromUri]GetConferenceRoomsRequest request)
        {
            return _mediator.Send(request);
        }
        
        public HttpResponseMessage Post(CreateConferenceRoomRequest request)
        {
            _mediator.Send(request);
            return Request.CreateResponse(HttpStatusCode.OK);
        }

        public HttpResponseMessage Delete([FromUri]DeleteConferenceRoomRequest request)
        {
            _mediator.Send(request);
            return Request.CreateResponse(HttpStatusCode.OK);
        }
    }
}
