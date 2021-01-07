#include <iostream>
#include "quad.hpp"

Quad::Quad()
{
}

Quad::Quad(long long x1, long long y1, long long width, long long height)
{
  x = x1;
  y = y1;
  w = width;
  h = height;
}

long long Quad::getX() { return x; }
long long Quad::getY() { return y; }
long long Quad::getWidth() { return w; }
long long Quad::getHeight() { return h; }