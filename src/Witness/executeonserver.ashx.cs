using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace Witness
{
    /// <summary>
    /// Summary description for serverexecute
    /// </summary>
    public class ExecuteJSOnServer : IHttpHandler
    {
        private static IDictionary<string, object> dotnetmethods = new Dictionary<string, object>(); 

        public static void AddMethod(string jsname,Delegate method)
        {
            dotnetmethods[jsname] = method;
        }

        public static void Add<T>(string jsname,Func<T> function)
        {
            dotnetmethods[jsname] = function;
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/javascript";
            context.Response.StatusCode = 200;

            using(var reader = new StreamReader(context.Request.GetBufferlessInputStream()))
            {
                var dotnetcontext = new DotNetContext();
                dotnetcontext.AddMany(dotnetmethods);

                try{ context.Response.Write(dotnetcontext.Run(reader.ReadToEnd()));}
                catch(Exception e)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write(e.Message);
                    return;
                }
            }
            
        }

        public bool IsReusable
        {
            get
            {
                return true;
            }
        }
    }
}