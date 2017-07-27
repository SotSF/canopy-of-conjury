/*
* Two rings, one each at apex and base, simulating sound wave movement.
*/

class PatternSound extends Pattern {
  int colorShifter = 0;
  int direction = 1;
  
  int mydelay = 0;
  int milliDiff = 0;
  int time = 0;

  public void runDefault(Strip[] strips) {
    colorMode(HSB, 100);
    int offset = int(random(5,10));

    for (int i = 0; i < NUM_STRIPS; i++) {
      strips[i].clear();
      //int lights = int(random(40,50));
      int lights = int(random(20,30));
       lights += offset;
       for (int l = 0; l < lights; l++) {
         strips[i].leds[l] = getColor(i, l);
         int outerColor = i + NUM_STRIPS / 2 > NUM_STRIPS ? i + NUM_STRIPS / 2 - NUM_STRIPS : i + NUM_STRIPS / 2; 
         strips[i].leds[NUM_LEDS_PER_STRIP - l - 1] = getColor(outerColor, l);
       }
    }
    if (random(100) > 99) direction = direction * -1;
    colorShifter += 120 / NUM_STRIPS * direction;
    if (colorShifter >= 100) { colorShifter = 0; }
    if (colorShifter < 0) { colorShifter = 100; }
    colorMode(RGB,255);
  }
  
  public void visualize(Strip[] strips) {
    time = millis();
    milliDiff = time - mydelay;
    fftForward();
    colorMode(HSB, 100);
    int offset = 0;
    
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave
      if (offset > 0) break;
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
        offset = round(amplitude / 5);
      }
    }
    
    for (int i = 0; i < NUM_STRIPS; i++) {
      strips[i].clear();
      //int lights = int(random(40,50));
      int lights = int(random(20,30));
       lights += offset;
       for (int l = 0; l < lights; l++) {
         if (l < NUM_LEDS_PER_STRIP) strips[i].leds[l] = getColor(i, l);
         int outerColor = i + NUM_STRIPS / 2 > NUM_STRIPS ? i + NUM_STRIPS / 2 - NUM_STRIPS : i + NUM_STRIPS / 2; 
         strips[i].leds[NUM_LEDS_PER_STRIP - l - 1] = getColor(outerColor, l);
       }
    }
    mydelay=time;
    int bpm = 6000 / milliDiff; // this should actually be 60000?
    println(bpm);
    if (bpm > 160) { direction = -1 * direction; }
    else if (offset > 0) { direction = -1 * direction; }
    if (bpm < NUM_STRIPS) { bpm += bpm; }
    colorShifter += bpm / NUM_STRIPS * direction;
    if (colorShifter >= 100) { colorShifter = 0; }
    if (colorShifter < 0) { colorShifter = 100; }
    colorMode(RGB,255);
  }
  
  private color getColor(int s, int l) {
    int hue = s * 100 / NUM_STRIPS + colorShifter;
    if (hue > 100) {
      hue += -100;
    }
    if (hue < 0) {
      hue += 100;
    }
    int sat = 100 - l;
    return color(hue,sat,100);
  }
}