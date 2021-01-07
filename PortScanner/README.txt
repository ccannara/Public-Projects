Simple and Concurrent Portscan C++ Implementations

pscan and fpscan both ping the given argument IP's ports in the given ranges
fpscan utilizes pingall.sh to ping all ports 1 to 255 of an active IP

Compile with: bash compile.sh
Correct usage is: ./pscan <target ip> <starting port> <ending port>
Correct usage is: ./fpscan <target ip> <starting port> <ending port>

For pscan, the target IP should be in the form xxx.xxx.x.x
For fpscan, the target IP should be in the form xxx.xxx.x

Usage example:
./pscan 192.168.1.1 80 80
./fpscan 192.168.1 80 80
These check to see if port 80 is open (HTML)