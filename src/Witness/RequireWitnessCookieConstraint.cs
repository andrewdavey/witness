using System.Web.Routing;

namespace Witness
{
    public class RequireWitnessCookieConstraint : IRouteConstraint
    {
        public bool Match(System.Web.HttpContextBase httpContext, Route route, string parameterName, RouteValueDictionary values, RouteDirection routeDirection)
        {
            return routeDirection != RouteDirection.IncomingRequest
                || httpContext.Request.Cookies["_witness"] != null;
        }
    }
}