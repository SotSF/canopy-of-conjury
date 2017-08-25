class PatternMandalas extends CartesianPattern {
  int numRings = 6;
  int finishedRings = 0;
  Ring[] rings = new Ring[numRings];
  boolean ringset = false;
  void runDefault(Strip[] strips) {
    image.beginDraw();
    image.noSmooth();
    image.background(0);
    if (!ringset) {
      float radius = random(10, 50);
      for (int i = 0; i < rings.length; i++) {
        float ringRadius = radius + (i > 0 ? rings[i - 1].ringWidth : 0);
        radius = ringRadius + 5 * i;
        rings[i] = new Ring(int(random(3, 7)), ringRadius); 
        println(ringRadius, rings[i].ringWidth, ringRadius + rings[i].ringWidth);
      }
      ringset = true;
    }

    //DEBUG
    image.translate(image.width /2, image.height /2);
    for (int i = 0; i < rings.length; i++) {
      Ring r = rings[i];
      image.stroke(r.c);
      image.strokeWeight(2);
      image.noFill();
      image.ellipse(0, 0, r.innerRadius * 2, r.innerRadius * 2);
      image.ellipse(0, 0, (r.innerRadius + r.ringWidth) * 2, (r.innerRadius + r.ringWidth) * 2);
      r.renderShapes();
      if (r.t == r.shapeCount) rings[i] = new Ring(int(random(3, 7)), r.innerRadius);
    }
    
    image.endDraw();
    scrapeImage(image.get(), strips);
  }

  int[] factors = {18, 20, 24, 30, 36, 40, 45, 60, 72, 90, 120};
  class Ring {
    int vertices; //2 (line), 3 (triangles, 4 (rectangles), 5 (circles)
    float innerRadius;
    float ringWidth;
    float shapeCount;
    float shapeWidth;
    float shapeMargin;
    color c;
    float velocity;
    int offset;
    int t = 0;
    float[] verts;
    Ring(int v, float rad) {
      vertices = v;
      innerRadius = rad;
      ringWidth = random(20, 50);
      shapeCount = factors[int(random(factors.length))];
      shapeMargin = random(1, 5);
      shapeWidth = (360 / shapeCount) - (2 * shapeMargin);
      //c = color(random(255),random(255),random(255));
      c =color(random(200, 255), random(50, 255), 0);
      //velocity = random(1, 5);
      velocity = 5;
      offset = int(random(360));
      verts = new float[vertices - 1];
      for (int i = 0; i < vertices - 1; i++) {
        verts[i] = random(shapeWidth * 2);
      }
    }
    void renderShapes() {
      image.pushMatrix();
      for (float i = 0; i < t; i++) {
        image.rotate(radians(shapeWidth + (2 * shapeMargin)));
        if (vertices > 2) image.noStroke();
        else { 
          image.stroke(c); 
          image.strokeWeight(2);
        }
        image.fill(c);
        image.beginShape();
        image.vertex(innerRadius + ringWidth, shapeWidth / 2);
        for (int v = 0; v < vertices - 1; v++) {
          float rad = innerRadius;
          if (v > vertices / 2) { 
            rad = innerRadius + ringWidth / vertices * (v - 1);
          }
          if (v == vertices - 1) {
            rad = innerRadius + ringWidth;
          }
          float x = rad * cos(radians(verts[v]));
          float y = rad * sin(radians(verts[v]));
          image.vertex(x, y);
        }
        image.endShape(CLOSE);
      }
      image.popMatrix();
      t += 2;
    }
  }
}