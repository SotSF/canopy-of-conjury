class PatternSunflower extends Pattern {
  int minHue = 10;
  int maxHue = 50;
  int direction = 1;
  int activeRowsFromBase = 20;
  int maxSpike = 20;
  int alphaBase = 0;
  int alphaFlower = 0;
  int alphaFlowerDirection = -1;
  int stripShift = 0;
  public void runDefault(Strip[] strips) {
    colorMode(HSB, 360);
    int spikePos = 0;
    for (int s = 0; s < NUM_STRIPS; s++) {
      int strip = s + stripShift;
      if (strip >= NUM_STRIPS) strip -= NUM_STRIPS;
      for (int l = NUM_LEDS_PER_STRIP - 1; l >= NUM_LEDS_PER_STRIP - activeRowsFromBase; l--) {
        int scale = NUM_LEDS_PER_STRIP - l - 1;
        strips[strip].leds[l] = color(maxHue - scale / 2, 360, alphaBase);
      }
      for (int l = NUM_LEDS_PER_STRIP - activeRowsFromBase - 1; l >= NUM_LEDS_PER_STRIP - activeRowsFromBase - 1 - spikePos; l--) {
        int scale = NUM_LEDS_PER_STRIP - l - 1;
        strips[strip].leds[l] = color(maxHue - scale / 2, 360, alphaBase);
      }
      for (int l = NUM_LEDS_PER_STRIP - activeRowsFromBase - spikePos - 2; l >= 0; l--) {
        int scale = NUM_LEDS_PER_STRIP - l - 1;
        strips[strip].leds[l] = color(minHue + scale / 2, 360, alphaFlower);
      }
      spikePos += 4 * direction;
      if (spikePos > maxSpike) direction = -1;
      else if (spikePos < 4) direction = 1;
    }
    colorMode(RGB, 255);
    if (alphaBase > 300) {
      alphaFlower += 5 * alphaFlowerDirection;
      if (alphaFlower > 360) alphaFlowerDirection = -1;
      else if (alphaFlower < 0) alphaFlowerDirection = 1;
    }
    if (alphaBase < 360) alphaBase += 10;

    stripShift++;
    if (stripShift >= NUM_STRIPS) stripShift = 0;
  }
}

class PatternBlossom extends Pattern {
  BeatListener bl;
  int minHue = 280;
  int maxHue = 310;
  int stripShift = 0;
  int shiftDirection = 1;
  int beatPetal = 0;
  int brightness = 0;
  int bDirection = 1;
  Petal[] petals;
  PatternBlossom() {
    petals = new Petal[8];
    for (int i = 0; i < petals.length; i++) {
      petals[i] = new Petal(NUM_STRIPS / 8 * i);
    }
    
  }
  void runDefault(Strip[] strips) {
    colorMode(HSB, 360);
    for (int i = 0; i < petals.length; i++) {
      for (int l = 0; l < petals[i].petalLength; l++) {
        int scale = NUM_LEDS_PER_STRIP - l - 1;
        color c = color(minHue + scale / 2, l * petals[i].petalLength / 10, brightness);
        int s = petals[i].stripStart + stripShift;
        if (s >= NUM_STRIPS) s -= NUM_STRIPS;
        strips[s].leds[l] = c;
        for (int j = 0; j <= petals[i].step; j++) {
          int stripPrev = s - (j + 1);
          int stripNext = s + (j + 1);
          color c1 = color(minHue + scale / 2, l * (petals[i].petalLength + (petals[i].step * (j + 1))) / 10, brightness);
          if (stripPrev < 0) stripPrev = NUM_STRIPS + stripPrev;
          if (stripNext >= NUM_STRIPS) stripNext -= NUM_STRIPS;
          if (l < petals[i].petalLength - (petals[i].step * (j + 1))) {
            strips[stripPrev].leds[l] =  c1;
            strips[stripNext].leds[l] =  c1;
          }
        }
      }
    }
    
    brightness += bDirection * 5;
    if (brightness > 360) bDirection = -1;
    else if (brightness < 0) bDirection = 1;
    colorMode(RGB, 255);
    stripShift++;
    if (stripShift >= NUM_STRIPS) stripShift = 0;
  }
  
  synchronized void visualize(Strip[] strips) {
    if (beat == null) { 
      beat = new BeatDetect();
      beat.setSensitivity(120);
      bl = new BeatListener(beat);
    }
    int targetBrightness = petals[beatPetal].petalBrightness;
    fftForward();
    
    float highAmp = 0;
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave 
      float amplitude = getAmplitudeForBand(i);
      if (i == 5 && amplitude > 30 || i == 11 && amplitude > 30) {
        targetBrightness = round(amplitude * 10);
      } else if (amplitude >= highAmp) {
        highAmp = amplitude;
        targetBrightness = round(highAmp * 10);
      }
      
    }
    if (beat.isOnset()) { shiftDirection = shiftDirection * -1; }
    petals[beatPetal].petalBrightness = targetBrightness;
    colorMode(HSB, 360);
    for (int i = 0; i < petals.length; i++) {
      for (int l = 0; l < petals[i].petalLength; l++) {
        int scale = NUM_LEDS_PER_STRIP - l - 1;
        color c = color(minHue + scale / 2, l * petals[i].petalLength / 10, petals[i].petalBrightness);
        int s = petals[i].stripStart + stripShift;
        if (s >= NUM_STRIPS) s -= NUM_STRIPS;
        strips[s].leds[l] = c;
        for (int j = 0; j <= petals[i].step; j++) {
          int stripPrev = s - (j + 1);
          int stripNext = s + (j + 1);
          color c1 = color(minHue + scale / 2, l * (petals[i].petalLength + (petals[i].step * (j + 1))) / 10, petals[i].petalBrightness);
          if (stripPrev < 0) stripPrev = NUM_STRIPS + stripPrev;
          if (stripNext >= NUM_STRIPS) stripNext -= NUM_STRIPS;
          if (l < petals[i].petalLength - (petals[i].step * (j + 1))) {
            strips[stripPrev].leds[l] =  c1;
            strips[stripNext].leds[l] =  c1;
          }
        }
      }
      petals[i].petalBrightness -= 30;
    }
    int leafDir = 1;
    int leafSize = 4;
    int leafStep = 2;
    for (int s = 0; s < NUM_STRIPS; s++) {
      int str = s + stripShift;
      if (str >= NUM_STRIPS) str -= NUM_STRIPS;
      for (int l = NUM_LEDS_PER_STRIP - 1; l >= NUM_LEDS_PER_STRIP - leafSize; l--) {
        strips[str].leds[l] = color(122, 360, 360);
      }
      leafSize += leafDir * leafStep;
      if (leafSize > 14) leafDir = -1;
      else if (leafSize < 4) leafDir = 1;
    }
    beatPetal -= shiftDirection;
    if (beatPetal < 0) beatPetal = petals.length - 1;
    else if (beatPetal >= petals.length) beatPetal = 0;
    stripShift += shiftDirection;
    if (stripShift >= NUM_STRIPS) stripShift = 0;
    else if (stripShift < 0) stripShift = NUM_STRIPS - 1;
     colorMode(RGB, 255);
  }
  
  class Petal {
    int stripStart;
    int petalLength = 50;
    int petalMin = 32;
    int petalBrightness = 180;
    int step = (petalLength - petalMin) / 4;
    Petal(int strip) {
      this.stripStart = strip;
    }
  }
}