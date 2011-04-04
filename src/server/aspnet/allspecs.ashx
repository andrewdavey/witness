<%@ WebHandler Language="C#" Class="WitnessSpecList" %>

using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

public class WitnessSpecList : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        var path = context.Request.QueryString["path"];
        var root = context.Server.MapPath("~/" + path);
        var urlBase = context.Request.ApplicationPath;
        if (!urlBase.EndsWith("/")) urlBase = urlBase + "/";
        var srcs = from filename in Directory.GetFiles(root, "*.js")
                   select urlBase + path + "/" + filename.Substring(root.Length+1);

        var json = new JavaScriptSerializer().Serialize(srcs);

        context.Response.ContentType = "application/json";
        context.Response.Write(json);
    }

    public bool IsReusable
    {
        get { return false; }
    }
}