using System.IO;
using System.Diagnostics;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;
using System.Runtime.Serialization.Formatters.Binary;
//using System.Runtime.Serialization.Formatters.Soap;
using System.Xml.Serialization;
using System.Collections;
using System;

namespace Proto1
{
    public class SerTest {
        public static void Main() {
            MySettings ms = new MySettings();
            ms.screenDx = 1;

            Settings.Save(ms, "ms.txt");

            return;
        }	//end of main
    }	// end of SerTest

    [Serializable]
    public class MySettings {
        public int screenDx;
        public ArrayList recentlyOpenedFiles;
        [NonSerialized]
        public string dummy;
    }

    public class Settings
    {
        const int VERSION = 1;
        public static void Save(MySettings settings, string fileName)
        {
            Stream stream = null;
            try
            {
                /*
                IFormatter formatter = new BinaryFormatter();
                stream = new FileStream(fileName, FileMode.Create, FileAccess.Write, FileShare.None);
                formatter.Serialize(stream, VERSION);
                formatter.Serialize(stream, settings);
                */

                XmlSerializer x = new XmlSerializer(settings.GetType());
                stream = new FileStream(fileName, FileMode.Create, FileAccess.Write, FileShare.None);
                x.Serialize(stream, settings);
            }
            catch
            {
                // do nothing, just ignore any possible errors
            }
            finally
            {
                if (null != stream)
                    stream.Close();
            }
        }

        public static MySettings Load(string fileName)
        {
            Stream stream = null;
            MySettings settings = null;
            try
            {
                IFormatter formatter = new BinaryFormatter();
                stream = new FileStream(fileName, FileMode.Open, FileAccess.Read, FileShare.None);
                int version = (int)formatter.Deserialize(stream);
                Debug.Assert(version == VERSION);
                settings = (MySettings)formatter.Deserialize(stream);
            }
            catch
            {
                // do nothing, just ignore any possible errors
            }
            finally
            {
                if (null != stream)
                    stream.Close();
            }
            return settings;
        }
    }
}
