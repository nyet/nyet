using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Proto1
{
    class TimeStuff
    {
        public static void Main()
        {
            DateTime current = DateTime.Now;
            Console.WriteLine("Year:        {0}", current.Year);
            Console.WriteLine("Month:       {0}", current.Month);
            Console.WriteLine("Day:         {0}", current.Day);
            //Console.WriteLine("Hour:        {0}", current.Hour);
            //Console.WriteLine("Minute:      {0}", current.Minute);
            //Console.WriteLine("Second:      {0}", current.Second);
            //Console.WriteLine("Millisecond: {0}", current.Millisecond);

            DateTime current2 = current.AddDays(30);
            Console.WriteLine("Year:        {0}", current2.Year);
            Console.WriteLine("Month:       {0}", current2.Month);
            Console.WriteLine("Day:         {0}", current2.Day);
            //Console.WriteLine("Hour:        {0}", current.Hour);
            //Console.WriteLine("Minute:      {0}", current.Minute);
            //Console.WriteLine("Second:      {0}", current.Second);
            //Console.WriteLine("Millisecond: {0}", current.Millisecond);

            string newOrderNumber = "1B0926"; //092611203327
            DateTime current1 = DateTime.Now;
            string ix = newOrderNumber + current1.ToString("MMddyyhhmmss");
            Console.WriteLine("ix: {0}", ix);
        }
    }
}
