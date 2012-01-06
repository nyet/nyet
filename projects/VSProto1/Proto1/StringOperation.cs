using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Proto1
{
    class StringOperation
    {
        public static void Main() {
            string ReceiptNumber1 = "000000000000409";
            Console.WriteLine("receiptNumber: {0}", ReceiptNumber1);
            long lCurrentReceiptNumber = Convert.ToInt64(ReceiptNumber1);
            string result = String.Format("{0,0:000000000000000}", ++lCurrentReceiptNumber);
            //string result = String.Format("{0,0:000000000000000}", 3);
            Console.WriteLine("receiptNumber: {0}", result);

            Regex r = new Regex("^\\d+$", RegexOptions.IgnoreCase);
            Match m = r.Match(ReceiptNumber1);
            if (m.Success)
            {
                Console.WriteLine("receiptNumber({0}) is numbers", ReceiptNumber1 );
            }
            
        }
    }
}
