using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Proto1
{
    [Serializable()]
    public class LoadTestData
    {
        public int orderNumber;
        public string orderIndex;

        public LoadTestData() { }

        public LoadTestData(int order_number, string order_index) 
        {
            this.orderNumber = order_number;
            this.orderIndex = order_index;
        }
    }
}
