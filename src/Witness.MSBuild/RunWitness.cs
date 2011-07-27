using System;
using System.Diagnostics;
using System.IO;
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

        [Required]
        public string Witness { get; set; }

        public string PhantomJS { get; set; }

        public override bool Execute()
        {
            var website = StartIISExpress(Website, 9000);
            var witness = StartIISExpress(Witness, 9001);
            var phantomjs = StartPhantomJS(PhantomJS, Specifications, 9001, 9000);

            phantomjs.WaitForExit();

            witness.Kill();
            website.Kill();
            witness.WaitForExit();
            website.WaitForExit();
            
            return true;
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

        Process StartPhantomJS(string phantomJS, string specsPath, int witnessPort, int websitePort)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = phantomJS,
                Arguments = GetPhantomJSArguments(specsPath, witnessPort, websitePort),
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
