using Microsoft.WindowsAzure.Storage.Table;

namespace HS.Bot.Core.Entities
{
    internal class ConferenceRoom : TableEntity
    {
        public ConferenceRoom()
        {
        }

        public ConferenceRoom(string name, string location)
        {
            PartitionKey = location;
            RowKey = name;
        }

        public string Phone { get; set; }

    }
}
