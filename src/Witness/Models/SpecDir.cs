using System.Collections.Generic;
using System.Linq;

namespace Witness.Models
{
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
}