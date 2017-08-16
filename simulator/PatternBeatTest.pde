class PatternBeatDetect extends CartesianPattern {
  PGraphics image = createGraphics(dimension, dimension);
  int[] brightness = new int[12];
  float[] throttles = new float[12];
  BeatListener bl;
  PatternBeatDetect() {
    image.noSmooth();
  }
  synchronized void visualize(Strip[] strips) {
    if (beat == null) { 
      beat = new BeatDetect();
      beat.setSensitivity(120);
      bl = new BeatListener(beat);
    }
    if (listeningToMic) { beat.detect(audio.mix); }
    else { beat.detect(player.mix); }
    colorMode(HSB, 360);
    fftForward();
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave
      float amplitude = getAmplitudeForBand(i);

      if (amplitude > 10) { 
        brightness[i] = round(amplitude * 10); 
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