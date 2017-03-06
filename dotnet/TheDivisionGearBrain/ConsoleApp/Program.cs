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
            var inventory = new Lib.Inventory(@"D:\PROJECTS\TheDivisionGearBrain\my-gear-list.json");
            var buildsCount = inventory.GenerateBuildCombinationCache("csharp");
        }
    }
}
