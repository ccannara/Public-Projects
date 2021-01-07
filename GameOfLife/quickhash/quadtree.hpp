#include <unordered_set>
#include "point.cpp"
#include "quad.cpp"

class QuadTree
{
public:
  QuadTree();
  QuadTree(Quad, long long);
  void insert(Point);
  void subdivide();

  static QuadTree northwest;
  static QuadTree northeast;
  static QuadTree southwest;
  static QuadTree southeast;

private:
  Quad bound;
  long long capacity;
  static std::unordered_set<Point> points;
  bool split;
};