class PatternTentacles extends CartesianPattern { //<>// //<>// //<>// //<>// //<>//
  int numCreatures = 5;
  Creature[] creatures = new Creature[numCreatures];
  PatternTentacles() {
    for (int i = 0; i < creatures.length; i++) {
      int numArms = int(random(7, 12));
      int numArmSegments = int(random(8, 20));
      int segmentLength = int(random(15, 40)); 
      creatures[i] = new Creature(random(image.width - 50), random(image.height - 50), 
        numArms, numArmSegments, segmentLength);
    }
  }

  void runDefault(Strip[] strips) {
    image.beginDraw();
    image.background(0);
    for (int i = 0; i < creatures.length; i++) {
      renderCreature(creatures[i]);
      creatures[i].update();
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
  }

  void renderCreature(Creature c) {
    image.pushMatrix();
    image.translate(c.center.x, c.center.y);
    for (int i = 0; i < c.arms.length; i++) {
      Arm a = c.arms[i];
      float hue = c.baseHue;
      image.rotate(2 * PI / c.numArms * i);
      for (int j = 1; j < a.segments.length; j++) {
        PVector point = a.segments[j];
        image.stroke(0);
        colorMode(HSB, 360);
        float segmentBrightness = 360 - abs(a.lightSegment - j) * 30;
        image.stroke(color(j * 5 + hue, 360, 360, 
          c.brightnessFadeIn < segmentBrightness ? c.brightnessFadeIn : segmentBrightness));
        colorMode(RGB, 255);
        image.strokeWeight(2 * a.segments.length - (j * 1.5));
        image.line(a.segments[j-1].x, a.segments[j-1].y, point.x, point.y);
      }
      a.update();
    }
    image.popMatrix();
  }

  class Creature {
    int numArms;
    int numArmSegments;
    int segmentLength;
    PVector center;
    float baseHue;
    int xDirection;
    int yDirection;
    float brightnessFadeIn = 0;
    Arm[] arms;
    Creature(float x, float y, int n, int s, int l) {
      center = new PVector(x, y);
      numArms = n;
      numArmSegments = s;
      segmentLength = l;
      xDirection = random(2) > 1 ? 1 : -1;
      yDirection = random(2) > 1 ? 1 : -1;
      arms = new Arm[numArms];
      baseHue = random(360);
      for (int i = 0; i < arms.length; i++) {
        rotate(2 * PI / numArms * i);
        arms[i] = new Arm(numArmSegments, segmentLength);
      }
    }

    void update() {
      center.x += xDirection;
      center.y += yDirection;
      if (center.x > image.width - 50) xDirection *= -1;
      if (center.y > image.height - 50) yDirection *= -1;
      if (brightnessFadeIn < 360) brightnessFadeIn += 10;
    }
  }

  class Arm {
    PVector[] segments;
    int segmentLength;
    int thetaDirection;
    int changeDirection;
    int lightSegment;
    int timer = 0;
    Arm(int numSegments, int segmentLength) {
      segments = new PVector[numSegments];
      this.segmentLength = segmentLength;
      thetaDirection = random(100) > 50 ? -1 : 1;
      lightSegment = int(random(segments.length));
      generateSegments();
      changeDirection = int(random(400, 600));
    }

    private void generateSegments() {
      segments[0] = new PVector(0, 0);
      float theta = random(PI / 3, 2 * PI / 3);
      for (int i = 1; i < segments.length; i++) {
        float x = segmentLength * cos(theta);
        float y = segmentLength * sin(theta);
        segments[i] = new PVector(x + segments[i-1].x, y + segments[i-1].y);
      }
    }

    public void update() {
      float rMod = random(-1, 1);
      for (int i = 1; i < segments.length; i ++) {
        PVector s = segments[i];
        float r = sqrt(s.x * s.x + s.y * s.y);
        float theta = atan2(s.y, s.x);
        theta += radians(i * 0.1) * thetaDirection; 
        r += 0.05 * i * rMod;
        if (theta < 0 || theta > PI * 0.99) {
          thetaDirection *= -1;
        }
        s.x = r * cos(theta);
        s.y = r * sin(theta);
        lightSegment = (lightSegment + 1) % segments.length;
      }
    }
  }
}
