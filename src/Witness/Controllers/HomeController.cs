using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Witness.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index(string path)
        {
            if (string.IsNullOrEmpty(path))
            {
                return RedirectToAction("index", new { path = "specs" });
            }

            ViewBag.Path = path;
            return View();
        }

        public ActionResult Sandbox()
        {
            return View();
        }
    }
}
