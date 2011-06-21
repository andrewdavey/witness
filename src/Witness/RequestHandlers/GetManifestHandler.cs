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
            var path = (string)context.RouteData.Values["path"] ?? "";

            path = path.TrimEnd('/');
            var fullPath = Path.Combine(context.HttpContext.Server.MapPath("~/" + path));
            if (!Directory.Exists(fullPath) && !File.Exists(fullPath))
            {
                throw new HttpException(404, "Cannot find the path \"" + path + "\"");
            }

            string json;
            if (File.GetAttributes(fullPath).HasFlag(FileAttributes.Directory))
            {
                var directory = GetSpecificationDirectory(fullPath, context.HttpContext);
                json = new JavaScriptSerializer().Serialize(directory);
            }
            else
            {
                var file = GetSpecificationFile(fullPath, context.HttpContext);
                json = new JavaScriptSerializer().Serialize(file);
            }
            context.HttpContext.Response.AddHeader("Cache-Control", "no-cache");
            context.HttpContext.Response.ContentType = "application/json";
            context.HttpContext.Response.Write(json);
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
            return "/" + filename.Substring(context.Request.PhysicalApplicationPath.Length).Replace('\\', '/');
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
