using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Witness.Controllers
{
    public class RunnerController : Controller
    {
        // GET /
        [HttpGet]
        public ActionResult Setup()
        {
            return View();
        }

        // GET /_witness?url={app-url}&path={spec-path}
        [HttpGet]
        public ActionResult Index(string url, string path)
        {
            var cookie = new HttpCookie("_witness_proxy", url);
            Response.Cookies.Add(cookie);

            ViewBag.Path = path;
            return View();
        }
    }
}