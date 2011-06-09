using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace Witness
{
    /// <summary>
    /// Returns a JSON object containing the specification directories and files for a given root path.
    /// </summary>
    public class GetSpecificationsHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var path = context.Request.PathInfo;
            path = path.TrimEnd('/');
            var fullPath = Path.Combine(context.Server.MapPath("~" + path));

            var directory = GetSpecificationDirectory(fullPath, context);
            var json = new JavaScriptSerializer().Serialize(directory);

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