using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;

namespace Lib
{
    public interface IFilter
    {
        bool Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters);
    }

    public class EnsureAtLeastFilter : IFilter
    {
        public bool Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters)
        {
            return false;
        }
    }

    public class UnlockNamedGearSetFilter : IFilter
    {
        public bool Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters)
        {
            return false;
        }
    }

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
            this.itemsCacheFile = string.Format("{0}-items.dat", cacheName);
            this.buildsCacheFile = string.Format("{0}-builds.dat", cacheName);
            this.ResultsCount = resultsCount;
            this.Filters = new List<FilterPipelineStep>();
            this.SortCriteria = new List<string>();

            //loadFilterPlugins();

            using (var sr = new StreamReader(this.itemsCacheFile))
            {
                this.Items = JsonConvert.DeserializeObject<List<GearItem>>(sr.ReadToEnd());
            }
        }

        private void loadFilterPlugins()
        {
            DirectoryInfo dllDirectory = new DirectoryInfo("Filters");
            FileInfo[] dlls = dllDirectory.GetFiles("*Filters.dll");
            foreach (FileInfo dllFileInfo in dlls)
            {
                Console.WriteLine(string.Format("Loading filter plugin: {0}", dllFileInfo.Name));
                //Assembly assembly = Assembly.Load(dllFileInfo.FullName);
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
                    var buildInfo = new List<GearItem>();
                    foreach (var itemId in cachedBuild.Items)
                    {
                        var fullItem = this.Items.Where(i => i.Id == itemId).FirstOrDefault();
                        buildInfo.Add(fullItem);
                    }
                    //var buildInfo = cachedBuild.Items.Select(c => this.Items.Where(i => i.Id == c).FirstOrDefault()).FirstOrDefault();
                    var buildStats = cachedBuild.Stats;

                    var allFiltersPassed = true;
                    var interfaceType = typeof(IFilter);
                    foreach (var filter in this.Filters)
                     {
                        // call filter via reflection?
                        var res = invokeFilter(filter.Filter, filter.Parameters, buildInfo, buildStats);
                        if (!res)
                        {
                            allFiltersPassed = false;
                            break;
                        }
                    }

                    if (allFiltersPassed)
                    {
                        // apply sort
                    }
                }
            }
        }

        private bool invokeFilter(string filterTypeName, Dictionary<string, string> filterArgs, List<GearItem> buildItems, Dictionary<string,decimal> buildStats)
        {
            //var type = Type.GetType(filter.Filter);
            //if (interfaceType.IsAssignableFrom(filterType))
            //{
            //    IFilter p = (IFilter)Activator.CreateInstance(filterType);
            //}

            Type type = Assembly.GetExecutingAssembly().GetType(filterTypeName);
            if (type != null)
            {
                MethodInfo m = type.GetMethod("Process");
                if (m != null)
                {
                    ParameterInfo[] parameters = m.GetParameters();
                    object instance = Activator.CreateInstance(type, null);
                    object[] parametersArray = new object[] { buildItems, buildStats, filterArgs };
                    bool res = ((bool)m.Invoke(instance, parametersArray));
                    return res;
                }
            }

            return false;
        }
    }
}
