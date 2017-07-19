class PatternChevrons extends CartesianPattern implements Pattern {
  boolean shiftOnX = false; 
  int colorOffset = 0;
  ArrayList<Position> peakList = new ArrayList<Position>();
  
  public void run(Strip[] strips) {
    colorMode(HSB,100);
    
    for (int y = 0; y < dimension; y++) {
      for (int x = 0; x < dimension; x++) {
        //int hue = x + colorOffset;
        //if (hue > 100) hue += -100;
        set(x,y,color(0, 0, 0));
      }
    }
    
    Position p = new Position(10,10);
    chevron(p, 1, 60);
    scrapeWindow(strips);
    colorMode(RGB,255);
    colorShift(10);
  }
  
  private void chevron(Position peak, int coefficient, int intercept) {
    for (int y = 0; y < dimension; y++) {
      for (int x = 0; x < dimension; x++) {
        if (y == (coefficient * x) + intercept) {
          set(x,y,color(255));
          set(x+1,y,color(255));
          set(x-1,y,color(255));
          set(x,y+1,color(255));
          set(x,y-1,color(255));
          set(x+1,y+1,color(255));
          set(x-1,y-1,color(255));
        }
      }
    }
    
  }
  
  private void switchShift() {
    shiftOnX = !shiftOnX;
  }
  
  private void colorShift(int offset) {
    colorOffset += offset;
    if (colorOffset > 100) colorOffset = 0;
  }
  
  private class Position {
    int x = 0;
    int y = 0;
    public Position(int x, int y) { this.x = x; this.y = y; }
  }
}