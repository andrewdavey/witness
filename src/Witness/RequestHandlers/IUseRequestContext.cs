using System.Web.Routing;

namespace Witness.RequestHandlers
{
    public interface IUseRequestContext
    {
        void UseRequestContext(RequestContext context);
    }
}
