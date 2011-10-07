using System;
using System.Diagnostics;
using System.IO;
using System.Linq.Expressions;
using System.Reflection;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Witness.MSBuild
{
    /// <summary>
    /// Starts Witness and the website under test in IIS Express. Runs PhantomJS to execute the specification runner.
    /// All output from these processes is piped to the task's log output.
    /// </summary>
    public class RunWitness : Task
    {
        public RunWitness()
        {
            witnessRootDirectory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        }

        /// <summary>
        /// The directory containing the installed Witness resources.
        /// </summary>
        string witnessRootDirectory;

        /// <summary>
        /// Path to the specifications directory.
        /// </summary>
        [Required]
        public string Specifications { get; set; }

        /// <summary>
        /// Optional file system path to the website under test.
        /// </summary>
        public string Website { get; set; }

        /// <summary>
        /// Optional TCP port to run the website under test on.
        /// </summary>
        public int WebsitePort { get; set; }

        /// <summary>
        /// Optional hostname port to run the website under test on.
        /// </summary>
        public string WebsiteHostname { get; set; }

        /// <summary>
        /// Optional file system path to the Witness application root.
        /// </summary>
        public string Witness { get; set; }

        /// <summary>
        /// Optional TCP port to run Witness on.
        /// </summary>
        public int WitnessPort { get; set; }


        /// <summary>
        /// Optional hostname port to run Witness on.
        /// </summary>
        public string WitnessHostname { get; set; }

        /// <summary>
        /// Path to the PhantomJS executable.
        /// </summary>
        public string PhantomJS { get; set; }

        public override bool Execute()
        {
            ExpandPropertyValues();
            Log.LogMessage(witnessRootDirectory);
            Log.LogMessage(Witness);
            Log.LogMessage(WitnessHostname);
            Log.LogMessage(WitnessPort.ToString());
            Log.LogMessage(Website);
            Log.LogMessage(WebsiteHostname);
            Log.LogMessage(WebsitePort.ToString());
            using (var iisConfig = new IisConfiguration(witnessRootDirectory, Witness, WitnessHostname, WitnessPort, Website, WebsiteHostname, WebsitePort))
            {
                var websites = iisConfig.StartWebsites();
                foreach (var website in websites)
                {
                    PipeProcessToLog(website);
                }

                var phantomjs = StartPhantomJS();
                phantomjs.WaitForExit();

                foreach (var website in websites)
                {
                    if (website.HasExited) continue;
                    Log.LogMessage("Stopping IIS Express.");
                    website.Kill();
                    website.WaitForExit();
                }
            }

            return true;
        }

        void ExpandPropertyValues()
        {
            if (WitnessPort == 0) WitnessPort = TcpHelpers.GetFreeTcpPort(9000);
            if (WebsitePort == 0) WebsitePort = TcpHelpers.GetFreeTcpPort(WitnessPort + 1);

            if (string.IsNullOrEmpty(Witness))
            {
                Witness = Path.Combine(witnessRootDirectory, "web");
            }


            if (string.IsNullOrEmpty(WitnessHostname))
            {
                WitnessHostname = "localhost";
            }

            if (string.IsNullOrEmpty(WebsiteHostname))
            {
                WebsiteHostname = "localhost";
            }

            EnsureAbsolutePath(() => Witness);
            EnsureAbsolutePath(() => Specifications);
            EnsureAbsolutePath(() => Website, optional: true);

            EnsurePhantomJS();
        }

        void EnsureAbsolutePath(Expression<Func<string>> property, bool optional = false)
        {
            var path = property.Compile()();
            var exists = Directory.Exists(path);
            if (!exists)
            {
                if (optional) return;
                throw new DirectoryNotFoundException("Directory not found: " + path);
            }
            if (Path.IsPathRooted(path)) return;
            
            path = Path.GetFullPath(path);

            // Create the path assignment statement.
            var assignment = Expression.Assign(property.Body, Expression.Constant(path, typeof(string)));
            var action = Expression.Lambda<Action>(assignment).Compile();
            action();
        }

        void EnsurePhantomJS()
        {
            if (string.IsNullOrEmpty(PhantomJS))
            {
                PhantomJS = Path.Combine(witnessRootDirectory, "phantomjs\\phantomjs.exe");
            }

            if (Path.IsPathRooted(PhantomJS) == false)
            {
                PhantomJS = Path.GetFullPath(PhantomJS);
            }

            if (File.Exists(PhantomJS) == false)
            {
                throw new FileNotFoundException("PhantomJS executable not found at " + PhantomJS);
            }
        }

        Process StartPhantomJS()
        {
            return StartProcessThatPipesToLog(PhantomJS, GetPhantomJSArguments(Specifications, WitnessHostname, WitnessPort, WebsiteHostname, WebsitePort));
        }

        string GetPhantomJSArguments(string specsPath, string witnessHostname, int witnessPort, string websiteHostname, int websitePort)
        {
            var runnerScript = Path.Combine(witnessRootDirectory, "run-witness.coffee");
            return string.Format(
                "--disk-cache=yes \"{0}\" http://{1}:{2} \"{3}\" http://{4}:{5}",
                runnerScript,
                witnessHostname,
                witnessPort,
                specsPath,
                websiteHostname,
                websitePort
            );
        }

        Process StartProcessThatPipesToLog(string exeFilename, string arguments)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = exeFilename,
                Arguments = arguments,
                RedirectStandardError = true,
                RedirectStandardOutput = true,
                UseShellExecute = false
            };
            var process = Process.Start(startInfo);
            PipeProcessToLog(process);
            return process;
        }

        void PipeProcessToLog(Process process)
        {
            process.BeginOutputReadLine();
            process.OutputDataReceived += (sender, e) =>
            {
                if (e.Data == null) return; // MSBuild throws an exception if the message is null. So we'll just skip those.
                Log.LogMessage(e.Data);
            };

            process.BeginErrorReadLine();
            process.ErrorDataReceived += (sender, e) =>
            {
                if (e.Data == null) return; // MSBuild throws an exception if the message is null. So we'll just skip those.
                Log.LogError(e.Data);
            };
        }
    }
}
