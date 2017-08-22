class PatternKaleidoscope extends CartesianPattern {
  ArrayList<Wave> bassWaves = new ArrayList<Wave>();
  float throttle = 0;
  float triangleAngle = 0;
  float waveAngle = 0;
  void runDefault(Strip[] strips) {
    image.noSmooth();
    image.beginDraw();
    image.background(0);
    float bassAmp = random(5, 100);
    if (random(100) > 60 && bassWaves.size() < 3 && millis() - throttle >= 2000) {
      throttle = millis();
      bassWaves.add(new Wave(bassAmp));
    }

    Collections.sort(bassWaves);
    colorMode(HSB, 360);
    image.translate(image.width / 2, image.height / 2 );
    for (int i = bassWaves.size() - 1; i >= 0; i--) {
      Wave w = bassWaves.get(i);
      renderWave(w);
      w.update();
      if (w.remove) bassWaves.remove(w);
    }
    waveAngle -= radians(0.2);
    colorMode(RGB, 255);
    image.endDraw();

    scrapeImage(image.get(), strips);
  }

  void visualize(Strip[] strips) {
    image.beginDraw();
    image.background(0);

    float bassAmp = getAmplitudeForBand(7);
    if ((bassAmp > 30 && millis() - throttle > 1000) && bassWaves.size() < 3 || bassWaves.size() < 1) {
      throttle = millis();
      bassWaves.add(new Wave(bassAmp));
    }

    Collections.sort(bassWaves);
    colorMode(HSB, 360);
    image.translate(image.width / 2, image.height / 2 );
    for (int i = bassWaves.size() - 1; i >= 0; i--) {
      Wave w = bassWaves.get(i);
      renderWave(w);
      w.update();
      if (w.remove) bassWaves.remove(w);
    }
    waveAngle -= radians(0.2);
    colorMode(RGB, 255);

    renderTriangles(getAmplitudeForBand(10) * 5, beat.isKick());
    triangleAngle += radians(1);


    image.endDraw();

    scrapeImage(image.get(), strips);
  }

  void renderTriangles(float offset, boolean isKick) {
    pushMatrix();
    image.noFill();
    if (isKick) image.fill(255);
    image.strokeWeight(3);
    image.stroke(255);
    float theta = PI / 3;
    image.rotate(triangleAngle); 
    for (int i = 0; i < 6; i++) {
      image.rotate( theta );
      image.beginShape();
      image.vertex(0, 20 + offset);
      image.vertex(40, 75 + offset);
      image.vertex(-40, 75 + offset);
      image.endShape(CLOSE);
    }
    popMatrix();
  }

  void renderWave(Wave w) {
    image.pushMatrix();
    image.rotate(w.theta);
    image.rotate( waveAngle );

    image.stroke(color(w.hue, 360, 360 * w.brightness, 360 - w.t));
    image.strokeWeight(3);
    image.fill(color(w.hue, 360, 360 * w.brightness, 360 - w.t));
    for (int i = 0; i < 6; i++) {
      image.rotate(PI / 3);
      image.beginShape();
      for (float x = 0; x < w.t; x += 5) {
        //float y0 = float y = w.amp * sin(x * image.height / w.amp);
        float y = w.flip * w.amp * sin(x * 0.2 * w.amp);
        image.curveVertex(x, y);
      }
      image.endShape();
    }

    image.popMatrix();
  }


  class Wave implements Comparable {
    float amp;
    float theta;
    float brightness = 1; // percent
    int t = 0;
    boolean remove = false;
    float hue;
    int flip;
    Wave(float amp) {
      this.amp = amp;
      this.hue = random(360);
      this.flip = random(100) > 50 ? 1 : -1;
    } 
    void update() {
      t += 5;
      if (t > 300) brightness -= 0.1;
      if (brightness < 0) remove = true;
      hue = (hue + 5) % 360;
    }

    public int compareTo(Object w) {
      if (this.amp < ((Wave)w).amp) return 1;
      else return -1;
    }
  }
}