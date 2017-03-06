using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;

namespace Lib
{
    public class GearItem
    {
        public string Name { get; set; }
        public string Quality { get; set; }
        public string ItemType { get; set; }
        public string Id { get; set; }
        public Dictionary<string, decimal> Stats { get; set; }

        public GearItem(Dictionary<string, string> item)
        {
            this.Name = item["name"];
            item.Remove("name");
            this.ItemType = item["item_type"];
            item.Remove("item_type");
            this.Quality = item["quality"];
            item.Remove("quality");
            this.Id = Guid.NewGuid().ToString();

            this.Stats = new Dictionary<string,decimal>();
            foreach (var stat in item.Keys)
            {
                try
                {
                    this.Stats.Add(stat, Convert.ToDecimal(item[stat]));
                }
                catch
                {
                    // assume a zero value for any bad conversions
                    this.Stats.Add(stat, 0);
                }
            }
        }
    }

    public class CachedBuildInfo
    {
        public List<string> Items { get; set; }
        public Dictionary<string, decimal> Stats { get; set; }

        public CachedBuildInfo(List<string> items, Dictionary<string,decimal> stats)
        {
            this.Items = items;
            this.Stats = stats;
        }
    }

    public class Inventory
    {
        private const string ITEM_TYPE_FIELD = "item_type";
        //private const string ITEM_HASH_FIELD = "base64_hash";

        public enum ItemType
        {
            vest = 0,
            mask = 1,
            kneepads = 2,
            backpack = 3,
            gloves = 4,
            holster = 5
        }
        private readonly string[] ItemTypesAsString;
        
        public enum Stats
        {
            firearms,
            stamina,
            electronics,
            armor,
            health,
            allresist,
            hp_on_kill,
            protection_from_elites,
            exotic_dmg_resilience,
            critchance,
            critdamage,
            smg_damage,
            ar_damage,
            shotgun_dmg,
            lmg_dmg,
            pistol_dmg,
            mmr_dmg,
            enemyarmordmg,
            skillhaste,
            skillpower,
            weaponstab,
            wepreloadspd,
            sig_res_gain,
            dmg_vs_elites,
            shockresist,
            burnresist,
            disorientresist,
            blinddeafresist,
            disruptresist,
            bleedresist,
            killxp,
            ammocap
        }
        private readonly string[] StatsAsString;

        //public Dictionary<ItemType, List<Dictionary<string, string>>> Items { get; set; }
        public Dictionary<string, List<GearItem>> Items { get; set; }

        public Inventory(string datafile, int minPercentile = 50)
        {
            this.StatsAsString = Enum.GetNames(typeof(Stats));
            this.ItemTypesAsString = Enum.GetNames(typeof(ItemType));

            Items = new Dictionary<string, List<GearItem>>
            {
                { "vest", new List<GearItem>() },
                { "mask", new List<GearItem>() },
                { "kneepads", new List<GearItem>() },
                { "backpack", new List<GearItem>() },
                { "gloves", new List<GearItem>() },
                { "holster", new List<GearItem>() }
            };

            int rawItemCount = 0;
            int itemCount = 0;
            using (var sr = new StreamReader(datafile)) {
                Console.WriteLine("Importing items from data file...");
                var rawItems = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(sr.ReadToEnd());
                foreach (var item in rawItems)
                {
                    var gearItem = new GearItem(item);
                    if (ensureMinimumPercentile(gearItem, minPercentile))
                    {                 
                        Items[gearItem.ItemType.ToLower()].Add(gearItem);
                        itemCount++;
                    }
                    rawItemCount++;
                }
            }
            Console.WriteLine(string.Format(" Completed importing {0} items.\n  Excluded {1} items due to minimum stat criteria.", itemCount, (rawItemCount - itemCount)));
        }

        public int GenerateBuildCombinationCache(string name)
        {
            string itemCacheFilename = string.Format("{0}-items.dat", name);
            string buildCacheFilename = string.Format("{0}-builds.dat", name);

            Console.WriteLine("Generating item cache file...");
            using (var sw = new StreamWriter(itemCacheFilename))
            {
                sw.Write(JsonConvert.SerializeObject(this.Items));
            }

            Console.WriteLine("Generating build cache file...");
            var numBuilds = 0;
            using (var sw = new StreamWriter(buildCacheFilename))
            {
                numBuilds = findBuildCombinations(this.Items, sw, 0);
            };

            return numBuilds;
        }



        private int findBuildCombinations(Dictionary<string, List<GearItem>> itemsToProcess, StreamWriter sw, int itemType, List<GearItem> itemsInBuild = null, int buildCount = 0)
        {
            bool buildComplete = false;
            if (itemsInBuild == null) itemsInBuild = new List<GearItem>();

            // Last item type in a build?
            if (this.ItemTypesAsString[itemType] == "holster")
            {
                buildComplete = true;
            }

            foreach (var item in itemsToProcess[this.ItemTypesAsString[itemType]])
            {
                itemsInBuild.Add(item);
                if (!buildComplete)
                {
                    // recurse
                    var nextItemType = itemType + 1;
                    buildCount = findBuildCombinations(itemsToProcess, sw, nextItemType, itemsInBuild, buildCount);
                }
                else
                {
                    buildCount++;
                    var aggregatedStats = calculateAggregateBuildStats(itemsInBuild);

                    // create build cache - using item ID to refer to each item and including the aggregate values
                    var itemRefs = itemsInBuild.Select(i => i.Id).ToList();
                    var buildCacheEntry = new CachedBuildInfo(itemRefs, aggregatedStats);
                    sw.WriteLine(JsonConvert.SerializeObject(buildCacheEntry));                    

                    // progress reporting
                    if (buildCount % 100 == 0) Console.Write(".");
                }

                // reset the itemsInBuild array
                itemsInBuild.Remove(item);
            }

            return buildCount;
        }

        private Dictionary<string, decimal> calculateAggregateBuildStats(List<GearItem> buildItems)
        {
            var aggStats = new Dictionary<string, decimal>();
            foreach (var stat in this.StatsAsString)
            {
                var aggValue = buildItems.Where(i => i.Stats.ContainsKey(stat)).Sum(j => j.Stats[stat]);
                aggStats[stat] = aggValue;
            }

            return aggStats;
        }

        private bool ensureMinimumPercentile(GearItem item, int minPercentile = 50)
        {
            decimal minStat = 1193;
            double minArmor = 0;

            switch (item.ItemType.ToLower())
            {
                case "vest":
                    minArmor = ((2003.0 - 1704.0) / 100.0 * minPercentile) + 1704;
                    minArmor = 2003 / 100 * minPercentile;
                    break;
                case "mask":
                    minArmor = ((1001.0 - 852.0) / 100.0 * minPercentile) + 852;
                    break;
                case "kneepads":
                    minArmor = ((1668.0 - 1419.0) / 100.0 * minPercentile) + 1419;
                    break;
                case "backpack":
                    minArmor = ((1334.0 - 1135.0) / 100.0 * minPercentile) + 1135;
                    break;
                case "gloves":
                    minArmor = ((1001.0 - 852.0) / 100.0 * minPercentile) + 852;
                    break;
                case "holster":
                    minArmor = ((1001.0 - 852.0) / 100.0 * minPercentile) + 852;
                    break;
                default:
                    throw new Exception(string.Format("Unknown item type: {0}", item.ItemType));                        
            }

            var mainStatValue = (new [] { item.Stats["firearms"], item.Stats["stamina"], item.Stats["electronics"] }).Select(s => Convert.ToDecimal(s)).Max();
            return ( item.Stats["armor"] > Convert.ToDecimal(minArmor) && mainStatValue > minStat );
        }

        private string serialize(object obj)
        {
            var formatter = new BinaryFormatter();
            using (var stream = new MemoryStream())
            {
                formatter.Serialize(stream, obj);

                stream.Position = 0;
                var sr = new StreamReader(stream);
                var text = sr.ReadToEnd();

                return toHash(text);
            }
        }

        private string toHash(string str)
        {
            var bytes = Encoding.UTF8.GetBytes(str);

            var sha1 = new SHA1CryptoServiceProvider();
            byte[] result = sha1.ComputeHash(bytes);

            return Convert.ToBase64String(result);
        }
    }
}
