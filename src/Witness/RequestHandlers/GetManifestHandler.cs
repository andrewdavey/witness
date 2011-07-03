using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Script.Serialization;

namespace Witness.RequestHandlers
{
    public class GetManifestHandler : WitnessRequestHandlerBase
    {
        public override void ProcessRequest(RequestContext context)
        {
            var path = context.HttpContext.Request.QueryString["path"] ?? "";
            path = path.TrimEnd('/');
            var fullPath = Path.Combine(context.HttpContext.Server.MapPath("~/" + path));
            EnsurePathExists(path, fullPath);

            var manifest = new Manifest(context.HttpContext.Request.ApplicationPath);
            AssignDirectoryOrFile(manifest, fullPath, context);
            
            var json = new JavaScriptSerializer().Serialize(manifest);
            context.HttpContext.Response.AddHeader("Cache-Control", "no-cache");
            context.HttpContext.Response.ContentType = "application/json";
            context.HttpContext.Response.Write(json);
        }

        void EnsurePathExists(string path, string fullPath)
        {
            if (!Directory.Exists(fullPath) && !File.Exists(fullPath))
            {
                throw new HttpException(404, "Cannot find the path \"" + path + "\"");
            }
        }

        void AssignDirectoryOrFile(Manifest manifest, string fullPath, RequestContext context)
        {
            if (File.GetAttributes(fullPath).HasFlag(FileAttributes.Directory))
            {
                manifest.directory = GetSpecificationDirectory(fullPath, context.HttpContext);
            }
            else
            {
                manifest.file = GetSpecificationFile(fullPath, context.HttpContext);
            }
        }

        SpecDir GetSpecificationDirectory(string rootPath, HttpContextBase context)
        {
            return new SpecDir
            {
                name = Path.GetFileName(rootPath),
                directories =
                    from path in Directory.EnumerateDirectories(rootPath)
                    where File.GetAttributes(path).HasFlag(FileAttributes.Hidden) == false
                    let directory = GetSpecificationDirectory(path, context)
                    where directory.IsNotEmpty
                    select directory,
                files =
                    from filename in Directory.EnumerateFiles(rootPath)
                    where IsScript(filename) && IsHelperFile(filename) == false
                    select GetSpecificationFile(filename, context),
                helpers =
                    from filename in Directory.EnumerateFiles(rootPath)
                    where IsScript(filename) && IsHelperFile(filename)
                    select GetFileUrl(filename, context)
            };
        }

        bool IsScript(string filename)
        {
            return (filename.EndsWith(".js", StringComparison.OrdinalIgnoreCase)
                 || filename.EndsWith(".coffee", StringComparison.OrdinalIgnoreCase))
                && File.GetAttributes(filename).HasFlag(FileAttributes.Hidden) == false;
        }

        bool IsHelperFile(string filename)
        {
            return Path.GetFileName(filename).StartsWith("_");
        }

        SpecFile GetSpecificationFile(string filename, HttpContextBase context)
        {
            return new SpecFile
            {
                name = Path.GetFileName(filename),
                url = GetFileUrl(filename, context)
            };
        }

        string GetFileUrl(string filename, HttpContextBase context)
        {
            var root = context.Request.ApplicationPath.TrimEnd('/');
            return root + "/" + filename.Substring(context.Request.PhysicalApplicationPath.Length).Replace('\\', '/');
        }

        class Manifest
        {
            public Manifest(string urlBase)
            {
                this.urlBase = urlBase;
                if (!this.urlBase.EndsWith("/")) this.urlBase += "/";
            }

            // directory xor file:
            public SpecDir directory { get; set; }
            public SpecFile file { get; set; }

            // So that `loadPage "foo.htm"` can reference the absolute URL:
            public string urlBase { get; set; }
        }

        class SpecDir
        {
            public string name { get; set; }
            public IEnumerable<SpecDir> directories { get; set; }
            public IEnumerable<SpecFile> files { get; set; }
            public IEnumerable<string> helpers { get; set; }

            public bool IsNotEmpty
            {
                get
                {
                    return directories.Any() || files.Any();
                }
            }
        }

        class SpecFile
        {
            public string name { get; set; }
            public string url { get; set; }
        }
    }
}
