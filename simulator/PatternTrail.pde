class PatternTrail extends CartesianPattern {
  ArrayList<TrailPoint> path = new ArrayList<TrailPoint>();
  void runDefault(Strip[] strips) {
    clearWindow();
    if (conjurer.mode == MODE_MANUAL) {
      addTrailPoint(int(random(dimension)), int(random(dimension)));
    }
    
    for (int i = path.size() - 1; i >= 0; i--) {
       TrailPoint p = path.get(i);
       plopPoint(p);
       if (p.brightness <= 0) path.remove(i);
    }
    
    scrapeWindow(strips);
  }
  void addTrailPoint(int x, int y) {
    path.add(new TrailPoint(x,y));
  }
  
  void plopPoint(TrailPoint p) {
    for (int x = p.x; x < p.x + 10; x++) {
      for (int y = p.y; y <= p.y + 10; y++) {
        set(x,y,color(255,0,0, p.brightness));
      }
    }
    p.brightness -= 20;
  }  
  
  private class TrailPoint {
    int x;
    int y;
    int brightness = 255;
    TrailPoint(int x, int y) {
      this.x = x;
      this.y = y;
    }
  }
}