using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Proto1
{
    class CurrentDirectory
    {
        public static void Main()
        {
            
            System.Console.WriteLine("Directory.GetCurrentDirectory: " + Directory.GetCurrentDirectory());

            System.Console.WriteLine("Environment.CurrentDirectory: " + Environment.CurrentDirectory);
        }
    }
}
