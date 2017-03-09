using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;

using Lib;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            int minStatPercentile = 80;
            var inventory = new Inventory(@"..\..\..\..\..\my-gear-list-with-mods.json", minStatPercentile, @"S:\");
            
            Console.WriteLine("Pre-computing all build combinations...");
            var cacheName = "tactician-striker-electronics";
            var start = DateTime.Now;
            var buildsCount = inventory.GenerateBuildCombinationCache(cacheName);
            var end = DateTime.Now;
            Console.WriteLine(string.Format("\nCompleted - created {0} build combinations - ({1} builds/sec)", buildsCount, buildsCount / (end - start).TotalSeconds));

            var engine = new FilterEngine(cacheName, 5, @"S:\");

            var filters = new List<FilterPipelineStep>
            {
                new FilterPipelineStep { Filter="Lib.UnlockNamedGearSetFilter", Parameters = new Dictionary<string,string>(){ { "gearset", "tactician" }, { "min_items", "3" }} },
                new FilterPipelineStep { Filter="Lib.UnlockNamedGearSetFilter", Parameters = new Dictionary<string,string>(){ { "gearset", "striker" }, { "min_items", "2" }} },
                new FilterPipelineStep { Filter="Lib.EnsureAtLeastFilter", Parameters = new Dictionary<string,string>(){ { "stat", "firearms" }, { "min_value", "3832" }} },
                new FilterPipelineStep { Filter="Lib.EnsureAtLeastFilter", Parameters = new Dictionary<string,string>(){ { "stat", "stamina" }, { "min_value", "3832" }} }
            };
            engine.Filters = filters;

            var sortCriteria = new List<string> { "electronics", "skillhaste" };
            engine.SortCriteria = sortCriteria;

            start = DateTime.Now;
            var results = engine.Process();
            end = DateTime.Now;
            Console.WriteLine(string.Format("\n Completed searching for optimal builds - ({0} builds/sec)", buildsCount / (end - start).TotalSeconds));

            foreach (var res in results)
            {
                Console.WriteLine(string.Format("*** Top {0} builds", results.Count()));
                Console.WriteLine(string.Format("\nElectronics: {0}", res.Stats["electronics"]));
                Console.WriteLine(string.Format("Armor: {0}", res.Stats["armor"]));
                Console.WriteLine(string.Format("Skill Haste: {0}", res.Stats["skillhaste"]));
                Console.WriteLine(string.Format("Firearms: {0}", res.Stats["firearms"]));
                Console.WriteLine(string.Format("Stamina: {0}", res.Stats["stamina"]));
            }

            var resultsFile = string.Format("{0}-results.json", cacheName);
            Console.WriteLine("Results saved to: {0}", resultsFile);
            using (var sw = new StreamWriter(resultsFile))
            {
                sw.WriteLine(JsonConvert.SerializeObject(results));
            }

        }
    }
}
