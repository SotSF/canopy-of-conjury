/* Given x,y coords, create a firework on the Canopy */

class PatternBurst extends CartesianPattern {
  ArrayList<Burst> targets;
  PImage[] frames;
  int overlayHue;
  public PatternBurst(PApplet window) {
    this.targets = new ArrayList<Burst>();
    this.frames = Gif.getPImages(window, "./images/firework.gif");
    for (PImage img : this.frames) {
      img.resize(dimension/3, dimension/3);
    }
    this.overlayHue = 0;
    println(frames.length);
  }
  
  public void addBurst(int x, int y) {
    this.targets.add(new Burst(x,y,overlayHue));
    overlayHue += 10;
    if (overlayHue > 100) overlayHue = 0;
  }
  
  public void runDefault(Strip[] strips) {
    clearWindow();
    for (Burst b : this.targets) {
      plopBurst(b);
    }
    scrapeWindow(strips);
    for (int i = targets.size() - 1; i >= 0; i--) {
      if (targets.get(i).stage == frames.length) {
        targets.remove(i);
      }
    }
  }
  
  private void plopBurst(Burst b) {
    PImage img = frames[b.stage];
    b.stage++;
    for (int i = 0; i < img.height; i++) {
      for (int j = 0; j < img.width; j++) {
        color c = img.get(j,i);
        if (c > color(5,5,5)) {
          colorMode(HSB,100);
          //c = int(c + color(b.hue,100,100));
          //if (hue(c) > 100) c = color(0,100,100);
          colorMode(RGB,255);
          set(b.x + j, b.y + i, c);
        }
        
      }
    }
  }
  
  private class Burst {
    int x;
    int y;
    int stage = 0;
    int hue;
    public Burst(int x, int y, int hue) {
      this.x = x;
      this.y = y;
      this.hue = hue;
    }

  }
}