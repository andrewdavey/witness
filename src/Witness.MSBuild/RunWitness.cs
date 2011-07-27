using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System.Linq.Expressions;

namespace Witness.MSBuild
{
    public class RunWitness : Task
    {
        /// <summary>
        /// Path to the specifications directory.
        /// </summary>
        [Required]
        public string Specifications { get; set; }

        /// <summary>
        /// File system path to the website under test.
        /// </summary>
        [Required]
        public string Website { get; set; }

        /// <summary>
        /// Optional TCP port to run the website under test on.
        /// </summary>
        public int WebsitePort { get; set; }

        /// <summary>
        /// File system path to the Witness application root.
        /// </summary>
        [Required]
        public string Witness { get; set; }

        /// <summary>
        /// Optional TCP port to run Witness on.
        /// </summary>
        public int WitnessPort { get; set; }

        /// <summary>
        /// Path to the PhantomJS executable.
        /// </summary>
        public string PhantomJS { get; set; }

        public override bool Execute()
        {
            ExpandPropertyValues();

            var website = StartIISExpress(Website, WebsitePort);
            var witness = StartIISExpress(Witness, WitnessPort);
            var phantomjs = StartPhantomJS();

            phantomjs.WaitForExit();

            witness.Kill();
            website.Kill();
            witness.WaitForExit();
            website.WaitForExit();
            
            return true;
        }

        void ExpandPropertyValues()
        {
            if (WitnessPort == 0) WitnessPort = TcpHelpers.GetFreeTcpPort(9000);
            if (WebsitePort == 0) WebsitePort = TcpHelpers.GetFreeTcpPort(WitnessPort + 1);

            EnsureAbsolutePath(() => Witness);
            EnsureAbsolutePath(() => Website);
            EnsureAbsolutePath(() => Specifications);
        }

        void EnsureAbsolutePath(Expression<Func<string>> property)
        {
            var path = property.Compile()();
            if (Directory.Exists(path) == false) throw new DirectoryNotFoundException("Directory not found: " + path);
            if (Path.IsPathRooted(path)) return;
            
            path = Path.GetFullPath(path);

            // Create the path assignment statement.
            var assignment = Expression.Assign(property.Body, Expression.Constant(path, typeof(string)));
            var action = Expression.Lambda<Action>(assignment).Compile();
            action();
        }

        Process StartIISExpress(string websitePath, int port)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = GetIISExpressExePath(),
                Arguments = CreateIISArguments(websitePath, port),
                RedirectStandardError = true,
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                UseShellExecute = false
            };
            var process = Process.Start(startInfo);
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.OutputDataReceived += (sender, e) =>
            {
                if (e.Data != null)
                {
                    Log.LogMessage(e.Data);
                }
            };
            process.ErrorDataReceived += (sender, e) =>
            {
                if (e.Data != null)
                {
                    Log.LogError(e.Data);
                }
            };
            return process;
        }

        string GetIISExpressExePath()
        {
            string root;
            if (Environment.Is64BitOperatingSystem)
            {
                root = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
            }
            else
            {
                root = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
            }

            return Path.Combine(root, "IIS Express", "iisexpress.exe");
        }

        string CreateIISArguments(string websitePath, int port)
        {
            return string.Format("/path:\"{0}\" /port:{1}", websitePath, port);
        }

        Process StartPhantomJS()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = PhantomJS,
                Arguments = GetPhantomJSArguments(Specifications, WitnessPort, WebsitePort),
                RedirectStandardError = true,
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                UseShellExecute = false
            };
            var process = Process.Start(startInfo);
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.OutputDataReceived += (sender, e) =>
            {
                if (e.Data != null)
                {
                    Log.LogMessage(e.Data);
                }
            };
            process.ErrorDataReceived += (sender, e) =>
            {
                if (e.Data != null)
                {
                    Log.LogError(e.Data);
                }
            };
            return process;
        }

        string GetPhantomJSArguments(string specsPath, int witnessPort, int websitePort)
        {
            return string.Format(
                "--disk-cache=yes run-witness.coffee http://localhost:{0} http://localhost:{1} \"{2}\"",
                witnessPort,
                websitePort,
                specsPath
            );
        }
    }
}
