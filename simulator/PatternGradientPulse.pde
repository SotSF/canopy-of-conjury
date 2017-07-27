/**
* Emits pulse rings from center - each ring is a different color,
* following a gradient color scheme.
**/

class PatternGradientPulse extends Pattern {
  ArrayList<Beat> beatList;
  float lastAvg = 0;
  int offSet = 10;
  int currHue = 0;
  
  public PatternGradientPulse() {
    this.beatList = new ArrayList<Beat>();
  }
  
  public void runDefault(Strip[] strips) {
    clearStrips();
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
    for (int i = 0; i < beatList.size(); i++) {
      for (int j = 0; j < NUM_STRIPS; j++) {

          Strip s = strips[j];
          s.leds[beatList.get(i).pos] = beatList.get(i).c;
        
      }
      // increment the position of each beat for the next go-around
      int l = beatList.get(i).pos + 1;
      beatList.get(i).pos = l;
    }
    
    // if any updated positions are too big, remove the beat from the list
    for (int l = beatList.size() - 1; l >= 0 ; l--) {
      if (beatList.get(l).pos >= NUM_LEDS_PER_STRIP) {
        beatList.remove(l);
      }
    }
    
    // switch back to RGB color (in case this interferes with anything after visualize()
    colorMode(RGB,255);
  }
  
  public void visualize(Strip[] strips) {
    clearStrips();
    fftForward();
    // switch to HSB colors for this method
    colorMode(HSB, 100);
    boolean added = false;
    
    float highAmp = 0;
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave 
      if (added) { break; } // already added something this run, move on
      int lowFreq;
      if ( i == 0 ) { lowFreq = 0; } 
      else {  lowFreq = (int)((sampleRate/2) / (float)Math.pow(2, 12 - i));  }
      int hiFreq = (int)((sampleRate/2) / (float)Math.pow(2, 11 - i));
  
      // we're asking for the index of lowFreq & hiFreq
      int lowBound = fft.freqToIndex(lowFreq); // freqToIndex returns the index of the frequency band that contains the requested frequency
      int hiBound = fft.freqToIndex(hiFreq); 
  
      // calculate the average amplitude of the frequency band
      float amplitude = fft.calcAvg(lowBound, hiBound);
      
      // keep track of high amplitudes in bands 5 (bass freqs) and 11 (treble freqs)
      // but we could be paying attention to any range of frequencies
      if (i == 5 && amplitude > 30 || i == 11 && amplitude > 30) {
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
    for (int i = 0; i < beatList.size(); i++) {
      for (int j = 0; j < NUM_STRIPS; j++) {

          Strip s = strips[j];
          s.leds[beatList.get(i).pos] = beatList.get(i).c;
        
      }
      // increment the position of each beat for the next go-around
      int l = beatList.get(i).pos + 1;
      beatList.get(i).pos = l;
    }
    
    // if any updated positions are too big, remove the beat from the list
    for (int l = beatList.size() - 1; l >= 0 ; l--) {
      if (beatList.get(l).pos >= NUM_LEDS_PER_STRIP) {
        beatList.remove(l);
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