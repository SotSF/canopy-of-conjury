class PatternDiamonds extends CartesianPattern {
  PGraphics image;
  int numShapes = 16;
  int currentShape = 0;
  
  int bassShape = 0;
  int trebleShape = numShapes - 1;
  BeatListener bl;
  Pattern gradient = new PatternGradientPulse();
  Diamond[] diamonds;
  PatternDiamonds() {
    image = createGraphics(dimension, dimension);
    image.noSmooth();
    diamonds = new Diamond[numShapes];
    for (int i = 0; i < diamonds.length; i++) {
      diamonds[i] = new Diamond();
    }
    
  }
  void runDefault(Strip[] strips) {
    colorMode(HSB, 360);
    image.beginDraw();
    image.clear();
    image.background(0);
    image.translate(dimension/2,dimension/2);
    for (int i = 0; i < diamonds.length; i++) {
      if (i == currentShape) diamonds[i].satOffset += 60;
      
      float theta = 2 * PI / numShapes;
      float radius = i % 2 == 0 ? 100 : 50;
      float dist = i % 2 == 0 ? dimension / 3 : dimension / 2;
      image.rotate(theta);
      image.fill(color(diamonds[i].hue, 360,360-diamonds[i].satOffset,360));
      image.beginShape();
      image.vertex(0,radius);
      image.vertex(20,radius + 30);
      image.vertex(0, radius + dist);
      image.vertex(-20, radius + 30);
      image.endShape();
      diamonds[i].update();
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    colorMode(RGB, 255);
    currentShape++;
    if (currentShape >= diamonds.length) currentShape = 0;
  }
  
  void visualize(Strip[] strips) {
    if (beat == null) { 
      beat = new BeatDetect();
      beat.setSensitivity(120);
      bl = new BeatListener(beat, player);
    }
    gradient.visualize(strips);
    colorMode(HSB, 360);
    fftForward();
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave
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
      if (i == 5) {
        diamonds[bassShape].hue = int(random(270,290));
        diamonds[bassShape].satOffset = round(amplitude * 10);
      }
      if (i == 11) {
       diamonds[trebleShape].hue = int(random(250,270));
        diamonds[trebleShape].satOffset = round(amplitude * 10); 
      }
    }
  
    image.beginDraw();
    image.clear();
    image.background(0);
    image.translate(dimension/2,dimension/2);
    for (int i = 0; i < diamonds.length; i++) {
      if (i == bassShape || i == trebleShape) diamonds[i].satOffset += 60;
      
      float theta = 2 * PI / numShapes;
      float radius = i % 2 == 0 ? 100 : 50;
      float dist = i % 2 == 0 ? dimension / 3 : dimension / 2;
      image.rotate(theta);
      image.fill(color(diamonds[i].hue,360 - diamonds[i].satOffset,360));
      image.beginShape();
      image.vertex(0,radius);
      image.vertex(20,radius + 30);
      image.vertex(0, radius + dist);
      image.vertex(-20, radius + 30);
      image.endShape();
      diamonds[i].satOffset += 10;
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    
    bassShape += 2;
    trebleShape -= 2;
    if (bassShape >= diamonds.length) bassShape = 0;
    if (trebleShape < 0) trebleShape = numShapes - 1;
    colorMode(RGB, 255);
    
  }
  
  private class Diamond {
    int hue;
    int satOffset;
    int direction = -1;
    Diamond() {
      this.hue = int(random(360));
      this.satOffset = 0;
    }
    
    void update() {
      //brightness = 0;
      satOffset += direction * 10;
      if (satOffset > 360) direction = -1;
      else if (satOffset < 0) direction = 1;
    }
  }
}