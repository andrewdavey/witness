using System;
using System.Linq;
using System.Text;
using Xunit;

namespace Witness.Tests
{
  
    public class CallingAMethodFromJavascript
    {
        static bool called;
        DotNetContext context;

        public CallingAMethodFromJavascript()
        {
            context = new DotNetContext();
            context.Add("callingAMethod", () => called = true);
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
            context = new DotNetContext();
            context.Add("callingAMethod", () => result = "called");
        }

        [Fact]
        public void IsCalled()
        {
            context.Run("callingAMethod('called')");

            Assert.Equal(result,"called");
        }
    }

    public class CallingAFunctionFromJavascript
    {
        DotNetContext context;

        public CallingAFunctionFromJavascript()
        {
            context = new DotNetContext();
            context.Add("callingAFunction", () => 42);
        }

        [Fact]
        public void IsCalled()
        {
            var returnvalue = context.Run("result = callingAFunction()");

            Assert.Equal(returnvalue, "42");
        }
    }


    public class ReturningAnObjectLiteralFromJavascript
    {

        DotNetContext context;

        public ReturningAnObjectLiteralFromJavascript()
        {
            context = new DotNetContext();
        }

        [Fact]
        public void ReturnsValue()
        {
            var returnvalue = context.Run("result = {key:12}");

            Assert.Equal(returnvalue, "{\"key\":12}");
        }
    }

}
