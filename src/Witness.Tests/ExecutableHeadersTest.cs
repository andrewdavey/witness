using System.Collections.Generic;

namespace Witness.Tests
{
    public class ExecutableHeadersTest
    {
        protected ExecutableHeaders headers;
        protected bool executed;

        protected void HeaderSet(string key)
        {
            headers = new ExecutableHeaders();
            headers.SetHeaders(new Dictionary<string, string>{{key,"function() {doThis();}"}});
            headers.Add("doThis", () => executed = true);
        }
    }
}