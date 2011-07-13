using System.Web;
using System.Web.Routing;

namespace Witness.RequestHandlers
{
    class WitnessRouteHandler<THandler> : IRouteHandler
        where THandler : IHttpHandler, IUseRequestContext, new()
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            var handler = new THandler();
            handler.UseRequestContext(requestContext);
            return handler;
        }
    }
}
