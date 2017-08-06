/*
* Emits rings from the center - each ring is the same color,
* with a random color shift each step.
* Params:
* int rows - max number of rings
* color c - the base color
*/

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

class PatternRedRings extends Pattern {
  ArrayList<Light> lights = new ArrayList<Light>();
  int currentStrip = 0;
  int currentLed = 0;
  void runDefault(Strip[] strips) {
    if (conjurer.mode == MODE_MANUAL) {
      if (currentStrip < NUM_STRIPS && currentLed < NUM_LEDS_PER_STRIP) {
        lights.add(new Light(currentStrip, currentLed));
        currentStrip++;
        if (currentStrip >= NUM_STRIPS) {
          currentStrip = 0;
          currentLed++;
        }
      }
    }
    
    for (int i = lights.size() - 1; i >= 0; i--) {
      Light l = lights.get(i);
      strips[l.strip].leds[l.led] = color(255,0,0,l.brightness);
      l.brightness -= 5;
      if (l.brightness < 0) lights.remove(i);
    }
  }
  
  private class Light {
    int strip;
    int led;
    int brightness;
    Light(int s, int l) {
      this.strip = s;
      this.led = l;
      this.brightness = 255;
    }
  }
}