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

        public Routing(RouteCollection routes)
        {
            this.routes = routes;
        }

        readonly RouteCollection routes;
        readonly string routePrefix = "_witness/";
        int nextInsertIndex = 0;

        /// <summary>
        /// Inserts all the Witness routes into the route collection.
        /// </summary>
        public void Install()
        {
            // In debug mode we need to parse the HTML files and insert to debug version
            // of Witness's javascript. This means each script is a separate file in the page.
            // In release mode the scripts are already merged into a single file and embedded
            // as a resource.
#if DEBUG
            MapRoute<GetDebugRunnerHandler>("runner.htm");
            MapRoute<GetDebugRunnerHandler>("sandbox.htm");
#endif
            MapRoute<GetManifestHandler>("manifest");
            MapRoute<ExecuteScriptHandler>("execute-script");
#if RELEASE
            // The witness.js file is in a separate resource file, so a specialized handler
            // is used to read it.
            MapRoute<GetScriptResourceHandler>("witness.js");
#endif
            // All other resources (css, images) can be accessed generically using this handler.
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
