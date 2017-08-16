/**
* Emits pulse rings from center - each ring is a different color,
* following a gradient color scheme.
**/

class PatternGradientPulse extends Pattern {
  ArrayList<Beat> beatList;
  float lastAvg = 0;
  int offSet = 10;
  int currHue = 0;
  BeatListener bl;
  
  public PatternGradientPulse() {
    this.beatList = new ArrayList<Beat>();
  }
  
  public void runDefault(Strip[] strips) {
    // switch to HSB colors for this method
    colorMode(HSB, 100);
    
    int r = int(random(100));
    if (r > 50 && beatList.size() < 25) {
      color c = color(currHue, 100, r * 2);
       currHue += 1;
       if (currHue > 100) currHue = 0;
       beatList.add(new Beat(0, c));
    }
    
    // go through every position in beatList, and light up the corresponding LED in all strips
    for (int i = beatList.size() - 1; i >= 0; i--) {
      for (int j = 0; j < NUM_STRIPS; j++) {

          Strip s = strips[j];
          s.leds[beatList.get(i).pos] = beatList.get(i).c;
        
      }
      // increment the position of each beat for the next go-around
      int l = beatList.get(i).pos + 1;
      beatList.get(i).pos = l;
      
      // remove if the position is too big
      if (beatList.get(i).pos >= NUM_LEDS_PER_STRIP) {
        beatList.remove(i);
      }
    }

    // switch back to RGB color (in case this interferes with anything after visualize()
    colorMode(RGB,255);
  }
  
  synchronized public void visualize(Strip[] strips) {
    if (beat == null) { 
      beat = new BeatDetect();
      beat.setSensitivity(120);
      bl = new BeatListener(beat);
    }
    fftForward();
    // switch to HSB colors for this method
    colorMode(HSB, 100);
    boolean added = false;
    
    float highAmp = 0;
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave 
      if (added) { break; } // already added something this run, move on
      float amplitude = getAmplitudeForBand(i);
      if (i == 7 && amplitude > 30 || i == 11 && amplitude > 30) {
         color c = color(currHue, 100, amplitude);
         currHue += 1;
         if (currHue > 100) currHue = 0;
         beatList.add(new Beat(0, c));
         added = true;
        
      } else {
        if (amplitude >= highAmp) {
          highAmp = amplitude;
        }
      }
    }
    //if nothing got added, bump the recorded highest amplitude we found if highAmp > [whatever amplitude]
    if (!added) { 
      if (highAmp > 12 && beatList.size() < 25) {
        color c = color(currHue, 100, highAmp * 2);
         currHue += 1;
         if (currHue > 100) currHue = 0;
         beatList.add(new Beat(0, c));
      }
    }
    
    // go through every position in beatList, and light up the corresponding LED in all strips
    for (int i = beatList.size() - 1; i >= 0; i--) {
      for (int j = 0; j < NUM_STRIPS; j++) {

          Strip s = strips[j];
          s.leds[beatList.get(i).pos] = beatList.get(i).c;
        
      }
      // increment the position of each beat for the next go-around
      int l = beatList.get(i).pos + 1;
      beatList.get(i).pos = l;
      
      // remove if the position is too big
      if (beatList.get(i).pos >= NUM_LEDS_PER_STRIP) {
        beatList.remove(i);
      }
    }
    
    // switch back to RGB color (in case this interferes with anything after visualize()
    colorMode(RGB,255);
  }
  
  private class Beat {
    int pos;
    color c;
    public Beat(int pos, color c) {
      this.pos = pos;
      this.c = c;
      
    }
  }
}