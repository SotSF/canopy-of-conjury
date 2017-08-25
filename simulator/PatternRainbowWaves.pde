/** 
* Given Point A (x0,y0) and B (x1,y1), 
* animate a sine wave between the two 
*/
class PatternRainbowWaves extends CartesianPattern {
  ArrayList<Wave> waves = new ArrayList<Wave>();
  void runDefault(Strip[] strips) {
    if (conjurer.mode == MODE_MANUAL) {
      if (random(100) > 80) { 
        addWave(new PVector(random(500), random(500)), 
          new PVector(random(500), random(500)));
      }
    }
    image.beginDraw();
    image.background(0);
    colorMode(HSB, 360);
    for (int i = waves.size() - 1; i >= 0; i--) {
      Wave w = waves.get(i);
      renderWave(w);
      w.update();
      if (w.remove) waves.remove(w);
    }
    colorMode(RGB, 255);
    image.endDraw();
    scrapeImage(image.get(), strips);
  }

  void renderWave(Wave w) {
    image.pushMatrix();
    float theta = atan2(w.end.y - w.start.y, w.end.x - w.start.x);
    image.translate(w.start.x, w.start.y);
    image.rotate(theta);
    image.noStroke();
    float v = 0;
    for (float i = 0; i < w.t; i += 0.5) {
      image.fill(color((w.hue - i) % 360, 360, 360, (w.brightness / w.t * i) % 360));
      float x = i * v;
      float y = sin(0.5 * i) * (i);
      image.ellipse(x, y, i, i);
      v += w.step;
    }
    image.popMatrix();
  }

  void addWave(PVector start, PVector end) {
    waves.add(new Wave(start, end));
  }

  class Wave {
    PVector start;
    PVector end;
    float t = 0;
    float step = 0.1;
    boolean remove = false;
    float hue = random(360);
    float brightness = 0;
    int brightDirection = 1;
    Wave(PVector s, PVector e) {
      start = s;
      end = e;
    }

    void update() {
      t += 2;
      hue = (hue + 360 / 100) % 360;
      brightness += 10 * brightDirection;
      if (brightness > 360) brightDirection = -1;
      if (brightness < 0) remove = true;
    }
  }
}