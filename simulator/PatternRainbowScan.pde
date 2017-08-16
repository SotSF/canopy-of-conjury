/*
* Full rainbow gradient scanner.
*/

class PatternRainbowScan extends CartesianPattern {
  int shift = 0;
  public void runDefault(Strip[] strips) {
    colorMode(HSB, 100);
    for (int y = 0; y < this.dimension; y++) {
      for (int x = 0; x < this.dimension; x++) {
        int hue = (y * 100 / this.dimension) + shift;
        if (hue > 100) {
          hue += -100;
        }
        //pixelWindow[y][x] = color(hue,100,100);;
        //pixels[y * x] = color(hue,100,100);
        image.set(x,y, color(hue,100,100));
      }
    }
    this.shift += 2;
    if (this.shift >= 100) {
      this.shift = 0;
    }
    colorMode(RGB, 255);
    scrapeImage(image.get(), strips);
  }
}