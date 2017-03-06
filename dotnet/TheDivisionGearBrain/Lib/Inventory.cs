using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;

namespace Lib
{
    public class Inventory
    {
        private const string ITEM_TYPE_FIELD = "item_type";
        private const string ITEM_HASH_FIELD = "base64_hash";

        public enum ItemType
        {
            vest = 0,
            mask = 1,
            kneepads = 2,
            backpack = 3,
            gloves = 4,
            holster = 5
        }
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

        public Dictionary<ItemType, List<Dictionary<string, string>>> Items { get; set; }

        public Inventory(string datafile)
        {
            Items = new Dictionary<ItemType, List<Dictionary<string, string>>>
            {
                { ItemType.vest, new List<Dictionary<string, string>>() },
                { ItemType.mask, new List<Dictionary<string, string>>() },
                { ItemType.kneepads, new List<Dictionary<string, string>>() },
                { ItemType.backpack, new List<Dictionary<string, string>>() },
                { ItemType.gloves, new List<Dictionary<string, string>>() },
                { ItemType.holster, new List<Dictionary<string, string>>() }
            };

            using (var sr = new StreamReader(datafile)) {
                var rawItems = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(sr.ReadToEnd());
                foreach (var item in rawItems)
                {
                    var key = (ItemType)Enum.Parse(typeof(ItemType), item[ITEM_TYPE_FIELD].ToLower());
                    //item.Add(ITEM_HASH_FIELD, )
                    Items[key].Add(item);
                }
            }
        }

        public int GenerateBuildCombinationCache(string name)
        {
            string itemCacheFilename = string.Format("{0}-items.dat", name);
            string buildCacheFilename = string.Format("{0}-builds.dat", name);

            foreach (var item in this.Items)
            {
                // create item cache
            }

            var numBuilds = 0;
            using (var sw = new StreamWriter(buildCacheFilename))
            {
                numBuilds = findBuildCombinations(sw, ItemType.vest);
            };

            return numBuilds;
        }

        private int findBuildCombinations(StreamWriter sw, ItemType itemType, List<Dictionary<string,string>> itemsInBuild = null, int buildCount = 0)
        {
            bool buildComplete = false;
            if (itemsInBuild == null) itemsInBuild = new List<Dictionary<string, string>>();

            if ((int)itemType == Enum.GetValues(typeof(ItemType)).Length - 1)
            {
                buildComplete = true;
            }

            foreach (var item in this.Items[itemType])
            {
                itemsInBuild.Add(item);
                if (!buildComplete)
                {
                    // recurse
                    var nextItemType = (ItemType)((int)itemType + 1);
                    buildCount = findBuildCombinations(sw, nextItemType, itemsInBuild, buildCount);
                }
                else
                {
                    buildCount++;
                    var aggregatedStats = calculateAggregateBuildStats(itemsInBuild);

                    // create build cache - using hash to refer to each item and including the aggregate values
                }
            }

            return buildCount;
        }

        private Dictionary<Stats, decimal> calculateAggregateBuildStats(List<Dictionary<string,string>> buildItems)
        {
            var aggStats = new Dictionary<Stats, decimal>();
            foreach (var stat in Enum.GetNames(typeof(Stats)))
            {
                var aggValue = buildItems.Where(i => i.ContainsKey(stat)).Sum(i => Convert.ToDecimal(i[stat]));
                aggStats[(Stats)Enum.Parse(typeof(Stats), stat)] = aggValue;
            }

            return aggStats;
        }
    }
}
