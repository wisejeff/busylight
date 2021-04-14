using System;
namespace BusyServer.Models
{
    public class ScheduleItem
    {
        public ScheduleItem()
        {
        }

        public string Description { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }


    }
}
