using System.Collections.Generic;
using System.Configuration;
using AutoMapper;
using HS.Bot.Requests;
using HS.Bot.Requests.Models;
using MediatR;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;

namespace HS.Bot.Core.ConferenceRooms
{
    public class GetConferenceRoomsRequestHandler : IRequestHandler<GetConferenceRoomsRequest, IEnumerable<ConferenceRoom>>
    {
        public IEnumerable<ConferenceRoom> Handle(GetConferenceRoomsRequest message)
        {
            var storageAccount = CloudStorageAccount.Parse(ConfigurationManager.ConnectionStrings["StorageConnection"].ConnectionString);
            var client = storageAccount.CreateCloudTableClient();
            
            var table = client.GetTableReference("ConferenceRooms");
            table.CreateIfNotExists();

            var query = new TableQuery<Entities.ConferenceRoom>();
            if (!string.IsNullOrEmpty(message.Location))
                query = query.Where(TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, message.Location.ToLower()));
                
            var results = table.ExecuteQuery(query);
            return Mapper.Map<IEnumerable<ConferenceRoom>>(results);
        }
    }
}
