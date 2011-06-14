using System;
using System.Linq;
using System.Text;
using Xunit;

namespace Witness.Tests
{
    public class ExecutingAuthenticateHeader : ExecutableHeadersTest
    {
        public ExecutingAuthenticateHeader()
        {
            HeaderSet("x-witness-onauthenticate");
        }

        [Fact]
        public void HeaderIsExecuted()
        {
            headers.ExecuteOnAuthenticate();

            Assert.True(executed);
        }
    }

    public class ExecutingBeginRequestHeader : ExecutableHeadersTest
    {
        public ExecutingBeginRequestHeader()
        {
            HeaderSet("x-witness-beginrequest");
        }

        [Fact]
        public void HeaderIsExecuted()
        {
            headers.ExecuteBeginRequest();

            Assert.True(executed);
        }
    }

    public class ExecutingEndRequestHeader : ExecutableHeadersTest
    {
        public ExecutingEndRequestHeader()
        {
            HeaderSet("x-witness-endrequest");
        }

        [Fact]
        public void HeaderIsExecuted()
        {
            headers.ExecuteEndRequest();

            Assert.True(executed);
        }
    }


    public class CallingAMethodFromJavascript
    {
        static bool called;
        DotNetContext context;

        public CallingAMethodFromJavascript()
        {
            context = new DotNetContext()
                .Add("callingAMethod", () => called = true);
        }

        [Fact]
        public void IsCalled()
        {
            context.Run("callingAMethod()");

            Assert.True(called);
        }
    }

    public class CallingAParametisedMethodFromJavascript
    {
        static string result;
        DotNetContext context;

        public CallingAParametisedMethodFromJavascript()
        {
            context = new DotNetContext()
                .Add("callingAMethod", () => result = "called");
        }

        [Fact]
        public void IsCalled()
        {
            context.Run("callingAMethod('called')");

            Assert.Equal(result,"called");
        }
    }


}
