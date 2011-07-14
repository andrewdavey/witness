using System.IO;
using System.Web.Mvc;

namespace Witness.Controllers
{
    public class SpecController : Controller
    {
        [HttpGet]
        public ActionResult Get(string path)
        {
            return File(path, "text/plain");
        }
    }
}