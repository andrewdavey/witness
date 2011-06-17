using System;
using System.Collections.Generic;
using System.Dynamic;
using Jurassic;

namespace Witness
{
    public class DotNetContext : DynamicObject
    {
        private ScriptEngine engine = new ScriptEngine();

        public void Add(string key, Action argument)
        {
            engine.SetGlobalFunction(key,argument);
        }

        public void Add<T>(string key, Func<T> argument)
        {
            engine.SetGlobalFunction(key, argument);
        }

        public void Add<T,T2>(string key, Func<T,T2> argument)
        {
            engine.SetGlobalFunction(key, argument);
        }

        public void Add<T, T2,T3>(string key, Func<T, T2,T3> argument)
        {
            engine.SetGlobalFunction(key, argument);
        }

        public string Run(string script)
        {
            engine.Execute("result = " +  script);
            engine.Execute("result = JSON.stringify(result)");
            return engine.GetGlobalValue("result").ToString();
        }

        public void AddMany(IDictionary<string, object> dotnetmethods)
        {
            foreach (var kv in dotnetmethods)
                engine.SetGlobalFunction(kv.Key, (Delegate) kv.Value);
        }
    }
}
