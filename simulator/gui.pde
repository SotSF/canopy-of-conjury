boolean isFading = false;

class GUI {
  public ControlP5 cp5;
  
  public GUI(PApplet window) {
    cp5 = new ControlP5(window);
    cp5.addButton("FadeLEDs").setLabel("Fade Out").setPosition(0,0);
    cp5.addButton("PlayPatternSwirly").setLabel("Swirls").setPosition(0,22);
    cp5.setAutoDraw(false);
  }
  
  public void run() {
    currCameraMatrix = new PMatrix3D(g3.camera);
    camera();
    cp5.draw();
    g3.camera = currCameraMatrix;
  }
  
  
}

boolean allLedsOff() {
  int count = 0;
  for (Strip s : ledstrips) {
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      color c = s.leds[l];
      if (c == 0 || c == color(0)) count++;
    }
  }
  return count == TOTAL_LEDS;
}

void FadeLEDs() {
  println("TEST");
  isFading = true;
}

void fadeStrips() {
  colorMode(HSB, 100);
  for (int i = 0; i < NUM_STRIPS; i++) {
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      color c = ledstrips[i].leds[l];
      int red = (c >> 16) & 0xFF;
      int green = (c >> 8) & 0xFF;
      int blue = c & 0xFF;  
      if (red > 0) red--;
      if (green > 0) green--;
      if (blue > 0) blue--;
      ledstrips[i].leds[l] = color(red,green,blue);
    }
  }
  colorMode(RGB,255);
  if (allLedsOff()) {
    isFading = false;
  }
}

void PlayPatternSwirly() {
  FadeLEDs();
  pattern = new PatternSwirly(color(255,0,0), 500, 0, false);
}