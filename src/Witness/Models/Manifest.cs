using System.Collections.Generic;

namespace Witness.Models
{
    class Manifest
    {
        public Manifest(string urlBase)
        {
            this.urlBase = urlBase;
            if (!this.urlBase.EndsWith("/")) this.urlBase += "/";
        }

        // directory xor file:
        public SpecDir directory { get; set; }
        public SpecFile file { get; set; }

        // Helpers from parent directories.
        // Used when returning the manifest for a single file or sub-directory.
        // We still need the helpers from higher up the tree.
        public IEnumerable<string> helpers { get; set; }

        // So that `loadPage "foo.htm"` can reference the absolute URL:
        public string urlBase { get; set; }
    }
}