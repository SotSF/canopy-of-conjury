/*
* GOAL: have a Will-o-Wisp move from (x,y) to (x2,y2)
* Currently moves a single Will-o-Wisp in an arc
*/
class PatternWillOWisp extends Pattern {
  int scale = 3;
  int direction = 1;
  int numParticles = 50;
  ArrayList<Particle> particles;
  float x;
  float y;
  float targetx;
  float targety;
  color base = #4DFFEF;
  int ydirection = -1;
  int xdirection = 1;
  int timer = 999;
  PatternWillOWisp() {
    this.particles = new ArrayList<Particle>();
  }
  
  void run() {
    if (timer >= 100) { clear(); return; }
    noStroke();
    int red = (base >> 16) & 0xFF;
    int green = (base >> 8) & 0xFF;
    int blue = base & 0xFF;  
    // draw the sphere
    for (int i = 0; i < 10; i++) {
      int r = 255 - (255 - red) * (i + 1)/10;
      int g = 255 - (255 - green) * (i + 1)/10;
      int b = 255 - (255 - blue) * (i + 1)/10;
      fill(color(r,g,b));
      ellipse(x,y,70 - scale * i,70 - scale * i);
    }
    pushMatrix();
    translate(x,y); // center off the orb
    if (particles.size() < numParticles) {
      Particle p = new Particle();
      particles.add(p);
    }
    for (Particle p : particles) {
      fill(p.c);
      ellipse(p.x, p.y, p.size, p.size);
      p.update();
    }
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p.fade >= 25) particles.remove(p);
    }
    popMatrix();
    updatePosition();
    timer++;
  }
  
  
  void updatePosition() {
    pushMatrix();
    translate(width/2, height/2);
    fill(color(255,0,0));
    // translate the center coordinates
    float x1 = x - width / 2;
    float y1 = y - height / 2;
    // get the coords in Polar
    float r = sqrt(x1 * x1 + y1 * y1);
    float theta = atan2(y1,x1);
    // increment angle
    theta += radians(1);
    // get new cartesian coordinates
    this.x = r * cos(theta) + width / 2;
    this.y = r * sin(theta) + height / 2;
    xdirection = x - (x1 + width / 2) > 0 ? 1 : -1;
    popMatrix();
  }
  
  void reset() {
    x = random(dimension);
    y = random(dimension);
    timer = 0;
  }
  
  private class Particle {
    float x;
    float y;
    float size;
    color c;
    int fade;
    
    int red = (base >> 16) & 0xFF;
    int green = (base >> 8) & 0xFF;
    int blue = base & 0xFF; 
    Particle() {
      float rad = random(25,40);
      float thetaDegrees = random(360);
      int rand = int(random(10));
      int r = 255 - (255 - red) * rand/10;
      int g = 255 - (255 - green) * rand/10;
      int b = 255 - (255 - blue) * rand/10;
      this.c = color(r,g,b);
      this.x = rad * cos(radians(thetaDegrees));
      this.y = rad * sin(radians(thetaDegrees)) + 20;
      this.size = random(20,40);
      this.fade = 0;
    }
    void update() {
      fade++;
      float jitter = random(100) / 100;
      this.x += this.x > 0 ? -1 * jitter : 1 * jitter;
      this.y -= 5;
      this.size--;
      this.c = color(red(this.c), green(this.c), blue(this.c),  255 - (255 * fade / 25));
    }
  }
}