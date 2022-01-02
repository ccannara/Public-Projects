g++ -g -std=c++17 md5.h anti.cpp md5.cpp -o anti
# valgrind --leak-check=full -v ./sim map.txt