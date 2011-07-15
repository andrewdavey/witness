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
            if (path[path.Length - 1] != Path.DirectorySeparatorChar) path += Path.DirectorySeparatorChar.ToString();
            basePath = path;
            var directory = GetSpecificationDirectory(path);

            Response.Cache.SetNoStore();
            return Json(directory, JsonRequestBehavior.AllowGet);
        }

        void EnsurePathExists(string fullPath)
        {
            if (!Directory.Exists(fullPath) && !System.IO.File.Exists(fullPath))
            {
                throw new HttpException(404, "Cannot find the path \"" + fullPath + "\"");
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
                    select GetSpecificationFile(filename),
                helpers =
                    from filename in Directory.EnumerateFiles(rootPath)
                    where IsScript(filename) && IsHelperFile(filename)
                    select GetFileUrl(filename)
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

        SpecFile GetSpecificationFile(string filename)
        {
            return new SpecFile
            {
                name = Path.GetFileName(filename),
                url = GetFileUrl(filename),
                path = filename.Substring(basePath.Length)
            };
        }

        string GetFileUrl(string filename)
        {
            return "/_witness/specs?path=" + HttpUtility.UrlEncode(filename);
        }

    }
}