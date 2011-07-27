using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;

namespace Witness.MSBuild
{
    static class TcpHelpers
    {
        public static int GetFreeTcpPort(int startPort)
        {
            var ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();
            var endPoints = ipGlobalProperties.GetActiveTcpListeners();
            var portsInUse = new HashSet<int>(endPoints.Select(e => e.Port));
            for (int port = startPort; port <= IPEndPoint.MaxPort; port++)
            {
                if (portsInUse.Contains(port) == false)
                {
                    return port;
                }
            }
            throw new Exception("Cannot find a free TCP port.");
        }
    }
}
