using System;
using Jurassic;
using Jurassic.Library;

namespace Witness.Specs.Remote
{
    /// <summary>
    /// For use by the Witness remote specs.
    /// </summary>
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
