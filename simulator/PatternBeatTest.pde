class PatternBeatDetect extends CartesianPattern {
  PGraphics image = createGraphics(dimension, dimension);
  int[] brightness = new int[12];
  float[] throttles = new float[12];
  BeatListener bl;
  PatternBeatDetect() {
    image.noSmooth();
  }
  void visualize(Strip[] strips) {
    if (beat == null) { 
      beat = new BeatDetect();
      beat.setSensitivity(120);
      if (listeningToMic) { bl = new BeatListener(beat, audio); }
      else { bl = new BeatListener(beat, player); }
    }
    if (listeningToMic) { beat.detect(audio.mix); }
    else { beat.detect(player.mix); }
    colorMode(HSB, 360);
    fftForward();
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave
      int lowFreq;
      if ( i == 0 ) { 
        lowFreq = 0;
      } else {  
        lowFreq = (int)((sampleRate/2) / (float)Math.pow(2, 12 - i));
      }
      int hiFreq = (int)((sampleRate/2) / (float)Math.pow(2, 11 - i));

      // we're asking for the index of lowFreq & hiFreq
      int lowBound = fft.freqToIndex(lowFreq); // freqToIndex returns the index of the frequency band that contains the requested frequency
      int hiBound = fft.freqToIndex(hiFreq); 

      // calculate the average amplitude of the frequency band
      float amplitude = fft.calcAvg(lowBound, hiBound);
      // keep track of high amplitudes in bands 5 (bass freqs) and 11 (treble freqs)
      // but we could be paying attention to any range of frequencies
      if (amplitude > 10 && millis() - throttles[i] > 100) { 
        brightness[i] = round(amplitude * 10); 
        throttles[i] = millis();
      }
    }
    image.beginDraw();
    image.clear();
    image.background(0);
    image.translate(dimension/2, dimension/2);
    for (int i = 0; i < 12; i++) {
      image.rotate(2 * PI / 12);
      image.fill(color(360 / 12 * i, 360, brightness[i]));
      brightness[i] -= 50;
      //image.fill(brightness[i]);
      image.noStroke();
      image.ellipse(0, 150, 80, 80);
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    colorMode(RGB, 255);
  }
}