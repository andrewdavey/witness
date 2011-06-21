using System;
using System.Collections.Generic;
using System.IO;
using System.Web.Routing;
using System.Web.Script.Serialization;

[assembly: WebActivator.PreApplicationStartMethod(typeof (Witness.RequestHandlers.ExecuteScriptHandler), "AppStart")]

namespace Witness.RequestHandlers
{
    public class ExecuteScriptHandler : WitnessRequestHandlerBase
    {
        public static void AppStart()
        {
            ExecuteScriptHandler.Add("serverfunctionthatreturns42", () => 42);
            ExecuteScriptHandler.Add("serverfunctionthatreturns43", () => 43);
            ExecuteScriptHandler.Add("servermethodthatthrowsanexception", () =>
            {
                throw new Exception("bang");
            });
        }


        private static IDictionary<string, object> dotnetmethods = new Dictionary<string, object>();

        public static void Add(string jsname, Action method)
        {
            dotnetmethods[jsname] = method;
        }

        public static void Add<T>(string jsname, Func<T> function)
        {
            dotnetmethods[jsname] = function;
        }

        public static void Add<T1, T2>(string jsname, Func<T1, T2> function)
        {
            dotnetmethods[jsname] = function;
        }

        public static void Add<T1, T2, T3>(string jsname, Func<T1, T2, T3> function)
        {
            dotnetmethods[jsname] = function;
        }

        public override void ProcessRequest(RequestContext context)
        {
            context.HttpContext.Response.ContentType = "text/javascript";
            context.HttpContext.Response.StatusCode = 200;

            using (var reader = new StreamReader(context.HttpContext.Request.InputStream))
            {
                var dotnetcontext = new DotNetContext();
                dotnetcontext.AddMany(dotnetmethods);

                try { context.HttpContext.Response.Write(dotnetcontext.Run(reader.ReadToEnd())); }
                catch (Exception e)
                {
                    context.HttpContext.Response.StatusCode = 400;
                    var serializer = new JavaScriptSerializer();
                    context.HttpContext.Response.Write(serializer.Serialize(new
                    {
                        error = e.Message
                    }));
                    return;
                }
            }
        }
    }
}
