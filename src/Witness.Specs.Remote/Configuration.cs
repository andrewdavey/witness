using System.ComponentModel.Composition;
using Jurassic;

namespace Witness.Specs.Remote
{
    [Export(typeof(IConfigureScriptEngine))]
    public class Configuration : IConfigureScriptEngine
    {
        public void Configure(ScriptEngine scriptEngine)
        {
            scriptEngine.SetGlobalValue("utils", new Utils(scriptEngine));
        }
    }
}