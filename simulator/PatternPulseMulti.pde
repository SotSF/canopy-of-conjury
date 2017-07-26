class PatternPulseMulti extends Pattern {
  ArrayList<Integer> rows;
  color c;
  int max;
  
  public PatternPulseMulti(int rows, color c) {
    this.rows = new ArrayList<Integer>(); 
    this.c = c;
    this.max = rows;
  }
  
  public void runDefault(Strip[] strips) {
    clearStrips();
    boolean add = random(100) > 80;
    if (add && rows.size() < max) {
      rows.add(0);
    }
    for (int r : rows) {
      for (int i = 0; i < strips.length; i++) {
        strips[i].leds[r] = this.c;
      }
       getNextColor();
    }
    for (int r = 0; r < rows.size(); r++) {
      rows.set(r, rows.get(r) + 1);
      if (rows.get(r) >= strips[0].leds.length) { rows.set(r,0); }
    }  
  }
  
  public void visualize(Strip[] strips) {
    runDefault(strips);
  }
  
  private void getNextColor() {
    int d = (int)random(10) >= 5 ? 1 : -1;
    int r = (int)random(3);
    int red = (this.c >> 16) & 0xFF;
    int green = (this.c >> 8) & 0xFF;
    int blue = this.c & 0xFF;  
    
    switch (r) {
      case 0: //red
        red += 20 * d;
        break;
      case 1:
        green += 20 * d;
        break;
      case 2:
        blue += 20 * d;
        break;
    }
    this.c = color(red,green,blue);
  }
 
}