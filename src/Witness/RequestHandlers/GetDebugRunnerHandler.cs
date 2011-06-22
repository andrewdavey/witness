using System;
using System.IO;
using System.IO.IsolatedStorage;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Routing;
using Knapsack;

namespace Witness.RequestHandlers
{
    public class GetDebugRunnerHandler : WitnessRequestHandlerBase
    {
        static readonly Knapsack.CoffeeScript.CoffeeScriptCompiler coffeeScriptCompiler = new Knapsack.CoffeeScript.CoffeeScriptCompiler(File.ReadAllText);

        static string GetDebugScriptsHtml(HttpContext context)
        {
            using (var storage = IsolatedStorageFile.GetMachineStoreForDomain())
            {
                var builder = new ScriptModuleContainerBuilder(
                    storage,
                    Path.Combine(
                        context.Request.PhysicalApplicationPath,
                        @"..\Witness\scripts"
                    ),
                    coffeeScriptCompiler
                );
                builder.AddModule("", "");
                var container = builder.Build();
                var rootUrl = context.Request.Url.GetLeftPart(UriPartial.Authority) + "/witness/";
                var urls =
                    from r in container.FindModule("").Resources
                    select r.Path.EndsWith(".coffee")
                        ? rootUrl + "knapsack.axd/coffee/scripts/" + r.Path.Substring(0, r.Path.Length - ".coffee".Length)
                        : rootUrl + "scripts/" + r.Path;
                var scriptTags = from url in urls
                                 select "<script type='text/javascript' src='" + url + "'></script>";
                return string.Join("\r\n", scriptTags);
            }
        }

        static Lazy<string> debugScriptsHtml = new Lazy<string>(() => GetDebugScriptsHtml(HttpContext.Current));

        public override void ProcessRequest(RequestContext context)
        {
            var filename = context.HttpContext.Request.Url.LocalPath.Split('\\', '/').Last();

            using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("Witness." + filename))
            {
                using (var reader = new StreamReader(stream))
                {
                    var replace = "<script type=\"text/javascript\" src=\"witness.js\"></script>";
                    var html = reader.ReadToEnd().Replace(replace, debugScriptsHtml.Value);

                    context.HttpContext.Response.ContentType = "text/html";
                    context.HttpContext.Response.Write(html);
                }
            }
        }
    }
}