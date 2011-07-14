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
        string basePath;

        public ActionResult Get(string path)
        {
            EnsurePathExists(path);

            basePath = path;

            var manifest = new Manifest(Request.ApplicationPath);
            AssignDirectoryOrFile(manifest, path);
            manifest.helpers = FindParentHelpers(path).ToArray();

            Response.Cache.SetNoStore();
            return Json(manifest, JsonRequestBehavior.AllowGet);
        }

        void EnsurePathExists(string fullPath)
        {
            if (!Directory.Exists(fullPath) && !System.IO.File.Exists(fullPath))
            {
                throw new HttpException(404, "Cannot find the path \"" + fullPath + "\"");
            }
        }

        void AssignDirectoryOrFile(Manifest manifest, string fullPath)
        {
            if (System.IO.File.GetAttributes(fullPath).HasFlag(FileAttributes.Directory))
            {
                manifest.directory = GetSpecificationDirectory(fullPath);
            }
            else
            {
                manifest.file = GetSpecificationFile(fullPath, "");
            }
        }

        IEnumerable<string> FindParentHelpers(string fullPath)
        {
            var root = Request.QueryString["root"];
            if (root == null) yield break;

            var rootPath = Server.MapPath("~/" + root).TrimEnd('\\', '/');

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
                    yield return GetFileUrl(file.FullName, rootPath);
                }
                directory = directory.Parent;
            }
        }

        SpecDir GetSpecificationDirectory(string rootPath)
        {
            return new SpecDir
            {
                name = Path.GetFileName(rootPath),
                directories =
                    from path in Directory.EnumerateDirectories(rootPath)
                    where System.IO.File.GetAttributes(path).HasFlag(FileAttributes.Hidden) == false
                    let directory = GetSpecificationDirectory(path)
                    where directory.IsNotEmpty
                    select directory,
                files =
                    from filename in Directory.EnumerateFiles(rootPath)
                    where IsScript(filename) && IsHelperFile(filename) == false
                    select GetSpecificationFile(filename, rootPath),
                helpers =
                    from filename in Directory.EnumerateFiles(rootPath)
                    where IsScript(filename) && IsHelperFile(filename)
                    select GetFileUrl(filename, rootPath)
            };
        }

        bool IsScript(string filename)
        {
            return (filename.EndsWith(".js", StringComparison.OrdinalIgnoreCase)
                 || filename.EndsWith(".coffee", StringComparison.OrdinalIgnoreCase))
                && System.IO.File.GetAttributes(filename).HasFlag(FileAttributes.Hidden) == false;
        }

        bool IsHelperFile(string filename)
        {
            return Path.GetFileName(filename).StartsWith("_");
        }

        SpecFile GetSpecificationFile(string filename, string rootPath)
        {
            return new SpecFile
            {
                name = Path.GetFileName(filename),
                url = GetFileUrl(filename, rootPath)
            };
        }

        string GetFileUrl(string filename, string rootPath)
        {
            return "/_witness/specs?path=" + HttpUtility.UrlEncode(filename);
        }

    }
}