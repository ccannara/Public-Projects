Virus Detection and File Integrity Monitor

The comparator (./anti) takes a file as input, calculates its MD5 signature and compares it against a registry of known virus signatures. 
In this implementation, the registry is "VirusShare_00000.md5.txt". The monitor (monitor.sh) examines a folder (.src/*) in real time and 
uses the comparator against files that have been added/altered. As soon as a file is added, deleted, or altered, the folder will be scanned.

IMPORTANT: This implementation views any file with MD5 '3e25960a79dbc69b674cd4ec67a72c62' as a virus. This equates to any file that has 
contents "Hello world". Thus, it is important to note that ./src/virus.txt is not a virus - it is a text file that says "Hello world". 
This was implemented for testing and interactive purposes to prove functionality.

Compile comparator with: bash compile.sh
Correct usage is: ./anti <file>
Correct usage is: ./monitor.sh

Usage example:
./anti anti.cpp
./anti ./src/example.jpg
./monitor.sh

Credits:
MD5 Hashes are courtesy of VirusShare.com (https://www.virusshare.com/hashes)
"md5.cpp" and "md5.h" are created by Frank Thilo (thilo@unix-ag.org) for bzflag (http://www.bzflag.org)