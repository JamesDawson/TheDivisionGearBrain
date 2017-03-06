using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lib
{
    public interface IFilter
    {
        bool Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters);
    }

    public class EnsureAtLeastFilter : IFilter
    {
        public bool Process(List<GearItem> buildItems, Dictionary<string,decimal> buildStats, Dictionary<string, string> parameters)
        {
            return false;
        }
    }

    public class UnlockNamedGearSet : IFilter
    {
        public bool Process(List<GearItem> buildItems, Dictionary<string, decimal> buildStats, Dictionary<string, string> parameters)
        {
            return false;
        }
    }
}
