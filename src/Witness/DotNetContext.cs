using System;
using System.Collections.Generic;
using System.Dynamic;
using Jurassic;

namespace Witness
{
    public class DotNetContext : DynamicObject
    {
        private ScriptEngine engine = new ScriptEngine();

        public void Add(string key, object argument)
        {
            engine.SetGlobalValue(key,argument);
        }

        public void Add(string key, Action argument)
        {
            engine.SetGlobalFunction(key,argument);
        }

        public string Run(string script)
        {
            engine.Execute(script);
            engine.Execute("result = JSON.stringify(result)");
            return engine.GetGlobalValue("result").ToString();
        }

        public void AddMany(IDictionary<string, Action> dotnetmethods)
        {
            foreach(var kv in dotnetmethods) Add(kv.Key,kv.Value);
        }
    }
}