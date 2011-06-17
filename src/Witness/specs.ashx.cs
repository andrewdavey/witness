using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System;

namespace Witness
{
    /// <summary>
    /// Returns a JSON object containing the specification directories and files for a given root path.
    /// </summary>
    public class GetSpecificationsHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var path = context.Request.QueryString["path"];
            if (path == null) throw new HttpException(400, "Request is missing the path query string parameter.");

            path = path.TrimEnd('/');
            var fullPath = Path.Combine(context.Server.MapPath("~/" + path));
            if (!Directory.Exists(fullPath) && !File.Exists(fullPath))
            {
                throw new HttpException(404, "Cannot find the path \"" + path + "\"");
            }

            string json;
            if (File.GetAttributes(fullPath).HasFlag(FileAttributes.Directory))
            {
                var directory = GetSpecificationDirectory(fullPath, context);
                json = new JavaScriptSerializer().Serialize(directory);
            }
            else
            {
                var file = GetSpecificationFile(fullPath, context);
                json = new JavaScriptSerializer().Serialize(file);
            }
            context.Response.AddHeader("Cache-Control","no-cache");
            context.Response.ContentType = "application/json";
            context.Response.Write(json);
        }

        public bool IsReusable
        {
            get { return true; }
        }

        SpecDir GetSpecificationDirectory(string rootPath, HttpContext context)
        {
            return new SpecDir
            {
                name = Path.GetFileName(rootPath),
                directories =
                    from path in Directory.EnumerateDirectories(rootPath)
                    where File.GetAttributes(path).HasFlag(FileAttributes.Hidden) == false
                    select GetSpecificationDirectory(path, context),
                files =
                    from filename in Directory.EnumerateFiles(rootPath)
                    where filename.EndsWith(".js", StringComparison.OrdinalIgnoreCase)
                       || filename.EndsWith(".coffee", StringComparison.OrdinalIgnoreCase)
                    where File.GetAttributes(filename).HasFlag(FileAttributes.Hidden) == false
                    select GetSpecificationFile(filename, context)
            };
        }

        SpecFile GetSpecificationFile(string filename, HttpContext context)
        {
            return new SpecFile
            {
                name = Path.GetFileName(filename),
                url = GetFileUrl(filename, context)
            };
        }

        string GetFileUrl(string filename, HttpContext context)
        {
            return "/" + filename.Substring(context.Request.PhysicalApplicationPath.Length).Replace('\\', '/');
        }

        class SpecDir
        {
            public string name { get; set; }
            public IEnumerable<SpecDir> directories { get; set; }
            public IEnumerable<SpecFile> files { get; set; }
        }

        class SpecFile
        {
            public string name { get; set; }
            public string url { get; set; }
        }
    }
}