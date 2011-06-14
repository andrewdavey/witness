using System;
using System.Dynamic;
using Jurassic;

namespace Witness
{
    public class DotNetContext : DynamicObject
    {
        private ScriptEngine engine = new ScriptEngine();

        public DotNetContext Add(string key, object argument)
        {
            engine.SetGlobalValue(key,argument);
            return this;
        }

        public DotNetContext Add(string key, Action argument)
        {
            engine.SetGlobalFunction(key,argument);
            return this;
        }

        public void Run(string script)
        {
            engine.Execute(script);
        }
    }
}