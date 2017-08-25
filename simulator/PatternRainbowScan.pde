/*
* Full rainbow gradient scanner.
*/

class PatternRainbowScan extends CartesianPattern {
  int shift = 0;
  public void runDefault(Strip[] strips) {
    colorMode(HSB, 360, 100, 100);
    for (int y = 0; y < this.dimension; y++) {
      for (int x = 0; x < this.dimension; x++) {
        int hue = ((y * 100 / this.dimension) + shift) % 100;

        image.set(x,y, color(hue,100,100));
      }
    }
    shift = (shift + 2) % 100 ;
    colorMode(RGB, 255);
    scrapeImage(image.get(), strips);
  }
}
