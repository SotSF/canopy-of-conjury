/**
* Maps a cardioid function in the Cartesian plane.
* Translated to Canopy coordinates.
* Params:
* float growStep - the rate at which the heart pulses larger
* float shrinkStep - the rate at which the heart pulses smaller
* float pulseMax - the largest the heart can grow
* float pulseMin - the smallest the heart can shrink
**/

class PatternHeartPulse extends CartesianPattern implements Pattern {
  int t = 0;
  boolean grow = true;
  float growStep = 0.03;
  float shrinkStep = -0.03;
  float pulseMax = 3.5;
  float pulseMin = 0.25;
  
  float pulse = pulseMin;
  color colorMask = color(255);
  
  public PatternHeartPulse(float growStep, float shrinkStep, float pulseMax, float pulseMin) {
    this.growStep = growStep;
    this.shrinkStep = shrinkStep;
    this.pulseMax = pulseMax;
    this.pulseMin = pulseMin;
  }
  
  public void run(Strip[] strips) {
    clearWindow();
    while (t < 1000) {
      // this is Cartesian
      int x = floor((1 + this.pulse) * (16 * sin(t) * sin(t) * sin(t)));
      int y = floor((1 + this.pulse) * (13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t)));
      // this is PixelWindow
      int x2 = round(x * 2 + (dimension / 2));
      int y2 = round(y * 2 + (dimension / 2));
     
       // overcompensate the lines
      drawPoint(x2,y2);
      drawPoint(x2+1, y2);
      drawPoint(x2-1, y2);
      drawPoint(x2, y2+1);
      drawPoint(x2, y2-1);
      t++;
    }
    t = 0;
    
    if (this.grow) { this.pulse += growStep; }
    else { this.pulse += shrinkStep; }
    if (this.pulse > pulseMax) {
      this.grow = false;
    }
    if (this.pulse < pulseMin) {
      this.grow = true;
    }

    this.scrapeWindow(strips); // only gets heart outline
    fillHeart(strips); // so roughly fill in the heart
    colorOverlay(strips);
  }
  
  private void drawPoint(int x, int y) {
     set(x,y,colorMask);
     set(x, y+1, colorMask);
     set(x,y-1,colorMask);
     set(x+1, y, colorMask);
     set(x-1, y, colorMask);
     set(x+1, y+1, colorMask);
     set(x-1, y+1, colorMask);
  }
  
  private void fillHeart(Strip[] strips) {
    for (int s = 0; s < NUM_STRIPS; s++) {
      for (int l = NUM_LEDS_PER_STRIP - 2; l >= 0; l--) {
        int nextStrip = s + 1 >= NUM_STRIPS ? 0 : s + 1;
        if (strips[s].leds[l + 1] == colorMask ||
          (strips[nextStrip].leds[l + 1] == colorMask)) {
          strips[s].leds[l] = colorMask;
        }
      }
    }
  }
  
  public void colorOverlay(Strip[] strips) {
    colorMode(HSB,100);
    for (Strip s : strips) {
      for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
        if (s.leds[l] == colorMask) {
          int hue = floor(l * this.dimension / NUM_LEDS_PER_STRIP / sin(this.pulse));
          s.leds[l] = color(hue,100,100);
        }
      }
    }
    colorMode(RGB, 255);
  }
  

}