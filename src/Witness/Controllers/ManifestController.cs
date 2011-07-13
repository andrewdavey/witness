using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Witness.Models;

namespace Witness.Controllers
{
    public class ManifestController : Controller
    {
        public ActionResult Get(string path)
        {
            path = (path ?? "").TrimEnd('/');
            var fullPath = Path.Combine(Server.MapPath("~/" + path));
            EnsurePathExists(path, fullPath);

            var manifest = new Manifest(Request.ApplicationPath);
            AssignDirectoryOrFile(manifest, fullPath, context);
            manifest.helpers = FindParentHelpers(fullPath, context).ToArray();

            Response.Cache.SetNoStore();
            return Json(manifest);
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

        IEnumerable<string> FindParentHelpers(string fullPath, RequestContext context)
        {
            var root = context.HttpContext.Request.QueryString["root"] ?? "";
            var rootPath = context.HttpContext.Server.MapPath("~/" + root).TrimEnd('\\', '/');

            DirectoryInfo directory;
            if (Directory.Exists(fullPath))
            {
                directory = new DirectoryInfo(fullPath);
            }
            else
            {
                directory = new FileInfo(fullPath).Directory;
            }

            while (directory.FullName.Equals(rootPath, StringComparison.OrdinalIgnoreCase) == false)
            {
                var files = directory.GetFiles().Where(
                    file => IsScript(file.FullName)
                         && IsHelperFile(file.FullName)
                );

                foreach (var file in files)
                {
                    yield return GetFileUrl(file.FullName, context.HttpContext);
                }
                directory = directory.Parent;
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

    }
}