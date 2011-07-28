using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Witness.Controllers
{
    public class SandboxController : Controller
    {
        public ActionResult Index()
        {
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(1));
            return View();
        }
    }
}
