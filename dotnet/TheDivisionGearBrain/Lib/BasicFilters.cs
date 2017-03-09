using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lib
{
    public class EnsureAtLeastFilter : IFilter
    {
        public FilterResult Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters)
        {
            var statName = parameters["stat"];
            var minValue = Convert.ToDecimal(parameters["min_value"]);

            var res = new FilterResult();
            res.Passed = buildStats[statName] > minValue;

            return res;
        }
    }

    public class UnlockNamedGearSetFilter : IFilter
    {
        public FilterResult Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters)
        {
            var gearsetName = parameters["gearset"].ToLower();
            var minGearsetItems = Convert.ToInt16(parameters["min_items"]);

            var numGearsetItems = buildItems.Where(i => i.Quality == "Named" && i.Name.ToLower().Contains(gearsetName)).Count();

            return new FilterResult { Passed = (numGearsetItems >= minGearsetItems) };
        }        
    }
}
