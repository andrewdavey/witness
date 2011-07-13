using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using Witness.RequestHandlers;

namespace Witness
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            MapRoutes(RouteTable.Routes);
        }

        void MapRoutes(RouteCollection routes)
        {
            // Any URL starting "_witness" is mapped to a Witness controller.
            routes.MapRoute(
                "Manifest",
                "_witness/manifest",
                new { controller = "Manifest", action = "Get" }
            );
            routes.MapRoute(
                "Witness",
                "_witness/{controller}/{action}"
            );

            // All other URLs are proxied to their original target.
            // (If the Witness cookie has been set up.)
            routes.Add(
                "Proxy",
                new Route(
                    "{*any}", // Match any URL
                    null, // No defaults required
                    new { constraint = new RequireWitnessCookieConstraint() },
                    new WitnessRouteHandler<ProxyHandler>()
                )
            );

            // When new browser session requests root URL they have no Witness cookie.
            // So display the runner page.
            routes.MapRoute(
                "Init",
                "", // The root URL.
                new { controller = "Runner", action = "Index" }
            );
        }
    }
}