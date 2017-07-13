class PatternPulseMulti implements Pattern {
  int[] rows;
  color c;
  
  public PatternPulseMulti(int rows, color c) {
    this.rows = new int[rows];
    this.c = c;
    for (int r = 0; r < this.rows.length; r++) {
      this.rows[r] = int(random(numLedsPerStrip));
    }
  }
  
  public void run(Strip[] strips) {
    for (int i = 0; i < strips.length; i++) {
      strips[i].clear();
      for (int r = 0; r < rows.length; r++) {
        strips[i].leds[rows[r]] = this.c;
      }
    }
    
    for (int r = 0; r < rows.length; r++) {
      rows[r] += 1;
      if (rows[r] >= strips[0].leds.length) { rows[r] = 0; }
    }
     getNextColor();
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