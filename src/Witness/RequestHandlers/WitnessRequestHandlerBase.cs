using System;
using System.Web;
using System.Web.Routing;

namespace Witness.RequestHandlers
{
    public abstract class WitnessRequestHandlerBase : IHttpHandler, IUseRequestContext
    {
        RequestContext requestContext;

        public abstract void ProcessRequest(RequestContext context);

        void IUseRequestContext.UseRequestContext(RequestContext context)
        {
            this.requestContext = context;
        }

        void IHttpHandler.ProcessRequest(HttpContext context)
        {
            if (requestContext == null) throw new InvalidOperationException("Cannot process a request until UseRequestContext has been called.");
            ProcessRequest(requestContext);
        }

        bool IHttpHandler.IsReusable
        {
            get { return false; }
        }
    }
}
