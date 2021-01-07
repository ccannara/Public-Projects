#include <iostream>
#include "point.hpp"

Point::Point()
{
}

Point::Point(long long x1, long long y1)
{
  x = x1;
  y = y1;
}

long long Point::getX() { return x; }
long long Point::getY() { return y; }