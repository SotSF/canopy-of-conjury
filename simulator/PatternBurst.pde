/* Given Point P(x,y,z) and line described by 
* vector <v1,v2,v3> originating at Point P, 
* illuminate the point of intersection on the Canopy
*/

class PatternBurst extends CartesianPattern {
  ArrayList<Burst> targets;
  PImage[] frames;
  PatternBurst(PApplet window) {
     targets = new ArrayList<Burst>();
     frames = Gif.getPImages(window, "./images/firework.gif");
     for (PImage img : this.frames) {
       img.resize(dimension/3, dimension/3);
     }
  }
  void runDefault(Strip[] strips) {
    if (conjurer.mode == MODE_MANUAL) {
      if (random(100) > 50) { 
        PVector o = new PVector(random(-200,200),-200,random(-200,200));
        PVector v = new PVector(random(-2,2),random(0,5),random(-2,2));
        addBurst(o, v);
      }
    }
    
    image.beginDraw();
    image.background(0);
    for (int i = targets.size() - 1; i >= 0; i--) {
      if (targets.get(i).center == null) { targets.remove(i); continue; }
      plopBurst(targets.get(i));
      if (targets.get(i).stage >= frames.length) targets.remove(i);
    }
    image.endDraw();
    scrapeImage(image, strips);
  }
  
  void addBurst(PVector origin, PVector vector) {
    this.targets.add(new Burst(origin, vector));
  }
  
  void plopBurst(Burst b) {
    PImage img = frames[b.stage];
    b.stage++;
    image.image(img, b.center.x - img.width/2 ,b.center.y - img.height/2);
    
  }
  
  class Burst {
    PVector origin;
    PVector vector;
    Position center;
    int stage = 0;
    public Burst(PVector o, PVector v) {
      this.origin = o;
      this.vector = v;
      for (int s = 0; s < NUM_STRIPS; s++) {
        for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
            checkIntersect(s,l);
          }
        }
      }
      // determine whether the "real" LED falls within a cylinder of radius 10 
      // following the line described by x,y,z 
      void checkIntersect(int s, int l) {
        PVector r = transformReal(s,l);
        for (int t = 0; t < 500; t++) {
          float x = origin.x + vector.x * t;
          float y = origin.y + vector.y * t;
          float z = origin.z + vector.z * t;         
          if ((x-r.x)*(x-r.x) + (y-r.y)*(y-r.y) + (z-r.z)*(z-r.z) > 100) continue; 
          float theta = radians(s * 360 / NUM_STRIPS);
          float radius = l * 3;
          center = new Position(int(radius * cos(theta)) + dimension / 2, int(radius * sin(theta)) + dimension / 2);
          return;
        }
      }
    }
}