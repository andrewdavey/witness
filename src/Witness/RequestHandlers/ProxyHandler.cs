using System.Net;
using System.Web;
using System.Web.Routing;
using System;
using System.IO;

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

            var targetRequest = (HttpWebRequest)HttpWebRequest.Create(urlString);
            AddRequestHeaders(context, targetRequest);

            if (context.Request.ContentLength > 0)
            {
                context.Request.InputStream.CopyTo(targetRequest.GetRequestStream());
            }

            var targetResponse = (HttpWebResponse)targetRequest.GetResponse();
            AddResponseHeaders(context, targetResponse);

            
            using (var stream = targetResponse.GetResponseStream())
            {
                // TODO: If stream is HTML, parse and replace absolute URLs to use proxy URLs instead.

                stream.CopyTo(context.Response.OutputStream);
                context.Response.OutputStream.Flush();
            }

            context.Response.Flush();
        }

        string GetTargetUrlString(HttpContextBase context)
        {
            var cookie = context.Request.Cookies["_witness"];
            var pathAndQuery = context.Request.Url.PathAndQuery;
            var urlString = cookie.Values["url"].TrimEnd('/') + pathAndQuery;
            return urlString;
        }

        void AddRequestHeaders(HttpContextBase context, HttpWebRequest targetRequest)
        {
            foreach (var header in context.Request.Headers.AllKeys)
            {
                var value = context.Request.Headers[header];
                switch (header)
                {
                    case "Accept":
                        targetRequest.Accept = value;
                        break;
                    case "User-Agent":
                        targetRequest.UserAgent = value;
                        break;
                    case "Connection":
                    case "Host":
                        break;
                    default:
                        try
                        {
                            targetRequest.Headers[header] = value;
                        }
                        catch (ArgumentException ex)
                        {
                            throw new Exception("Cannot set header " + header, ex);
                        }
                        break;
                }
            }
        }

        void AddResponseHeaders(HttpContextBase context, WebResponse targetResponse)
        {
            context.Response.ClearHeaders();
            context.Response.ContentType = targetResponse.ContentType;
            foreach (var header in targetResponse.Headers.AllKeys)
            {
                var value = targetResponse.Headers[header];
                if (header == "Transfer-Encoding")
                {
                }
                else
                {
                    context.Response.Headers.Add(header, value);
                }
            }
        }
    }
}