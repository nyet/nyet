using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Proto1
{
    class LoadTestDataTestDriver
    {
        public static void Main()
        {
            const int SessionContainerType = 1; //SQLServer/DB for distributed test execution
            const String SessionContainerString = "Data Source=LSUSANTO-M3V1\\SQLEXPRESS;Initial Catalog=ImpactLTDB;Integrated Security=true;";
            System.Console.WriteLine("SessionContainerType:  " + SessionContainerType);
            System.Console.WriteLine("SessionContainerString:" + SessionContainerString);
            LoadTestDataFactory TestData = new LoadTestDataFactory(SessionContainerType, SessionContainerString);
            System.Console.WriteLine("TestData is loaded");





            try
            {
                System.Console.WriteLine("hash_add"); TestData.hash_add("key_12", "1");
                System.Console.WriteLine("hash_get(key_12): " + TestData.hash_get("key_12"));

                //System.Console.WriteLine("orderNumber: " + TestData.get("orderNumber"));
            }
            catch (Exception e)
            {
                System.Console.WriteLine("get.e.Message:" + e.Message);
            }
        }
    }
}
