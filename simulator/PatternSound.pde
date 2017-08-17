/*
* Two rings, one each at apex and base, simulating sound wave movement.
 */

class PatternSound extends Pattern {
  BeatListener bl;
  int colorShifter = 0;
  int direction = 1;

  int mydelay = 0;
  int milliDiff = 0;
  int time = 0;

  public void runDefault(Strip[] strips) {
    colorMode(HSB, 100);
    int offset = int(random(5, 10));

    for (int i = 0; i < NUM_STRIPS; i++) {
      //int lights = int(random(40,50));
      int lights = int(random(20, 30));
      lights += offset;

      for (int l = 0; l < lights; l++) {
        strips[i].leds[l] = getColor(i, l);

        int oppositeStripIndex = i + NUM_STRIPS / 2 > NUM_STRIPS
          ? i - NUM_STRIPS / 2
          : i + NUM_STRIPS / 2;

        // color the LEDs on the outside the opposite color as those on the inside
        strips[i].leds[NUM_LEDS_PER_STRIP - l - 1] = getColor(oppositeStripIndex, l);
      }
    }

    if (random(100) > 99) direction = direction * -1;
    colorShifter += 120 / NUM_STRIPS * direction;
    if (colorShifter >= 100) { 
      colorShifter = 0;
    }
    if (colorShifter < 0) { 
      colorShifter = 100;
    }
    colorMode(RGB, 255);
  }

  synchronized void visualize(Strip[] strips) {
    time = millis();
    milliDiff = time - mydelay;
    colorMode(HSB, 100);
    int innerOffset = round(getAmplitudeForBand(7) / 4);
    int outerOffset = round(getAmplitudeForBand(11) / 3);
    

    for (int i = 0; i < NUM_STRIPS; i++) {
      int lights = int(random(20, 25));
      for (int l = 0; l < innerOffset + lights; l++) {
        if (l < NUM_LEDS_PER_STRIP) strips[i].leds[l] = getColor(i, l);
      }

      int oppositeStripIndex = i + NUM_STRIPS / 2 > NUM_STRIPS
          ? i - NUM_STRIPS / 2
          : i + NUM_STRIPS / 2;

      for (int l = 0; l < outerOffset + lights; l++) {
        // color the LEDs on the outside the opposite color as those on the inside
        strips[i].leds[NUM_LEDS_PER_STRIP - l - 1] = getColor(oppositeStripIndex, l);
      }
    }

    mydelay=time;
    int bpm = 6000 / milliDiff; // this should actually be 60000?
    println(bpm);
    if (bpm > 160) { 
      direction = -1 * direction;
    } else if (innerOffset > 10) { 
      direction = -1 * direction;
    }
    if (bpm < NUM_STRIPS) { 
      bpm += bpm;
    }
    colorShifter += bpm / NUM_STRIPS * direction;
    if (colorShifter >= 100) { 
      colorShifter = 0;
    } else if (colorShifter < 0) {
      colorShifter = 100;
    }
    colorMode(RGB, 255);
  }

  private color getColor(int stripIndex, int ledIndex) {
    int hue = 100 * stripIndex / NUM_STRIPS + colorShifter;
    hue = hue % 100;
    if (hue < 0) hue += 100;

    int sat = 100 - ledIndex;
    return color(hue, sat, 100);
  }
}

class PatternSoundBlob extends CartesianPattern {
  float bassTheta = 0;
  float bassAmp = 0;
  float trebleTheta = bassTheta + PI;
  float trebleAmp = 0;
  float colorShift = 0;
  PatternSoundBlob() {
    image.noSmooth();
  }
  void runDefault(Strip[] strips) {
    bassAmp = random(20, 200);
    trebleAmp = random(20, 300);
    image.beginDraw();
    image.background(0);
    image.noStroke();
    image.pushMatrix();
    image.translate(dimension/2, dimension/2);
    image.noStroke();
    image.fill(255);

    renderSpike(bassAmp, bassTheta);
    renderSpike(trebleAmp, trebleTheta);
    for (int i = 1; i < 6; i++) {
      renderSpike(bassAmp, bassTheta + i * PI / 3);
      renderSpike(trebleAmp - i * 15, trebleTheta + i * PI / 6);
    }

    bassTheta += PI / 18;
    //if (bassTheta >= 2 * PI) bassTheta -= 2 * PI;

    trebleTheta += PI / 18;
    //if (trebleTheta >= 2 * PI) trebleTheta -= 2 * PI; 
    colorOverlay();
    image.popMatrix();
    image.endDraw();
    scrapeImage(image.get(), strips);
  }
  synchronized void visualize(Strip[] strips) {
    bassAmp = getAmplitudeForBand(7) * 8;
    trebleAmp = getAmplitudeForBand(11) * 14;
    image.beginDraw();
    image.background(0);
    image.noStroke();
    image.pushMatrix();
    image.translate(dimension/2, dimension/2);
    image.noStroke();
    image.fill(255);

    renderSpike(bassAmp, bassTheta);
    renderSpike(trebleAmp, trebleTheta);
    for (int i = 1; i < 6; i++) {
      renderSpike(bassAmp, bassTheta + i * PI / 3);
      if (trebleAmp > 200) { 
        renderSpike(trebleAmp - i * 15, trebleTheta + i * PI / 6);
      } else { 
        renderSpike(trebleAmp, trebleTheta + i * PI / 6);
      }
    }

    bassTheta += PI / 18;
    //if (bassTheta >= 2 * PI) bassTheta -= 2 * PI;

    trebleTheta += PI / 18;
    //if (trebleTheta >= 2 * PI) trebleTheta -= 2 * PI; 
    colorOverlay();
    image.popMatrix();
    image.endDraw();
    scrapeImage(image.get(), strips);
  }
  void colorOverlay() {
    colorMode(HSB, 360);
    for (int x = 0; x < dimension; x++) {
      for (int y = 0; y < dimension; y++) {
        if (image.get(x, y) == color(360)) {
          int xOff = x - dimension / 2;
          int yOff = y - dimension / 2;
          float r = sqrt(xOff * xOff + yOff * yOff);
          float t = atan2(yOff, xOff);
          if (t < 0) t += 2 * PI;
          float hue = degrees(t) + colorShift;

          if (hue >= 360) hue -= 360;
          image.set(x, y, color(hue, r * 10, 360));
        }
      }
    }
    colorMode(RGB, 255);
    colorShift += 0.5;
    if (colorShift >= 360) colorShift = 0;
  }

  void renderSpike(float rad, float theta) {
    float spokeWidth = 50;
    float x = rad * cos(theta);
    float y = rad * sin(theta);
    float xr = spokeWidth * cos(theta + PI / 2);
    float yr = spokeWidth * sin(theta + PI / 2);
    float xl = spokeWidth * cos(theta - PI / 2);
    float yl = spokeWidth * sin(theta - PI / 2);

    image.beginShape();
    image.curveVertex(xr, yr);
    image.curveVertex(xr, yr);
    image.curveVertex(x, y);
    image.curveVertex(xl, yl);
    image.curveVertex(xl, yl);
    image.endShape();
  }
}