/* Given x,y coords, create a firework on the Canopy */

class PatternBurst extends CartesianPattern {
  ArrayList<Burst> targets;
  PImage[] frames;
  public PatternBurst(PApplet window) {
    this.targets = new ArrayList<Burst>();
    this.frames = Gif.getPImages(window, "./images/firework.gif");
    for (PImage img : this.frames) {
      img.resize(dimension/5, dimension/5);
    }
    println(frames.length);
  }
  
  public void addBurst(int x, int y) {
    this.targets.add(new Burst(x,y));
  }
  
  public void runDefault(Strip[] strips) {
    clearWindow();
    for (Burst b : this.targets) {
      PImage thisFrame = frames[b.stage];
      b.stage++;
      plopBurst(b.x, b.y, thisFrame);
    }
    scrapeWindow(strips);
    for (int i = targets.size() - 1; i >= 0; i--) {
      if (targets.get(i).stage == frames.length) {
        targets.remove(i);
      }
    }
  }
  
  private void plopBurst(int x, int y, PImage img) {
    for (int i = 0; i < img.height; i++) {
      for (int j = 0; j < img.width; j++) {
        set(x + j, y + i, img.get(j, i));
      }
    }
  }
  
  private class Burst {
    int x;
    int y;
    int stage = 0;
    public Burst(int x, int y) {
      this.x = x;
      this.y = y;
    }

  }
}