using BusyServer.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;

namespace BusyServer.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ScheduleController : ControllerBase
    {
        private readonly ILogger<StatusController> logger;
        private readonly IMemoryCache memoryCache;

        public ScheduleController(ILogger<StatusController> logger, IMemoryCache memoryCache)
        {
            this.logger = logger;
            this.memoryCache = memoryCache;
        }

        [HttpGet("{id}")]
        public IEnumerable<ScheduleItem> Get(string id)
        {
            //return memoryCache.Get<string>($"{id}_schedule");

            return new List<ScheduleItem>() {
                new ScheduleItem(){Description = "Conference Call", StartTime = new DateTime(2020, 12, 3, 15,0,0),  EndTime = new DateTime(2020, 12, 3, 15,30,0)},
                new ScheduleItem(){Description = "Conference Call", StartTime = new DateTime(2020, 12, 3, 15,30,0), EndTime = new DateTime(2020, 12, 3, 16,0,0)},
                new ScheduleItem(){Description = "Conference Call", StartTime = new DateTime(2020, 12, 3, 16,0,0),  EndTime = new DateTime(2020, 12, 3, 16,30,0)},
                new ScheduleItem(){Description = "Conference Call", StartTime = new DateTime(2020, 12, 3, 16,30,0), EndTime = new DateTime(2020, 12, 3, 17,0,0)},
            };
        }
    }
}
