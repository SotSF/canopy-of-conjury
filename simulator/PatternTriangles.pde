class PatternTriangles extends CartesianPattern {
  int numPoints = 50;
  Point[] points = new Point[100];
  PatternTriangles() {
    for (int i = 0; i < points.length; i++) {
      points[i] = new Point();
    }
  }
  void runDefault(Strip[] strips) {
    image.beginDraw();
    image.background(0);
    image.noStroke();
    for (int i = 0; i < points.length; i++) {
      Point point = points[i];
      point.getSiblings();
      image.fill(point.c);
      image.ellipse(point.point.x, point.point.y, 2, 2);
      image.fill(red(point.c), green(point.c), blue(point.c), point.brightness);
      image.beginShape();
      image.vertex(point.point.x, point.point.y);
      image.vertex(point.siblings[0].point.x, point.siblings[0].point.y);
      image.vertex(point.siblings[1].point.x, point.siblings[1].point.y);
      image.endShape(CLOSE);
      point.update();
      if (point.remove) {
        points[i] = new Point();
      }
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
  }

  class Point {
    PVector point;
    color c;
    float brightness;
    Point[] siblings = new Point[2];
    float xStep = 0;
    int xDirection = 1;
    int yDirection = 1;
    boolean remove = false;
    Point() {
      this.point = new PVector(random(image.width), 
        (random(100) > 50 ? random(-image.height, 0) : random(image.height, 2 * image.height)));
      if (this.point.y >= image.height) yDirection = -1;
      this.xStep = random(-2, 2);
      this.brightness = random(150, 255);
      setColor();
    }
    void update() {
      if (yDirection == 1) {
        this.point.y = (this.point.y + 1.5) % image.height;
      } else {
        this.point.y = (this.point.y - 1.5);
        if (this.point.y < 0) this.point.y = image.height;
      }
      this.point.x += xDirection * xStep;
      remove =  this.point.x < 0 || this.point.x >= image.width;
    }
    void getSiblings() {
      float sib1 = 500;
      float sib2 = 500;
      for (int i = 0; i < points.length; i++) {
        Point p = points[i];
        if (p == this) continue;
        float d = this.distanceTo(p);
        if (d <= sib1) {
          siblings[0] = p;
          sib1 = d;
          continue;
        } else if (d <= sib2) {
          siblings[1] = p;
          sib2 = d;
        }
      }
    }
    private void setColor() {
      this.c = color(random(150, 255), 0, random(100, 255));
    }
    private float distanceTo(Point a) {
      float x = a.point.x - point.x;
      float y = a.point.y - point.y;
      return sqrt(x * x + y * y);
    }
  }
}