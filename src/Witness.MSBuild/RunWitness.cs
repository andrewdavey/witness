using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Witness.MSBuild
{
    public class RunWitness : Task
    {
        [Required]
        public string Specifications { get; set; }

        [Required]
        public string Website { get; set; }

        public int WebsitePort { get; set; }

        [Required]
        public string Witness { get; set; }

        public int WitnessPort { get; set; }

        public string PhantomJS { get; set; }

        public override bool Execute()
        {
            AssignPropertyDefaultsIfEmpty();

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

        void AssignPropertyDefaultsIfEmpty()
        {
            if (WitnessPort == 0) WitnessPort = GetFreeTcpPort(9000);
            if (WebsitePort == 0) WebsitePort = GetFreeTcpPort(WitnessPort + 1);
        }

        int GetFreeTcpPort(int startPort)
        {
            var ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();
            var endPoints = ipGlobalProperties.GetActiveTcpListeners();
            var portsInUse = new HashSet<int>(endPoints.Select(e => e.Port));
            for (int port = startPort; port <= IPEndPoint.MaxPort; port++)
            {
                if (portsInUse.Contains(port) == false)
                {
                    return port;
                }
            }
            throw new Exception("Cannot find a free TCP port.");
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
