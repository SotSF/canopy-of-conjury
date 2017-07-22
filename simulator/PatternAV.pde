/**
* An audio visualizer. Requires a filename pointing to an audio file.
* Can be extended, with visualize(Strip[] strips) overridden in the 
* subclasses. When the audio stops playing, any baseline pattern will
* continue to run.
**/


/*
  More precise frequency and amplitude calculations in PatternAVTestPulse
  based on sketch here: 
  https://forum.processing.org/one/topic/minim-super-accurate-frequency-or-beat-detection-analysis-3-4-2013-1.html
*/
class PatternAVTestPulse extends PatternAV {
  ArrayList<Beat> beatList;
  float lastAvg = 0;
  int offSet = 10;
  int currHue = 0;
  
  public PatternAVTestPulse(String filename) {
    super(filename);
    this.beatList = new ArrayList<Beat>();
  }
  
  public void visualize(Strip[] strips) {
    clearStrips();
    fft.forward(player.mix);
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

class PatternAVRainbowPulsar extends PatternAV {
  ArrayList<Integer> lightTracks;
  int currHue = 0;
  
  public PatternAVRainbowPulsar(String filename) {
    super(filename);
    this.lightTracks = new ArrayList<Integer>();
  }
  
  public void visualize(Strip[] strips) {
    colorMode(HSB,100);
    clearStrips();
    fft.forward(player.mix);
    
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
         lightTracks.add(0);
         added = true;
        
      } else {
        if (amplitude >= highAmp) {
          highAmp = amplitude;
        }
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
        currHue += 2;
        if (currHue > 100) currHue = 0;
      }
      int l = lightTracks.get(i) + 2;
      lightTracks.set(i, l);
    }
    
    for (int l = lightTracks.size() - 1; l >= 0 ; l--) {
      if (lightTracks.get(l) >= NUM_LEDS_PER_STRIP) {
        lightTracks.remove(l);
      }
    }
    
    colorMode(RGB,255);
  }
}

class PatternAV implements Pattern {

  private int colorShifter = 0;
  private int direction = 1;
  
  public int mydelay = 0;
  public int milliDiff = 0;
  public int time = 0;
  
  public int sampleRate = 44100;

  public PatternAV(String filename) {
    player = minim.loadFile(filename, 1024);
    if (stopCurrentAudio) { player.play(); } // current audio is stopped, play next audio (which is this)
    //player = minim.getLineIn(Minim.STEREO, 1024, 192000.0);
    fft = new FFT(player.bufferSize(), player.sampleRate());
  }
  
  public void run(Strip[] strips) {
    visualize(strips);
  }
  
  public void visualize(Strip[] strips) {
    time = millis();
    milliDiff = time - mydelay;
    fft.forward(player.mix);

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
         strips[i].leds[l] = getColor(i, l);
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