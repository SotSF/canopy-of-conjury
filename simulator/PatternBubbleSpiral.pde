class PatternBubbleSpiral extends CartesianPattern {
  ArrayList<Circle> points = new ArrayList<Circle>();
  int rotation = 1;
  float baseHue = random(360);
  void runDefault(Strip[] strips) {
    points.add(new Circle());
    image.beginDraw();
    image.background(0);
    image.translate(image.width / 2, image.height / 2);
    image.noStroke();
    for (int i = points.size() - 1; i >= 0; i--) {
      Circle cir = points.get(i);
      image.fill(cir.c);
      image.ellipse(cir.pos.x, cir.pos.y, cir.diameter, cir.diameter);
      cir.update();
      if (cir.remove) points.remove(cir);
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    baseHue = (baseHue + random(1)) % 360;
  }

  class Circle {
    PVector pos;
    float diameter;
    float radius;
    float theta;
    float alpha;
    color c;
    boolean remove = false;
    Circle() {
      pos = new PVector(0, 0);
      diameter = random(40, 60);
      alpha = random(200, 240);
      radius = 0;
      theta = random(100) > 50 ? random(PI / 4, 3 * PI / 4) : random(-3 * PI / 4, -PI/4);
      colorMode(HSB, 360);
      c = getColor();
      colorMode(RGB, 255);
    }

    private color getColor() {
      float h = baseHue + (random(-20, 20)) % 360;
      if (h < 0) h = 360 - h;
      return color(h, 360, 360, alpha);
    }

    void update() {
      radius += 2;
      this.pos.x = radius * cos(theta);
      this.pos.y = radius * sin(theta);
      this.theta += radians(5 * rotation);
      this.diameter -= 0.2;
      if (radius > 300 || diameter < 0) remove = true;
      if (random(100) > 99.99) {
        rotation *= -1;
      }
    }
  }
}
