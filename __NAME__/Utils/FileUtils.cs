using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;

namespace __NAME__.Utils
{
    public class FileUtils
    {
        private static string _StoragePath;
        public static string StoragePath 
        {
            get 
            {
                if (string.IsNullOrWhiteSpace(_StoragePath))
                {
                    _StoragePath = ConfigurationManager.AppSettings["StoragePath"];
                    var folder = new DirectoryInfo(_StoragePath);
                    if (!folder.Exists)
                        folder.Create();
                }
                return _StoragePath; 
            }
            
        }
    }
}