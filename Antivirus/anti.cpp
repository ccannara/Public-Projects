#include <iostream>
#include <fstream>
#include <sstream>
#include "md5.h"

const std::string directory = "VirusShare_00000.md5.txt";

std::string FileToStr(const char *path)
{
  std::ostringstream ss = std::ostringstream{};
  std::ifstream input(path);

  if (!input.is_open())
  {
    std::cerr << "Could not read '" << path << "'\n";
    exit(EXIT_FAILURE);
  }

  ss << input.rdbuf();
  return ss.str();
}

int scan(std::string m)
{
  std::ifstream dir(directory);
  std::string line;

  if (!dir.is_open())
  {
    std::cerr << "'" << directory << "' does not exist in directory\n";
    exit(EXIT_FAILURE);
  }

  while (getline(dir, line))
  {
    if (line.compare(m) == 0)
    {
      printf("VIRUS DETECTED!\n");
      return 0;
    }
  }

  printf("Virus undetected.\n");
  return 0;
}

int main(int argc, const char *argv[])
{
  if (argc != 2)
    return printf("Correct usage is: %s <file>\n", argv[0]);

  std::string m = md5(FileToStr(argv[1]));
  printf("MD5 of %s: %s\n", argv[1], m.c_str());

  scan(m);

  return 0;
}