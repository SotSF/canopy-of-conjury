class IdentifyStripZero extends Pattern {
  void runDefault(Strip[] strips) {
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      strips[0].leds[l] = color(0,255,0);
    }
  }
}

class IdentifyTripleZigs extends Pattern {
  color[] zigs = {
    color(255,0,0),
    color(0,255,0),
    color(0,0,255),
    color(255,255,0),
  };
  void runDefault(Strip[] strips) {
    int currentZig = 0;
    for (int s = 0; s < NUM_STRIPS; s++) {
      if (s % 6 == 0) { currentZig++; }
      for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
        strips[s].leds[l] = zigs[currentZig % 4];
      }
    }
  }
}

class Snakes extends Pattern {
  color[] zigs = {
    color(255,0,0),
    color(0,255,0),
    color(0,0,255),
    color(255,255,0),
  };
  ArrayList<Snake> snakes = new ArrayList<Snake>();
  Snakes() {
    for (int i = 0; i < 16; i++) { snakes.add(new Snake(i * 6)); }
  }
  void runDefault(Strip[] strips) {
    for (Snake s : snakes) {
      strips[s.currentStrip].leds[s.currentLed] = s.c;
      s.update();
    }
  }
  
   private class Snake {
    int currentStrip = 0;
    int currentLed = 0;
    int outToBase = 1;
    color c = zigs[int(random(4))];
    Snake(int s) {
      currentStrip = s;
    }
    void update() {
      currentLed += outToBase;
      if (currentLed >= NUM_LEDS_PER_STRIP) {
        currentLed = NUM_LEDS_PER_STRIP - 1;
        outToBase = -1;
        currentStrip++;
      }
      if (currentLed < 0) {
        currentLed = 0;
        outToBase = 1;
        currentStrip++;
      }
      if (currentStrip >= NUM_STRIPS) currentStrip = 0;
    }
  }
}

class RedRing extends Pattern {
  int currentRing = 0;
  void runDefault(Strip[] strips) {
    for (Strip s : strips) {
      s.leds[currentRing] = color(255,0,0);
    }
    currentRing++;
    if (currentRing >= NUM_LEDS_PER_STRIP) currentRing = 0;
  }
}