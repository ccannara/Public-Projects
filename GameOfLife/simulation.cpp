#include <iostream>
#include <unistd.h>
#include <fstream>
#include <vector>

const char ALIVE = '@';
const char DEAD = '.';

bool readMap(const char *fileName, std::vector<std::string> &vecOfStrs);
void printGrid(const std::vector<std::string> &map);
void generate(std::vector<std::string> &map);

int main(int argc, const char *argv[])
{
  if (argc != 2)
  {
    printf("Correct usage is: %s <file name>\n", argv[0]);
    return 0;
  }

  std::vector<std::string> map;
  if (!readMap(argv[1], map))
    return 0;

  bool cont = true;
  long long genCount = 0;
  printf("Output for %s\n", argv[1]);

  printf("\nGeneration %llu ==========\n", genCount);
  printGrid(map);

  while (cont)
  {
    printf("\nProgress how many generations? : ");
    char *p, s[100];
    fgets(s, sizeof(s), stdin);
    long long n = strtol(s, &p, 10);
    cont = n > 0;

    for (int i = 0; i < n; i++)
    {
      genCount++;
      generate(map);
      printf("Generation %llu ==========\n", genCount);
      printGrid(map);

      usleep(200000);
    }
  }

  return 1;
}

bool readMap(const char *fileName, std::vector<std::string> &vec)
{
  std::ifstream in(fileName);

  if (!in)
  {
    printf("Cannot open the File : %s \n", fileName);
    return false;
  }

  std::string str;
  while (std::getline(in, str))
  {
    if (str.size() > 0)
      vec.push_back(str);
  }

  in.close();
  return true;
}

void printGrid(const std::vector<std::string> &map)
{
  for (const std::string &line : map)
    std::cout << line << std::endl;
}

void generate(std::vector<std::string> &map)
{
  std::vector<std::string> map2 = map;
  int x, y;

  for (int a = 1; a < map2.size() - 1; a++)
  {
    for (int b = 1; b < map2[a].size() - 1; b++)
    {
      int alive = 0;
      for (int c = -1; c < 2; c++)
      {
        y = a + c;
        if (y < 0)
          y = map2.size() - 1;
        else if (y > map2.size() - 1)
          y = 0;

        for (int d = -1; d < 2; d++)
        {
          x = b + d;
          if (x < 0)
            x = map2[y].size() - 1;
          else if (x > map2[y].size() - 1)
            x = 0;

          if (!(c == 0 && d == 0))
          {
            if (map2[y].at(x) == ALIVE)
              alive++;
          }
        }
      }

      if (alive == 3)
        map[a].at(b) = ALIVE;
      else if (alive != 2)
        map[a].at(b) = DEAD;
    }
  }
}