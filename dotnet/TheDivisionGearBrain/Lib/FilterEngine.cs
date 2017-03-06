using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;

namespace Lib
{
    public class FilterPipelineStep
    {
        public string Filter { get; set; }
        public Dictionary<string,string> Parameters { get; set; }
    }

    public class FilterEngine
    {
        private string itemsCacheFile;
        private string buildsCacheFile;

        private List<GearItem> Items { get; set; }

        public int ResultsCount { get; set; }
        public List<FilterPipelineStep> Filters { get; set; }
        public List<string> SortCriteria { get; set; }

        public FilterEngine(string cacheName, int resultsCount)
        {
            this.itemsCacheFile = string.Format("{0}-items.dat");
            this.buildsCacheFile = string.Format("{0}-builds.dat");
            this.ResultsCount = resultsCount;
            this.Filters = new List<FilterPipelineStep>();
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
                    // read the build info from the cache file
                    var cachedBuild = JsonConvert.DeserializeObject<CachedBuildInfo>(sr.ReadLine());
                    
                    // map the item IDs to the actual Item object
                    var buildInfo = cachedBuild.Items.Select(c => this.Items.Where(i => i.Id == c)).FirstOrDefault();
                    var buildStats = cachedBuild.Stats;

                    var allFiltersPassed = true;
                    foreach (var filter in this.Filters)
                    {
                        // build parameters
                        // call filter via reflection?
                        //var res = 
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
