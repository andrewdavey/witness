using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Xml.Linq;

namespace Witness.MSBuild
{
    /// <summary>
    /// Creates an IIS Express config file that hosts two websites (Witness and website under test).
    /// Can start the website processes.
    /// Deletes the file when disposed.
    /// </summary>
    class IisConfiguration : IDisposable
    {
        public IisConfiguration(string witnessRootDirectory, string witnessPath, string witnessHostName, int witnessPort, string websitePath, string websiteHostName, int websitePort)
        {
            iisExpressExeFilename = GetIISExpressExePath();
            filename = UniqueConfigFilename(witnessRootDirectory);
            CreateConfigFile(witnessRootDirectory, witnessPath, witnessHostName, witnessPort, websitePath, websiteHostName, websitePort);
        }

        readonly string filename;
        readonly string iisExpressExeFilename;

        public Process[] StartWebsites()
        {
            var processes = 
                from id in new[] { 1, 2 }
                let arguments = "/config:\"" + filename + "\" /siteid:" + id
                let startInfo = new ProcessStartInfo
                {
                    FileName = iisExpressExeFilename,
                    Arguments = arguments,
                    RedirectStandardError = true,
                    RedirectStandardOutput = true,
                    UseShellExecute = false
                }
                select Process.Start(startInfo);

            return processes.ToArray();
        }

        public void Dispose()
        {
            if (File.Exists(filename)) File.Delete(filename);
        }

        void CreateConfigFile(string witnessRootDirectory, string witnessPath, string witnessHostName, int witnessPort, string websitePath, string websiteHostName, int websitePort)
        {
            var xml = LoadTemplateConfigXml(witnessRootDirectory);
            var sitesElement = xml.Root.Element("system.applicationHost").Element("sites");
            var witnessElement = SiteElement(1, "Witness", witnessPath,witnessHostName, witnessPort);
            sitesElement.Add(witnessElement);

            if (string.IsNullOrEmpty(websitePath) == false)
            {
                var websiteElement = SiteElement(2, "Website Under Test", websitePath, websiteHostName, websitePort);
                sitesElement.Add(websiteElement);
            }

            xml.Save(filename);
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

            var filename = Path.Combine(root, "IIS Express", "iisexpress.exe");
            if (File.Exists(filename) == false)
            {
                throw new Exception("Could not find IIS Express at \"" + filename + "\". Please install IIS Express.");
            }
            return filename;
        }

        XDocument LoadTemplateConfigXml(string witnessRootDirectory)
        {
            var templateFilename = Path.Combine(witnessRootDirectory, "iisexpress-template.config");
            using (var template = File.OpenRead(templateFilename))
            {
                return XDocument.Load(template);
            }
        }

        XElement SiteElement(int id, string name, string physicalPath, string hostname, int port)
        {
            return new XElement("site",
                new XAttribute("name", name),
                new XAttribute("id", id.ToString()),
                new XAttribute("serverAutoStart", "true"),

                new XElement("application",
                    new XAttribute("path", "/"),

                    new XElement("virtualDirectory",
                        new XAttribute("path", "/"),
                        new XAttribute("physicalPath", physicalPath)
                    )
                ),

                new XElement("bindings",
                    new XElement("binding",
                        new XAttribute("protocol", "http"),
                        new XAttribute("bindingInformation", ":" + port + ":" + hostname)
                    )
                )
            );
        }

        string UniqueConfigFilename(string witnessRootDirectory)
        {
            return Path.Combine(witnessRootDirectory, "iisexpress-" + Guid.NewGuid() + ".config");
        }
    }
}
