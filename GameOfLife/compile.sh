g++ -g -std=c++17 simulation.cpp -o sim
# valgrind --leak-check=full -v ./sim map.txt