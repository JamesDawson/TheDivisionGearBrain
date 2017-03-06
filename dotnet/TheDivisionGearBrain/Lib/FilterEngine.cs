using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;

namespace Lib
{
    class FilterEngine
    {
        private string itemsCacheFile;
        private string buildsCacheFile;

        private List<GearItem> Items { get; set; }

        public int ResultsCount { get; set; }
        public List<string> Filters { get; set; }
        public List<string> SortCriteria { get; set; }

        public FilterEngine(string cacheName, int resultsCount)
        {
            this.itemsCacheFile = string.Format("{0}-items.dat");
            this.buildsCacheFile = string.Format("{0}-builds.dat");
            this.ResultsCount = resultsCount;
            this.Filters = new List<string>();
            this.SortCriteria = new List<string>();

            using (var sr = new StreamReader(this.itemsCacheFile))
            {
                this.Items = JsonConvert.DeserializeObject<List<GearItem>>(sr.ReadToEnd());
            }
        }

        public void Process()
        {
            if (this.Filters.Count > 0)
            {
                Console.WriteLine("Searching build combinations...");
                using (var sr = new StreamReader(this.buildsCacheFile))
                {
                    // read the build info frmo the cache file
                    var cachedbuild = JsonConvert.DeserializeObject<CachedBuildInfo>(sr.ReadLine());
                    // map the item IDs to the actual Item object
                    var buildDetails = cachedbuild.Items.Select(c => this.Items.Where(i => i.Id == c)).FirstOrDefault();

                    foreach (var filter in this.Filters)
                    {
                        //
                    }

                    if (allFiltersPassed)
                    {
                        // apply sort
                    }
                }
            }
        }
    }
}
