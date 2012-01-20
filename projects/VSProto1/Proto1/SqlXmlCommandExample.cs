using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using System.Xml;

namespace Proto1
{
    class SqlXmlCommandExample
    {
        static String SessionConnectionStr = "Data Source=QAWEB-JAX01\\SQLEXPRESS;Initial Catalog=ImpactLTDB;Integrated Security=true;";
        public static void Main()
        {
            System.Console.WriteLine("SessionConnectionStr=" + SessionConnectionStr);
            System.Console.WriteLine("SqlCommand");
            SqlConnection _connection;
            SqlCommand cmd = null;
            try
            {
                _connection = new SqlConnection(SessionConnectionStr);
                _connection.Open();
                cmd = new SqlCommand();
                cmd.Connection = _connection;
                cmd.CommandType = CommandType.Text;
                FileInfo file = new FileInfo("SQLSelectTest1.sql");
                //string SQLTxt = file.OpenText().ReadToEnd(); 
                cmd.CommandText = file.OpenText().ReadToEnd(); 
                //cmd.CommandText = "SELECT * FROM SessionInfo;";
                SqlDataReader reader = cmd.ExecuteReader();
                Console.WriteLine("\tField count: {0}", reader.FieldCount);
                int rowCount = 0;
                if (reader.Read())
                {
                    System.Console.WriteLine("\t{0}:{1}:{2}", rowCount, reader["key1"], reader["value1"]);
                    rowCount++;
                }
                reader.Close();
                _connection.Dispose();
            }
            finally
            {
                if ((cmd != null))
                {
                    cmd.Dispose();
                }
            }

            /*
            System.Console.WriteLine("SqlXmlCommand");
            SqlXmlCommand cmd2 = new SqlXmlCommand(SessionConnectionStr);
            System.Console.WriteLine("\tcmd2=[" + cmd2 + "]");
            cmd2.CommandType = SqlXmlCommandType.TemplateFile;
            cmd2.CommandText = "SQLSelectTest1.xml";
            Stream strm = cmd2.ExecuteStream();
            StreamReader sw = new StreamReader(strm);
            System.Console.WriteLine(sw.ReadToEnd());
            
            //cmd2.CommandText = "SELECT * FROM SessionInfo;";
            try
            {
                XmlReader Reader = cmd2.ExecuteXmlReader();
                XmlTextWriter tw = new XmlTextWriter(Console.Out);
                Reader.MoveToContent();
                tw.WriteNode(Reader, false);
                tw.Flush();
                tw.Close();
            }
            catch (Exception e)
            {
                System.Console.WriteLine(e.Message);
            }
            */

            /*
            int rowCount = 0;
            SqlDataReader reader = cmd.ExecuteXmlReader();
            while (reader.Read())
            {
                TestData.orderNumber = (int)reader["value1"];
                CLogger.WriteLog(ELogLevel.INFO, "SQLGetOrderNumber.xml:newOrderNumber:" + TestData.orderNumber);
                rowCount++;
            }
            reader.Close();
            */
        }
    }
}
