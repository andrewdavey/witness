using System;
using System.Collections.Generic;

namespace Witness
{
    public class ExecutableHeaders
    {
         IDictionary<string, string> headers;
        protected readonly DotNetContext context = new DotNetContext();
        
        public DotNetContext Add(string key, object argument)
        {
            return context.Add(key, argument);
        }

        public DotNetContext Add(string key, Action argument)
        {
            return context.Add(key, argument);
        }

        public void SetHeaders(IDictionary<string,string> headers)
        {
            this.headers = headers;
        }

        void ExecuteHeader(string name)
        {
            if (!headers.ContainsKey(name)) return;

            context.Run(string.Format("({0})(this)", headers[name]));
        }

        public void ExecuteOnAuthenticate()
        {
            ExecuteHeader("x-witness-onauthenticate");
        }

        public void ExecuteBeginRequest()
        {
            ExecuteHeader("x-witness-beginrequest");
        }

        public void ExecuteEndRequest()
        {
            ExecuteHeader("x-witness-endrequest");
        }

        public void ExecuteAuthorizeRequest()
        {
            ExecuteHeader("x-witness-authorizerequest");
        }
    }
}