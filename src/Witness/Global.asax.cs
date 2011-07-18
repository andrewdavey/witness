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
            routes.RouteExistingFiles = true;

            // Any URL starting "_witness" is mapped to a Witness controller.
            routes.MapRoute(
                "Manifest",
                "_witness/manifest",
                new { controller = "Manifest", action = "Get" }
            );
            routes.MapRoute(
                "Sandbox",
                "_witness/sandbox.htm",
                new { controller = "Sandbox", action = "Index" }
            );
            routes.MapRoute(
                "SpecFile",
                "_witness/specs",
                new { controller = "Spec", action = "Get" }
            );
            routes.MapRoute(
                "RunnerSetupProxy",
                "_witness/setupproxy", // The root URL.
                new { controller = "Runner", action = "SetupProxy" }
            );
            routes.MapRoute(
                "RunnerIndex",
                "_witness",
                new { controller = "Runner", action = "Index" }
            );

            routes.IgnoreRoute("_witness/knapsack.axd/{*any}");

            // When new browser session requests root URL they have no Witness cookie.
            // So display the runner setup page.
            routes.MapRoute(
                "RunnerRoot",
                "", // The root URL.
                new { controller = "Runner", action = "Root" }
            );
        }
    }
}