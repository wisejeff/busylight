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

        [HttpGet]
        public string Get()
        {
            return memoryCache.Get<string>("busy_status");
        }

        [HttpPost]
        public string Set([FromBody]string busyStatus)
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions().SetSlidingExpiration(TimeSpan.FromHours(24));

            this.memoryCache.Set("busy_status", busyStatus);
            return Get();
        }
    }
}
