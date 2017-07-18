/**
* An audio visualizer. Requires a filename pointing to an audio file.
* Can be extended, with visualize(Strip[] strips) overridden in the 
* subclasses. When the audio stops playing, any baseline pattern will
* continue to run.
**/

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
    if (beat.isOnset()) {
      this.lightTracks.add(0);
    }
        
    for (int i = 0; i < lightTracks.size(); i++) {
      for (Strip s : strips) {
        s.leds[lightTracks.get(i)] = color(currHue, 100, 100);
        if (lightTracks.get(i) + 1 < NUM_LEDS_PER_STRIP) {
          s.leds[lightTracks.get(i) + 1] = color(currHue, 100, 100);
        }
        currHue += 2;
        if (currHue >= 100) currHue = 0;
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

class PatternAVIntersection extends PatternAV {
  public PatternAVIntersection(String filename) {
    super(filename);
  }
  
  public void visualize(Strip[] strips) {
    time = millis();
    milliDiff = time - mydelay;
    fft.forward(player.mix);

    colorMode(HSB, 100);
    int bsize = player.bufferSize();
    for (int i = 0; i < NUM_STRIPS; i++) {
      strips[i].clear();
      int lights = int(random(45,60));
      int b = 0;
       lights += abs(player.left.get(b));
       if (beat.isOnset()) lights += random(100) > 50 ? -10 : -7;
       b += bsize / NUM_STRIPS;
       for (int l = 0; l < lights; l++) {
         strips[i].leds[l] = getColor(i, l);
         int outerColor = i + NUM_STRIPS / 2 > NUM_STRIPS ? i + NUM_STRIPS / 2 - NUM_STRIPS : i + NUM_STRIPS / 2; 
         strips[i].leds[NUM_LEDS_PER_STRIP - l - 1] = getColor(outerColor, l);
       }
    }
    for(int i = 0; i<256 ; i++)
    {
     fft.getBand(i);
    }
    mydelay=time;
    int bpm = 6000 / milliDiff; // this should actually be 60000?
    if (bpm > 160) { direction = -1 * direction; }
    else if (beat.isOnset()) { direction = -1 * direction; }
    colorShifter += bpm / NUM_STRIPS * direction;
    if (colorShifter >= 100) { colorShifter = 0; }
    if (colorShifter < 0) { colorShifter = 100; }
    colorMode(RGB,255);
  }
}

class PatternAV implements Pattern {

  public int colorShifter = 0;
  public int direction = 1;
  
  public int mydelay = 0;
  public int milliDiff = 0;
  public int time = 0;

  public PatternAV(String filename) {
    player = minim.loadFile(filename);
    beat = new BeatDetect();
    fft = new FFT(player.bufferSize(), player.sampleRate());
    player.play();
  }
  
  public void run(Strip[] strips) {
    visualize(strips);
    beat.detect(player.mix);
  }
  
  public void visualize(Strip[] strips) {
    time = millis();
    milliDiff = time - mydelay;
    fft.forward(player.mix);

    colorMode(HSB, 100);
    int bsize = player.bufferSize();
    for (int i = 0; i < NUM_STRIPS; i++) {
      strips[i].clear();
      //int lights = int(random(40,50));
      int lights = int(random(20,30));
      int b = 0;
       lights += abs(player.left.get(b));
       if (beat.isOnset()) lights += random(100) > 50 ? -10 : -7;
       b += bsize / NUM_STRIPS;
       for (int l = 0; l < lights; l++) {
         strips[i].leds[l] = getColor(i, l);
         int outerColor = i + NUM_STRIPS / 2 > NUM_STRIPS ? i + NUM_STRIPS / 2 - NUM_STRIPS : i + NUM_STRIPS / 2; 
         strips[i].leds[NUM_LEDS_PER_STRIP - l - 1] = getColor(outerColor, l);
       }
    }
    for(int i = 0; i<256 ; i++)
    {
     fft.getBand(i);
    }
    mydelay=time;
    int bpm = 6000 / milliDiff; // this should actually be 60000?
    if (bpm > 160) { direction = -1 * direction; }
    else if (beat.isOnset()) { direction = -1 * direction; }
    colorShifter += bpm / NUM_STRIPS * direction;
    if (colorShifter >= 100) { colorShifter = 0; }
    if (colorShifter < 0) { colorShifter = 100; }
    colorMode(RGB,255);
  }
  
  public color getColor(int s, int l) {
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