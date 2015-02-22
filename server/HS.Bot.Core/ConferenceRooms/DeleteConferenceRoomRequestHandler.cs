using System.Configuration;
using AutoMapper;
using HS.Bot.Requests;
using MediatR;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;

namespace HS.Bot.Core.ConferenceRooms
{
    public class DeleteConferenceRoomRequestHandler : RequestHandler<DeleteConferenceRoomRequest>
    {
        protected override void HandleCore(DeleteConferenceRoomRequest message)
        {
            var storageAccount = CloudStorageAccount.Parse(ConfigurationManager.ConnectionStrings["StorageConnection"].ConnectionString);
            var client = storageAccount.CreateCloudTableClient();

            var table = client.GetTableReference("ConferenceRooms");
            table.CreateIfNotExists();

            var entity = Mapper.Map<Entities.ConferenceRoom>(message);
            entity.ETag = "*";

            var opertation = TableOperation.Delete(entity);
            

            table.Execute(opertation);
        }
    }
}
