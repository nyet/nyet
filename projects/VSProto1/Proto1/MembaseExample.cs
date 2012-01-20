using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Enyim.Caching.Memcached;
using Membase;

namespace Proto1
{
    class MembaseExample
    {
        static void Main(string[] args)
        {
            using (var client = new MembaseClient())
            {
                String spoon = null;

                if ((spoon = client.Get<string>("Spoon")) == null)
                {
                    Console.WriteLine("There is no spoon!");
                    client.Store(StoreMode.Set,
                                 "Spoon",
                                 "Hello, Membase!",
                                 TimeSpan.FromMinutes(1));
                }
                else
                {
                    Console.WriteLine(spoon);
                }
            }
        }
    }
}
