using System.Configuration;

namespace __NAME__.Utils
{
    public static class ConfigData
    {
        public static string DefaultSalt
        {
            get { return ConfigurationManager.AppSettings["DefaultSalt"]; }
        }

        public static string EmailFrom
        {
            get { return ConfigurationManager.AppSettings["EmailFrom"]; }
        }

        public static string EmailPass
        {
            get { return ConfigurationManager.AppSettings["EmailPass"]; }
        }

        public static string EmailNewAccountBody
        {
            get { return ConfigurationManager.AppSettings["EmailNewAccountBody"]; }
        }

        public static string EmailNewAccountSubject
        {
            get { return ConfigurationManager.AppSettings["EmailNewAccountSubject"]; }
        }

        public static string SmtpAddress
        {
            get { return ConfigurationManager.AppSettings["SmtpAddress"]; }
        }

        public static string SmtpPort
        {
            get { return ConfigurationManager.AppSettings["PortNumber"]; }
        }


    }
}