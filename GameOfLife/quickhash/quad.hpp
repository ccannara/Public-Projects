class Quad
{
public:
  Quad();
  Quad(long long, long long, long long, long long);
  long long getX();
  long long getY();
  long long getWidth();
  long long getHeight();

private:
  long long x;
  long long y;
  long long w;
  long long h;
};