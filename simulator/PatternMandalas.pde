class PatternMandalas extends Pattern {
  int numRings = 5;
  int finishedRings = 0;
  boolean ringset = false;
  Ring[] rings = new Ring[numRings];
  PatternMandalas() {
    int lastOut = 0;
    for (int i = 0; i < rings.length; i++) {
      if (lastOut >= NUM_LEDS_PER_STRIP) return;
      int out = lastOut + 3 + int(random(10, 15));
      if (out > NUM_LEDS_PER_STRIP) out = NUM_LEDS_PER_STRIP;
      rings[i] = new Ring(lastOut + 3, out);
      lastOut = out;
    }
  }
  void runDefault(Strip[] strips) {
    for (int i = 0; i < rings.length; i++) {
      Ring r = rings[i];
      for (int s = r.offset + r.fadeOut; s < r.t + r.offset; s++) {
        for (int l = r.innerRing; l < r.outerRing; l++) {
          if (l == r.innerRing || l == r.outerRing - 1 || 
            l == r.innerRing + 1 || l == r.outerRing - 2) {
            strips[s % NUM_STRIPS].leds[l] = r.c1;
          } else if (s % r.numShapes == 0) { 
            strips[s % NUM_STRIPS].leds[l] = r.c1;
          }
          if (s % r.numShapes < r.outerRing - r.innerRing) {
            for (int j = 2; j < s % r.numShapes; j++) {
              strips[s % NUM_STRIPS].leds[r.innerRing + j] = r.c2;
            }
          }
        }
      }
      r.update();
    }
  }

  int[] factors = { 2, 3, 4, 6, 8, 12, 16, 24, 32, 48};
  class Ring {
    int innerRing;
    int outerRing;
    int offset;
    int t = 0;
    int fadeOut = 0;

    color c1;
    color c2;
    int velocity;
    int numShapes;
    Ring(int pos, int out) {
      innerRing = pos;
      outerRing = out;
      offset = int(random(NUM_STRIPS));
      setParams();
    }

    void update() {
      if (t < NUM_STRIPS) {
        t += velocity;
      }
      if (t > NUM_STRIPS / 2) {
        fadeOut += velocity;
      }
      if (t >= NUM_STRIPS && fadeOut >= NUM_STRIPS) { 
        t = 0; 
        fadeOut = 0;
        setParams();
      }
    }

    void setParams() {
      numShapes = factors[int(random(factors.length))];
      colorMode(HSB, 360);
      c1 = color(random(360), 360, 360);
      c2 = color(hue(c1) + 50 % 360, 360, 360);
      colorMode(RGB, 255);
      velocity = int(random(1, 4));
    }
  }
}