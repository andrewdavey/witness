using Jurassic;

namespace Witness
{
    /// <summary>
    /// Implemented in third-party assemblies to configure the <see cref="ScriptEngine"/>
    /// used to run remote scripts. Typically this includes adding global objects and functions
    /// to the engine's environment.
    /// </summary>
    public interface IConfigureScriptEngine
    {
        // See http://jurassic.codeplex.com/wikipage?title=Exposing%20a%20.NET%20class%20to%20JavaScript&referringTitle=Documentation
        // for examples of how to customize the script engine by adding .NET clases and functions.
        void Configure(ScriptEngine scriptEngine);
    }
}