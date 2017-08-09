/*
* GOAL: have a Will-o-Wisp move from (x,y) to (x2,y2)
* Currently moves a single Will-o-Wisp in an arc
*/
class PatternWillOWisp extends Pattern {
  color base = #4DFFEF; // it's blue
  ArrayList<Wisp> wisps = new ArrayList<Wisp>();
  void run() {
    for (int i = wisps.size() - 1; i >= 0; i--) {
      wisps.get(i).run();
      if (wisps.get(i).removeMe) {
        wisps.remove(i);
      }
    }
  }
  
  void addWisp(float x, float y, float x1, float y1) {
    this.wisps.add(new Wisp(x,y,x1,y1));
  }
  
  private class Wisp {
    int scale = 3;
    int numParticles = 50;
    ArrayList<Particle> particles;
    float x;
    float y;
    float targetx;
    float targety;
    boolean pathComplete = true;
    int fade = 0;
    boolean removeMe = false;
    float speed = 1;
    
    Wisp(float x0, float y0, float x1, float y1) {
       this.particles = new ArrayList<Particle>();
       this.x = x0;
       this.y = y0;
       this.targetx = x1;
       this.targety = y1;
    }
    
    void run() {
      if (pathComplete) fade += 10;
      if (fade >= 255) removeMe = true;
      noStroke();
      int red = (base >> 16) & 0xFF;
      int green = (base >> 8) & 0xFF;
      int blue = base & 0xFF;  
      // draw the sphere
      for (int i = 0; i < 10; i++) {
        int r = 255 - (255 - red) * (i + 1)/10;
        int g = 255 - (255 - green) * (i + 1)/10;
        int b = 255 - (255 - blue) * (i + 1)/10;
        fill(color(r,g,b,255-fade));
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
    }
    
    void updatePosition() {
      if (targetx > x)  { 
        x += speed;
        if (x >= targetx) x = targetx;
      }
      else if (targetx < x) { 
        x -= speed;
        if (x <= targetx) x = targetx;
      }
      if (targety > y) {
        y += speed;
        if (y >= targety) y = targety;
      }
      else if (targety < y) { 
        y -= speed;
        if (y <= targety) y = targety;
      }
      speed += 0.4;
    }
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