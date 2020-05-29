using System;

using Microsoft.AspNetCore.Mvc;

namespace BusyServer.Controllers
{
    
    public class HomeController:Controller
    {
        public HomeController()
        {

        }

        public IActionResult Index() {
            return View();
        }
    }
}
