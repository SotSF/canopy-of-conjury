class PatternSwirly extends Pattern {
  Swirl[] swirls;
  color c;
  boolean warm = true;
  public PatternSwirly(color c, int swirlCount, int flow, boolean warm) {
    this.swirls = new Swirl[swirlCount];
    this.c = c;
    this.warm = warm;
    
    for (int i = 0; i < swirlCount; i++) {
      boolean flowOut = true;
      if (flow == 0) {
        flowOut = int(random(100)) >= 50;        
      } 
      if (flow == -1) flowOut = false;
      if (flow == 1) flowOut = true;
      this.swirls[i] = new Swirl(int(random(NUM_STRIPS)), int(random(NUM_LEDS_PER_STRIP)), int(random(15,30)), color(255,0,0), flowOut);
    }
  }
  
  public void runDefault(Strip[] strips) {
    clearStrips();
    int d = random(100) > 50 ? 1 : -1;
    int r = int(random(3));
    for (Swirl s : this.swirls) {
      if (s.lights.size() < s.maxLights) {
        s.lights.add(0,new Position(s.startStrip,s.startLed));
      }
      for (Position p : s.lights) {
        strips[p.strip].leds[p.led] = s.c;
         p.update(s.flowOut ? 1 : -1);
      }
      for (int i = s.lights.size() - 1; i >= 0; i--) {
        if (s.lights.get(i).kill) {
          s.lights.remove(i);
        }
      }
      s.getNextColor(d,r,int(random(5,11)), this.warm);
    }
  }

  private class Swirl {
    ArrayList<Position> lights;
    int maxLights;
    int startStrip;
    int startLed;
    color c;
    boolean flowOut = false; 
    public Swirl(int strip, int led, int maxlights, color c, boolean flowOut) {
      this.lights = new ArrayList<Position>();
      this.maxLights = maxlights;
      this.startStrip = strip;
      this.startLed = led;
      this.c = c;
      this.flowOut = flowOut;
    }
    private void getNextColor(int d, int r, int variance, boolean warm) {
      int red = (this.c >> 16) & 0xFF;
      int green = (this.c >> 8) & 0xFF;
      int blue = this.c & 0xFF;  
      
      switch (r) {
        case 0: //red
          red += (10 + variance) * d;
          break;
        case 1:
          green += (5 + variance) * d;
          break;
        case 2:
          blue += (5 + variance) * d;
          break;
      }
      // if the color gets too dim, tend towards warm or cool
      if (red < 150 && green < 150 && blue < 150) {
        if (warm) { red = 200; }
        else { blue = 200; }
      }
      this.c = color(red,green,blue);
    }
  }
  
  private class Position {
    int strip = 0;
    int led = 0;
    boolean kill = false;
    public Position(int strip, int led) {
      this.strip = strip;
      this.led = led;
    }
    
    public void update(int direction) {
      this.strip += 1 * direction;
      this.led += 1 * direction;
      if (this.strip >= NUM_STRIPS) { this.strip = 0; }
      if (this.strip < 0) { this.strip = NUM_STRIPS - 1; }
      if (this.led >= NUM_LEDS_PER_STRIP || this.led < 0) { kill = true; }
    }
  }
}