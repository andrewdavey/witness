using System.Net;
using System.Web;
using System.Web.Routing;

namespace Witness.RequestHandlers
{
    /// <summary>
    /// Forwards any request to the web server under test and returns
    /// that response as if it was it's own.
    /// </summary>
    public class ProxyHandler : WitnessRequestHandlerBase
    {
        public override void ProcessRequest(RequestContext requestContext)
        {
            var context = requestContext.HttpContext;
            var urlString = GetTargetUrlString(context);

            var targetRequest = HttpWebRequest.Create(urlString);
            AddRequestHeaders(context, targetRequest);

            var targetResponse = targetRequest.GetResponse();
            AddResponseHeaders(context, targetResponse);

            using (var stream = targetResponse.GetResponseStream())
            {
                // TODO: If stream is HTML, parse and replace absolute URLs to use proxy URLs instead.

                stream.CopyTo(context.Response.OutputStream);
            }

            context.Response.End();
        }

        string GetTargetUrlString(HttpContextBase context)
        {
            var cookie = context.Request.Cookies["_witness"];
            var pathAndQuery = context.Request.Url.PathAndQuery;
            var urlString = cookie.Values["url"] + pathAndQuery;
            return urlString;
        }

        void AddRequestHeaders(HttpContextBase context, WebRequest targetRequest)
        {
            targetRequest.Headers.Add(context.Request.Headers);
        }

        void AddResponseHeaders(HttpContextBase context, WebResponse targetResponse)
        {
            context.Response.Headers.Add(targetResponse.Headers);
        }
    }
}