using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Lib;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            var inventory = new Inventory(@"..\..\..\..\..\my-gear-list-with-mods.json", 75);
            
            Console.WriteLine("Pre-computing all build combinations...");
            var start = DateTime.Now;
            var buildsCount = inventory.GenerateBuildCombinationCache("csharp");
            var end = DateTime.Now;
            Console.WriteLine(string.Format("\nCompleted - created {0} build combinations - ({1} builds/sec)", buildsCount, (end - start).TotalSeconds/buildsCount));

            var cacheName = "csharp";
            var engine = new FilterEngine(cacheName, 3);

            var filters = new List<FilterPipelineStep>
            {
                new FilterPipelineStep { Filter="Lib.EnsureAtLeastFilter", Parameters = new Dictionary<string,string>(){ { "stat", "firearms" }, { "min_value", "3832" }} },
                new FilterPipelineStep { Filter="Lib.EnsureAtLeastFilter", Parameters = new Dictionary<string,string>(){ { "stat", "stamina" }, { "min_value", "3832" }} }
            };
            engine.Filters = filters;

            start = DateTime.Now;
            var results = engine.Process();
            end = DateTime.Now;
            Console.WriteLine(string.Format("\n Completed searching for optimal builds - ({0} builds/sec)", (end - start).TotalSeconds / buildsCount));

            foreach (var res in results)
            {
                Console.WriteLine(string.Format("*** Top {0} builds", results.Count()));
                Console.WriteLine(string.Format("\nElectronics: {0}", res.Stats["electronics"]));
                Console.WriteLine(string.Format("Armor: {0}", res.Stats["armor"]));
                Console.WriteLine(string.Format("Skill Haste: {0}", res.Stats["skillhaste"]));
                Console.WriteLine(string.Format("Firearms: {0}", res.Stats["firearms"]));
                Console.WriteLine(string.Format("Stamina: {0}", res.Stats["stamina"]));
            }

        }
    }
}
