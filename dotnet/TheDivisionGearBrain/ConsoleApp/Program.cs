using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            var inventory = new Lib.Inventory(@"..\..\..\..\..\my-gear-list.json", 75);
            
            Console.WriteLine("Pre-computing all build combinations...");
            var buildsCount = inventory.GenerateBuildCombinationCache("csharp");
            Console.WriteLine(string.Format("\nCompleted - created {0} build combinations", buildsCount));

            var cacheName = "csharp";

        }
    }
}
