using System.Configuration;
using AutoMapper;
using HS.Bot.Requests;
using MediatR;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;

namespace HS.Bot.Core.ConferenceRooms
{
    public class CreateConferenceRoomRequestHandler : RequestHandler<CreateConferenceRoomRequest>
    {
        protected override void HandleCore(CreateConferenceRoomRequest message)
        {
            var storageAccount = CloudStorageAccount.Parse(ConfigurationManager.ConnectionStrings["StorageConnection"].ConnectionString);
            var client = storageAccount.CreateCloudTableClient();

            var table = client.GetTableReference("ConferenceRooms");
            table.CreateIfNotExists();

            var entity = Mapper.Map<Entities.ConferenceRoom>(message);
            var operation = TableOperation.InsertOrReplace(entity);

            table.Execute(operation);
        }
    }
}
