/**
* Up to 100 fireflies floating through a black sky.
*/
class PatternFireFlies extends CartesianPattern {
  int numFlies = 100;
  int flySize = 10;
  int fireflyHue = 50;
  int lifespan = 1000;
  ArrayList<Firefly> fireflies = new ArrayList<Firefly>();
  PatternFireFlies() {
    image.noStroke();
  }
  void runDefault(Strip[] strips) {
    image.beginDraw();
    image.background(0);
    if (fireflies.size() < numFlies) {
      if (random(100) > 80) fireflies.add(new Firefly(random(dimension),random(dimension)));
    }
    
    for (int i = fireflies.size() - 1; i >= 0; i--) {
      Firefly f = fireflies.get(i);
      renderFirefly(f);
      f.update();
      if (f.life >= lifespan) fireflies.remove(f);
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
  }
  
  void renderFirefly(Firefly f) {
    colorMode(HSB,360);
    image.pushMatrix();
    image.translate(f.x, f.y);
    for (int i = flySize; i >=0; i--) {
      image.noStroke();
      image.fill(color(fireflyHue,
                 360 - i * 30,
                 360, 
                 i * f.brightness));
      float x = f.radius * cos(f.theta);
      float y = f.radius * sin(f.theta);
      image.ellipse(x,y,i * f.size, i * f.size);
    }
    image.popMatrix();
    colorMode(RGB,255);
  }

  class Firefly {
    float brightness = 0; // max 25
    int brightdirection = 1;
    int radiusDirection;
    int thetaDirection;
    float size; // between 1 and 3 ideal
    float x;
    float y;
    float radius = 0;
    float theta = 0;
    int life = 0;
    Firefly(float x, float y) {
      this.x = x;
      this.y = y;
      this.size = random(1,2);
      this.radiusDirection = (random(100) > 50 ? 1 : -1);
      this.thetaDirection = (random(100) > 50 ? 1 : -1);
    }
  
    void update() {
     brightness += brightdirection;
     if (brightness > 25) brightdirection = -1;
     else if (brightness < 0) brightdirection = 1;
     radius += radiusDirection;
     if (radius > 20) radiusDirection = -1;
     else if (random(100) > 99) radiusDirection *= -1;
     
     theta += radians(thetaDirection); 
     if (random(100) > 99) thetaDirection *= -1;
     life++;
    }
  }
}