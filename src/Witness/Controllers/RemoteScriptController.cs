using System;
using System.ComponentModel.Composition.Hosting;
using System.IO;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using Jurassic;

namespace Witness.Controllers
{
    /// <summary>
    /// Executes a JavaScript function using a script engine that has been configured with 
    /// any plugins added to the "plugins" directory.
    /// </summary>
    public class RemoteScriptController : Controller
    {
        public RemoteScriptController()
        {
            container = CreateContainer();
        }

        readonly CompositionContainer container;

        [HttpPost]
        public ActionResult Execute()
        {
            try
            {
                var script = ReadScriptFromRequestBody();
                // TODO: Check that script is a "function() { ... }".

                var scriptEngine = new ScriptEngine();
                ConfigureScriptEngine(scriptEngine);

                var result = scriptEngine.Evaluate("(" + script + "())");
                if (result == Undefined.Value)
                {
                    Response.ContentType = "application/json";
                    return new EmptyResult();
                }
                // TODO: Check for non-primitive results and convert into a serialization friendly format.
                // However, the result is probably only ever undefined or a boolean. So don't worry for now.
                return Json(result);
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                return Content(ex.ToString(), "text/plain");
            }
        }

        CompositionContainer CreateContainer()
        {
            var catalog = new AggregateCatalog(
                new AssemblyCatalog(Assembly.GetExecutingAssembly()),
                new DirectoryCatalog(Path.Combine(HttpRuntime.AppDomainAppPath, "plugins"))
            );
            return new CompositionContainer(catalog);
        }

        string ReadScriptFromRequestBody()
        {
            using (var reader = new StreamReader(Request.InputStream))
            {
                return reader.ReadToEnd();
            }
        }

        void ConfigureScriptEngine(ScriptEngine scriptEngine)
        {
            var configurations = container.GetExports<IConfigureScriptEngine>();
            foreach (var c in configurations)
            {
                c.Value.Configure(scriptEngine);
            }
        }
    }
}
