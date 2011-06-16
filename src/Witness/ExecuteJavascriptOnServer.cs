using System;
using System.Linq;
using System.Web;

namespace Witness
{

    public class ExecuteJavascriptOnServer : IHttpModule
    {
        static ExecutableHeaders headers = new ExecutableHeaders();

        public static void Add(string key, object argument)
        {
             headers.Add(key, argument);
        }

        public static void Add(string key, Action argument)
        {
             headers.Add(key, argument);
        }

        public void Init(HttpApplication context)
        {
            context.BeginRequest += (e, v) =>
            {
                headers.SetHeaders((from string k in context.Request.Headers select k)
                                        .Where(k => k.StartsWith("x-witness"))
                                        .ToDictionary(k => k,k => context.Request.Headers[k]));

                headers.ExecuteBeginRequest();
            };

            context.AuthorizeRequest += (e, v) => headers.ExecuteBeginRequest();
            context.AuthenticateRequest += (e, v) => headers.ExecuteOnAuthenticate();
            context.EndRequest += (e, v) => headers.ExecuteEndRequest();
        }

        public void Dispose()
        {
        }
    }
}