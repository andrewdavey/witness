using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace Witness
{
    /// <summary>
    /// Summary description for serverexecute
    /// </summary>
    public class ExecuteJavascriptOnServer : IHttpHandler
    {
        private static IDictionary<string, object> dotnetmethods = new Dictionary<string, object>(); 

        public static void Add(string jsname,Action method)
        {
            dotnetmethods[jsname] = method;
        }

        public static void Add<T>(string jsname,Func<T> function)
        {
            dotnetmethods[jsname] = function;
        }

        public static void Add<T1,T2>(string jsname, Func<T1,T2> function)
        {
            dotnetmethods[jsname] = function;
        }

        public static void Add<T1, T2,T3>(string jsname, Func<T1, T2,T3> function)
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
                    var serializer = new JavaScriptSerializer();
                    context.Response.Write(serializer.Serialize(new
                    {
                        error = e.Message
                    }));
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