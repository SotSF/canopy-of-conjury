/**
* Variants on the rainbow PatternHeartPulse.
* colorOverlay controls the color scheme used on the heart.
**/

class PatternHeartPink extends PatternHeartPulse {
  public PatternHeartPink(float grow, float shrink, float max, float min) {
    super(grow, shrink, max, min);
  }
  
  public void colorOverlay(Strip[] strips) {
    colorMode(HSB, 100);
    int minHue = 65;
    int maxHue = 85;
    int direction = 1;
    int currHue = minHue;
    int count = 0;
    int step = 10 + round(this.pulse);
    for (Strip s : strips) {
      for (int l = numLedsPerStrip - 1; l >= 0; l--) {
        // hit the first light
        if (s.leds[l] != 0) {
          while (count < step) {
            if (l - count < 0) break;
            s.leds[l - count] = color(currHue, 75, 100);
            count++;
          }
          l = l - step;
          currHue += round((maxHue - minHue) / (numLedsPerStrip / (step + 1)));
          if (currHue > maxHue) currHue = minHue;
          count = 0;
          continue;
        }
      }
    }
    colorMode(RGB,255);
  }
}