using System;
using System.Security.Cryptography;
using System.Text;

namespace __NAME__.Utils
{
    public class Encryption
    {
        public string Encrypt(string message, string salt)
        {

            if (string.IsNullOrEmpty(salt))
            {
                salt = ConfigData.DefaultSalt;
            }

            message += salt;
            byte[] bytes = Encoding.Unicode.GetBytes(message);
            byte[] inArray = HashAlgorithm.Create("SHA1").ComputeHash(bytes);

            return Convert.ToBase64String(inArray);
        }
    }
}