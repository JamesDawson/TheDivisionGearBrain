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
            var inventory = new Inventory(@"..\..\..\..\..\my-gear-list.json", 75);
            
            Console.WriteLine("Pre-computing all build combinations...");
            var buildsCount = inventory.GenerateBuildCombinationCache("csharp");
            Console.WriteLine(string.Format("\nCompleted - created {0} build combinations", buildsCount));

            var cacheName = "csharp";
            var engine = new FilterEngine(cacheName, 3);

            var filters = new List<FilterPipelineStep>
            {
                new FilterPipelineStep { Filter="EnsureAtLeast", Parameters = new Dictionary<string,string>(){ { "stat", "firearms" }, { "min_value", "3832" }} },
                new FilterPipelineStep { Filter="EnsureAtLeast", Parameters = new Dictionary<string,string>(){ { "stat", "stamina" }, { "min_value", "3832" }} }
            };
            engine.Filters = filters;

            engine.Process();

        }
    }
}
