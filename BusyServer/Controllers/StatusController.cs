using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;

namespace BusyServer.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class StatusController: ControllerBase
    {
        private readonly ILogger<StatusController> logger;
        private readonly IMemoryCache memoryCache;

        public StatusController(ILogger<StatusController> logger, IMemoryCache memoryCache)
        {
            this.logger = logger;
            this.memoryCache = memoryCache;
        }

        [HttpGet("{id}")]
        public string Get(string id)
        {
            return memoryCache.Get<string>($"{id}_busy_status");
        }

        [HttpPost("{id}")]
        public string Set(string id, [FromBody]string busyStatus)
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions().SetSlidingExpiration(TimeSpan.FromHours(24)).SetAbsoluteExpiration(TimeSpan.FromHours(24));

            this.memoryCache.Set($"{id}_busy_status", busyStatus);
            return Get(id);
        }

        [HttpPost("/api/v2/[controller]/{id}")]
        public string Set(string id, [FromBody]StatusViewModel busyStatus)
        {
            return Set(id, busyStatus.Status);
        }
    }

    public class StatusViewModel
    {
        public string Status { get; set; }
    }
}
