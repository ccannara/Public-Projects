#include <iostream>
#include <fstream>
#include <cstring>
#include <vector>

#include <thread>
#include <mutex>

#include <arpa/inet.h>
#include <unistd.h>

std::mutex mutex;
std::vector<u_short> ports;
void search(const int startPort, const int endPort, const char *addr);

int main(int argc, char **argv)
{
  if ((argc != 4) & (argc != 5))
  {
    printf("Correct usage is: %s <target ip> <first port> <second port>\n", argv[0]);
    return 0;
  }

  const u_short sPort1 = atoi(argv[2]), ePort2 = atoi(argv[3]);
  std::string addr[255];

  u_short counter = 0;
  int hostCount = 0;

  const int ePort1 = (sPort1 + ePort2) / 2;
  const int sPort2 = ePort1 + 1;

  // Send IP to bash file to search
  std::string command = "./pingall.sh ";
  command += argv[1];
  system(command.c_str());

  // Open the logs and grab all active IPs being used by devices on network
  std::fstream file("log.txt", std::ios::in);
  while (!file.eof())
  {
    std::getline(file, addr[hostCount]);
    hostCount++;
  }
  hostCount--;

  // Scan each port of each IP
  for (int i = 0; i < hostCount; i++)
  {
    const char *addr2 = addr[i].c_str();
    printf("Open ports on %s: \n", addr2);

    // Make two threads instead of one thread by partitioning the ports in half
    // Did this for my device because it is faster, but may not prove faster
    // for other devices
    std::thread(&search, sPort1, ePort1, addr2).join();
    std::thread(&search, sPort2, ePort2, addr2).join();

    while (counter < ports.size())
    {
      printf("    Port %d open\n", ports[counter]);
      counter++;
    }
    printf("\n");
  }
  printf("Scan Complete.\n");

  return 0;
}

void search(const int startPort, const int endPort, const char *addr)
{
  // Scoped Lock for temporary usage
  std::scoped_lock lock(mutex);

  struct sockaddr_in address;
  int sock;

  for (int i = startPort; i <= endPort; i++)
  {
    memset((void *)&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = inet_addr(addr);
    address.sin_port = htons(i);

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
      std::cout << "Error creating socket: ";
      std::cout << std::strerror(errno) << std::endl;
      return;
    }

    if (connect(sock, (const struct sockaddr *)&address, sizeof(address)) == 0)
      ports.push_back(i);

    close(sock);
  }
}