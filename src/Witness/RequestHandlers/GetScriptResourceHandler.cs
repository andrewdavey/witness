using System.IO;
using System.Reflection;
using System.Resources;
using System.Web.Routing;

namespace Witness.RequestHandlers
{
    public class GetScriptResourceHandler : WitnessRequestHandlerBase
    {
        public override void ProcessRequest(RequestContext context)
        {
            var response = context.HttpContext.Response;

            response.ContentType = "text/javascript";

            using (var scriptStream = GetScriptStream())
            {
                scriptStream.CopyTo(response.OutputStream);
            }

            response.Flush();
        }

        Stream GetScriptStream()
        {
            var manager = GetResourceManager();
            return (Stream)manager.GetObject("witness.js");
        }

        ResourceManager GetResourceManager()
        {
            return new ResourceManager("Witness.Script", Assembly.GetExecutingAssembly());
        }
    }
}
