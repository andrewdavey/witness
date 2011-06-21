using System.Reflection;
using System.Web.Routing;

namespace Witness.RequestHandlers
{
    public class GetAssemblyResourceHandler : WitnessRequestHandlerBase
    {
        public override void ProcessRequest(RequestContext context)
        {
            var path = (string)context.RouteData.Values["path"] ?? "runner.htm";
            var resourceName = "Witness." + path.Replace('/', '.');

            var response = context.HttpContext.Response;

            if (resourceName.EndsWith(".htm"))
            {
                response.ContentType = "text/html";
            }
            else if (resourceName.EndsWith(".css"))
            {
                response.ContentType = "text/css";
            }
            else if (resourceName.EndsWith(".png"))
            {
                response.ContentType = "image/png";
            }

            using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName))
            {
                if (stream == null)
                {
                    response.StatusCode = 404;
                }
                else
                {
                    stream.CopyTo(response.OutputStream);
                }
            }
        }
    }
}
