using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Jurassic;
using Jurassic.Library;
using System.ComponentModel.Composition;

namespace Witness.Specs.Remote
{
    [Export(typeof(IConfigureScriptEngine))]
    public class Configuration : IConfigureScriptEngine
    {
        public void Configure(ScriptEngine scriptEngine)
        {
            scriptEngine.SetGlobalValue("utils", new Utils(scriptEngine));
        }

        class Utils : ObjectInstance
        {
            public Utils(ScriptEngine engine)
                : base(engine)
            {
                this.PopulateFunctions();
            }

            [JSFunction]
            public static int serverfunctionthatreturns42()
            {
                return 42;
            }

            [JSFunction]
            public static int serverfunctionthatreturns43()
            {
                return 43;
            }

            [JSFunction]
            public static void servermethodthatthrowsanexception()
            {
                throw new Exception("bang");
            }
        }
    }
}
