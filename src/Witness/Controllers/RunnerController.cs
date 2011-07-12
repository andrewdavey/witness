using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Witness.Controllers
{
    public class RunnerController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }
    }
}