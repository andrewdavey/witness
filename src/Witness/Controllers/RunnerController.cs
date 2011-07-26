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
        public ActionResult Root()
        {
            return RedirectToAction("Index");
        }

        // GET /_witness
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult SetupProxy(string path, string url)
        {
            Response.Cookies.Add(new HttpCookie("_witness_path", path));
            Response.Cookies.Add(new HttpCookie("_witness_proxy", url));
            return new EmptyResult();
        }
    }
}