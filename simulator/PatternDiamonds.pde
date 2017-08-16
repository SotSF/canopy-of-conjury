class PatternDiamonds extends CartesianPattern {
  int numShapes = 16;
  int currentShape = 0;
  int bassShape = 0;
  int trebleShape = numShapes - 1;
  BeatListener bl;
  Pattern gradient = new PatternGradientPulse();
  Diamond[] diamonds;
  PatternDiamonds() {
    image.noSmooth();
    diamonds = new Diamond[numShapes];
    for (int i = 0; i < diamonds.length; i++) {
      diamonds[i] = new Diamond();
    }
    
  }
  void runDefault(Strip[] strips) {
    colorMode(HSB, 360);
    image.beginDraw();
    image.clear();
    image.background(0);
    image.translate(dimension/2,dimension/2);
    for (int i = 0; i < diamonds.length; i++) {
      if (i == currentShape) diamonds[i].satOffset += 60;
      
      float theta = 2 * PI / numShapes;
      float radius = i % 2 == 0 ? 100 : 50;
      float dist = i % 2 == 0 ? dimension / 3 : dimension / 2;
      image.rotate(theta);
      image.fill(color(diamonds[i].hue, 360,360-diamonds[i].satOffset,360));
      image.beginShape();
      image.vertex(0,radius);
      image.vertex(20,radius + 30);
      image.vertex(0, radius + dist);
      image.vertex(-20, radius + 30);
      image.endShape();
      diamonds[i].update();
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    colorMode(RGB, 255);
    currentShape++;
    if (currentShape >= diamonds.length) currentShape = 0;
  }
  
  synchronized void visualize(Strip[] strips) {
    if (beat == null) { 
      beat = new BeatDetect();
      beat.setSensitivity(120);
      bl = new BeatListener(beat);
    }
    gradient.visualize(strips);
    colorMode(HSB, 360);
    fftForward();

    diamonds[bassShape].hue = int(random(270,290));
    diamonds[bassShape].satOffset = round(getAmplitudeForBand(5) * 10); 
    diamonds[trebleShape].hue = int(random(250,270));
    diamonds[trebleShape].satOffset = round(getAmplitudeForBand(11) * 10); 

    image.beginDraw();
    image.clear();
    image.background(0);
    image.translate(dimension/2,dimension/2);
    for (int i = 0; i < diamonds.length; i++) {
      if (i == bassShape || i == trebleShape) diamonds[i].satOffset += 60;
      
      float theta = 2 * PI / numShapes;
      float radius = i % 2 == 0 ? 100 : 50;
      float dist = i % 2 == 0 ? dimension / 3 : dimension / 2;
      image.rotate(theta);
      image.fill(color(diamonds[i].hue,360 - diamonds[i].satOffset,360));
      image.beginShape();
      image.vertex(0,radius);
      image.vertex(20,radius + 30);
      image.vertex(0, radius + dist);
      image.vertex(-20, radius + 30);
      image.endShape();
      diamonds[i].satOffset += 10;
    }
    image.endDraw();
    scrapeImage(image.get(), strips);
    
    bassShape += 2;
    trebleShape -= 2;
    if (bassShape >= diamonds.length) bassShape = 0;
    if (trebleShape < 0) trebleShape = numShapes - 1;
    colorMode(RGB, 255);
    
  }
  
  private class Diamond {
    int hue;
    int satOffset;
    int direction = -1;
    Diamond() {
      this.hue = int(random(360));
      this.satOffset = 0;
    }
    
    void update() {
      //brightness = 0;
      satOffset += direction * 10;
      if (satOffset > 360) direction = -1;
      else if (satOffset < 0) direction = 1;
    }
  }
}