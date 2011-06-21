using System.Web;
using System.Web.Routing;
using Witness.RequestHandlers;

// When the host web application is started, we install routes to Witness resources.
[assembly: WebActivator.PostApplicationStartMethod(typeof(Witness.Routing), "MapRoutes")]

namespace Witness
{
    public class Routing
    {
        public static void MapRoutes()
        {
            var router = new Routing(RouteTable.Routes);
            router.Install();
        }

        readonly string routePrefix = "_witness/";
        readonly RouteCollection routes;
        int nextInsertIndex = 0;

        public Routing(RouteCollection routes)
        {
            this.routes = routes;
        }

        public void Install()
        {
            MapRoute<GetManifestHandler>("manifest/{*path}");
            MapRoute<GetScriptResourceHandler>("witness.js");
            MapRoute<ExecuteScriptHandler>("execute-script");
            MapRoute<GetAssemblyResourceHandler>("{*path}");
        }

        void MapRoute<T>(string url)
            where T : IHttpHandler, IUseRequestContext, new()
        {
            // Routes need to go at the start of the collection.
            // Otherwise more generic routes defined in the host application could
            // intercept Witness URLs.
            routes.Insert(
                nextInsertIndex++, // Keep the order correct by incrementing the insert location.
                new Route(
                    routePrefix + url, 
                    new WitnessRouteHandler<T>()
                )
            );
        }
    }
}
