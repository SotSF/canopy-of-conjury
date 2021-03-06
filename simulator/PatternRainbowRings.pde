/*
* Emits rings from the center - each ring is it's own rainbow
*/

class PatternRainbowRings extends Pattern {
  ArrayList<Integer> lightTracks;
  int currHue = 0;
  int delay = 14;
  int delayCount = 0;
  public PatternRainbowRings() {
    this.lightTracks = new ArrayList<Integer>();
  }
  
  public void runDefault(Strip[] strips) {
    // switch to HSB colors for this method
    boolean added = false;
    colorMode(HSB, 360, 100, 100);
    
    if (conjurer.mode == MODE_MANUAL) {
     if (delayCount == 0) {
        lightTracks.add(0);
        added = true;
      }
      if (!added && random(100) > 70) {
        lightTracks.add(0);
      }
    }
        
    for (int i = lightTracks.size() - 1; i >= 0; i--) {
      for (Strip s : strips) {
        s.leds[lightTracks.get(i)] = color(currHue, 100, 100);
        if (lightTracks.get(i) + 1 < NUM_LEDS_PER_STRIP) {
          s.leds[lightTracks.get(i) + 1] = color(currHue, 100, 100);
        }
        currHue = (currHue + 2) % 100;
      }
      int l = lightTracks.get(i) + 2;
      lightTracks.set(i, l);
      if (lightTracks.get(i) >= NUM_LEDS_PER_STRIP) {
        lightTracks.remove(i);
      }
    }
    
    colorMode(RGB, 255);
    delayCount++;
    if (delayCount >= delay) delayCount = 0;
  }
  
  synchronized void visualize(Strip[] strips) {
    // switch to HSB colors for this method
    colorMode(HSB, 360, 100, 100);
    boolean added = false;
    
    float highAmp = 0;
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave 
      if (added) { break; } // already added something this run, move on
      float amplitude = sound.getAmplitudeForBand(i);
      if (i == 5 && amplitude > 30 || i == 11 && amplitude > 30) {
         lightTracks.add(0);
         added = true;
      } else if (amplitude >= highAmp) {
        highAmp = amplitude;
      }
    }
    
    if (!added && highAmp > 10 && lightTracks.size() < 10) {
      lightTracks.add(0);
    }
        
    for (int i = 0; i < lightTracks.size(); i++) {
      for (Strip s : strips) {
        s.leds[lightTracks.get(i)] = color(currHue, 100, 100);
        if (lightTracks.get(i) + 1 < NUM_LEDS_PER_STRIP) {
          s.leds[lightTracks.get(i) + 1] = color(currHue, 100, 100);
        }
        currHue = (currHue + 2) % 100;
      }
      int l = lightTracks.get(i) + 2;
      lightTracks.set(i, l);
    }
    
    for (int l = lightTracks.size() - 1; l >= 0 ; l--) {
      if (lightTracks.get(l) >= NUM_LEDS_PER_STRIP) {
        lightTracks.remove(l);
      }
    }
    
    colorMode(RGB, 255);
  }
  
  public void addRing() {
    lightTracks.add(0);
    lightTracks.add(1);
  }
}