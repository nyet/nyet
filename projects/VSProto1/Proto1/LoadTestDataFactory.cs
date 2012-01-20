using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Runtime.Serialization;
using System.Data.SqlTypes;

namespace Proto1
{
    class LoadTestDataFactory
    {
        private int sessionContainerType;
        private string sessionContainerString;
        private SqlConnection _connection = null;
        private LoadTestData TestData = new LoadTestData();

        public LoadTestDataFactory(int SessionContainerType, string SessionContainerString)
        {
            this.sessionContainerType = SessionContainerType;
            this.sessionContainerString = SessionContainerString;

            if (this.sessionContainerType == 1)
            {
                this._connection = new SqlConnection(sessionContainerString);
                this._connection.Open();
                TestData.orderIndex = "L";
            }
        }

        public void hash_add(string key, string value) {
            if (sessionContainerType == 1)
            {
                SqlCommand cmd = null;
                try
                {
                    cmd = new SqlCommand();
                    cmd.Connection = _connection;
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = System.IO.File.ReadAllText("LTDF_Hash_AddElement.sql");
                    Nullable<SqlString> p0 = key;
                    Nullable<SqlString> p1 = value;
                    cmd.Parameters.AddWithValue("@p0", p0);
                    cmd.Parameters.AddWithValue("@p1", p1);
                    cmd.ExecuteNonQuery();
                }
                finally
                {
                    if ((cmd != null))
                    {
                        cmd.Dispose();
                    }
                }
            }
        }

        public void set(string key, string value) {
            if (sessionContainerType == 1)
            {
                SqlCommand cmd = null;
                SqlDataReader reader = null;
                try
                {
                    cmd = new SqlCommand();
                    cmd.Connection = _connection;
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = System.IO.File.ReadAllText("LTDFAdd.sql");
                    Nullable<SqlString> p0 = key;
                    cmd.Parameters.AddWithValue("@p0", p0);
                    reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        value = (string)reader["value1"];
                    }
                    reader.Close();
                    
                }
                finally
                {
                    if ((cmd != null))
                    {
                        cmd.Dispose();
                    }
                }
            }            
        }

        public string hash_get(string key) {
            string value = null;
            if (sessionContainerType == 1)
            {
                SqlCommand cmd = null;
                SqlDataReader reader = null;
                try
                {
                    cmd = new SqlCommand();
                    cmd.Connection = _connection;
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = System.IO.File.ReadAllText("LTDF_Hash_GetElement.sql");
                    Nullable<SqlString> p0 = key;
                    cmd.Parameters.AddWithValue("@p0", p0);
                    reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        value = (string)reader["value1"];
                    }
                    reader.Close();
                    return value;
                }
                finally
                {
                    if ((cmd != null))
                    {
                        cmd.Dispose();
                    }
                }
            }
            return value;
        }

        public string increment(string key) {
            return null;
        }

        public string decrement(string key) {
            return null;
        }

        public string push(string key, string value) {
            return null;
        }

        public string pop(string key) {
            return null;
        }



        public int getNewOrderNumber()
        {
            if (sessionContainerType == 1)
            {
                SqlCommand cmd = null;
                SqlDataReader reader = null;
                try
                {
                    cmd = new SqlCommand();
                    cmd.Connection = _connection;
                    cmd.CommandType = CommandType.Text;
                    FileInfo file = new FileInfo("SQLGetOrderNumber.sql");
                    cmd.CommandText = file.OpenText().ReadToEnd();
                    reader = cmd.ExecuteReader();
                    int rowCount = 0;
                    if (reader.Read())
                    {
                        String value1 = (String)reader["value1"];
                        value1.Trim();
                        TestData.orderNumber = Int32.Parse(value1);
                        rowCount++;
                    }
                    reader.Close();
                    return TestData.orderNumber;
                }
                finally
                {
                    if ((cmd != null))
                    {
                        cmd.Dispose();
                    }
                }
            }
            else if (sessionContainerType == 2)
            {
                return ++TestData.orderNumber;
            }
            
            return 0;
        }

        public int orderNumber()
        {
            return TestData.orderNumber;
        }

        public string orderIndex()
        {
            return TestData.orderIndex;
        }
    }
}
