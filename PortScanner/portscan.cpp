#include <iostream>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <cstring>
#include <fcntl.h>

int main(int argc, char **argv)
{
  if (argc != 4)
  {
    printf("Correct usage is: %s <target ip> <first port> <second port>\n", argv[0]);
    return 0;
  }

  char *targetIP = argv[1];

  // Make sure port is valid
  int sPort = atoi(argv[2]), ePort = atoi(argv[3]);
  sPort = (65536 < sPort) ? 65536 : sPort;
  sPort = (1 > sPort) ? 1 : sPort;
  ePort = (65536 < ePort) ? 65536 : ePort;
  ePort = (1 > ePort) ? 1 : ePort;

  struct sockaddr_in addr, target;
  int sock = 0;

  memset(&target, '0', sizeof(target));
  target.sin_family = AF_INET;

  // Check to see if IP is valid (can be converted to binary)
  if (inet_pton(AF_INET, targetIP, &target.sin_addr) <= 0)
  {
    std::cout << "Cannot convert target IP to binary" << std::endl;
    return 0;
  }

  // Check each port is open
  for (int i = sPort; i <= ePort; i++)
  {
    target.sin_port = htons(i);

    // Connection is refused with given IP. Could happen if IP is not
    // valid, if a firewall is blocking access, if IP is "asleep" (not able
    // to be pinged), etc.
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
      std::cout << "Error creating socket: ";
      std::cout << std::strerror(errno) << std::endl;
      return 0;
    }

    printf("Open ports on %s:\n", argv[1]);
    if ((connect(sock, (struct sockaddr *)&target, sizeof(target)) < 0))
      std::cout << "    Port " << i << " open " << std::endl;

    close(sock);
  }

  return 1;
}