class PatternBeatDetect extends CartesianPattern {
  int[] brightness = new int[12];
  BeatListener bl;
  PatternBeatDetect() {
    image.noSmooth();
  }
  synchronized void visualize(Strip[] strips) {
    colorMode(HSB, 360);
    image.beginDraw();
    image.clear();
    image.background(0);
    image.translate(dimension/2, dimension/2);
    for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave
      float amplitude = getAmplitudeForBand(i);
      image.rotate(2 * PI / 12);
      if (amplitude > 10) { 
        brightness[i] = round(amplitude * 10); 
      }
      image.fill(color(360 / 12 * i, 360, brightness[i]));
      image.noStroke();
      image.ellipse(0, 150, 80, 80);
      brightness[i] -= 50;
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    colorMode(RGB, 255);
  }
}