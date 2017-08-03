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