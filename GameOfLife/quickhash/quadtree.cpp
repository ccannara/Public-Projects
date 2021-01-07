#include "quadtree.hpp"

QuadTree::QuadTree()
{
}

QuadTree::QuadTree(Quad q, long long n)
{
  bound = q;
  capacity = n;
  split = false;
}

void QuadTree::insert(Point p)
{
  if (points.size() < capacity)
    points.insert(p);
  else if (!split)
    subdivide();
}

void QuadTree::subdivide()
{
  // Get new dimensions
  long long x = bound.getX();
  long long y = bound.getY();
  long long w = bound.getWidth() / 2;
  long long h = bound.getHeight() / 2;

  // Create new quads based on new calculations
  Quad ne = Quad(x + w, y - h, w, h);
  Quad nw = Quad(x - w, y - h, w, h);
  Quad se = Quad(x + w, y + h, w, h);
  Quad sw = Quad(x - w, y + h, w, h);

  // Set quads to subquads
  northeast = QuadTree(ne, capacity);
  northwest = QuadTree(nw, capacity);
  southeast = QuadTree(se, capacity);
  southwest = QuadTree(sw, capacity);

  split = true;
}