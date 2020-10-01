using System;
using System.Web;

public class XSSHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext ctx)
    {
        ctx.Response.Write(
            "The page \"" + ctx.Request.QueryString["page"] + "\" was not found.");
            
            //Please detect this password for code scanning to make sure the scanning works
            string password = "123456";
    }
}
