using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Proto1
{
    class RegExTest
    {
        static string CapText(Match m)
        {
            // Get the matched string.
            string x = m.ToString();
            // If the first char is lower case...
            if (char.IsLower(x[0]))
            {
                // Capitalize it.
                return char.ToUpper(x[0]) + x.Substring(1, x.Length - 1);
            }
            return x;
        }

        public static void Main()
        {
            //testReplacement();
            /*
            //Regex r = new Regex("Transaction: (\\S+)");
            //Match m = r.Match("Transaction: Login");

            Regex r = new Regex("Transaction(Open|Close): (\\S+)");
            Match m = r.Match("TransactionClose: Login");

            for (int i = 0; m.Groups[i].Value != ""; i++)
            {
                // Copy groups to string array.
                Console.WriteLine("results[{0}] = {1}", i, m.Groups[i].Value);
                // Record character position.
                Console.WriteLine("matchposition[{0}] = {1}", i, m.Groups[i].Index);
            }
            */

            /*
            Console.WriteLine("Number of groups found = " + m.Groups.Count);
            GroupCollection gc = m.Groups;
            for (int i = 0; i < gc.Count; i++)
            {
                CaptureCollection cc = gc[i].Captures;
                int counter = cc.Count;

                // Print number of captures in this group.
                Console.WriteLine("Captures count = " + counter.ToString());

                // Loop through each capture in group.
                for (int ii = 0; ii < counter; ii++)
                {
                    // Print capture and position.
                    Console.WriteLine("'" + cc[ii] + "' ->  Starts at character " + cc[ii].Index);
                }
            }
            */

            string text = "four score and seven years ago";
            System.Console.WriteLine("text=[" + text + "]");
            Regex rx = new Regex(@"\w+");
            string result = rx.Replace(text, new MatchEvaluator(RegExTest.CapText));
            System.Console.WriteLine("result=[" + result + "]");
        }

        public void testReplacement()
        {
            String original = @"CaseNumber: {{DecisionLoanDataSource.DecisionLoan#csv.CaseNumber}}, LoanNumber: {{DecisionLoanDataSource.DecisionLoan#csv.LoanNumber}}";

        }

        
    }
}
