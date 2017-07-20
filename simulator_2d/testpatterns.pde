class TestPattern extends CartesianPattern implements Pattern {
  int currHue = 0;
  float min = dimension / 2 - 5;
  public void run(Strip[] strips) {
    colorMode(HSB,100);
    float pos = 0;
    while (pos <= min) {
      fill(color(currHue,100,100));
      rect(pos,pos,dimension-pos * 2,dimension-pos * 2);
      currHue += 10;
      if (currHue > 100) currHue = 0;
      pos += 10;
    }
    colorMode(RGB,255);
    scrapeWindow(strips);
  }
}

class ImgPattern extends CartesianPattern implements Pattern {
  String filename;
  color background;
  int resizeWidth = dimension;
  int resizeHeight = dimension;
  public ImgPattern(String filename, color bgColor) {
    this.filename = filename;
    this.background = bgColor;
  }
  
  public ImgPattern(String filename, color bgColor, int w, int h) {
    this.filename = filename;
    this.background = bgColor;
    this.resizeWidth = w;
    this.resizeHeight = h;
  }
  
  public void run(Strip[] strips) {
    fill(background);
    rect(0,0,dimension,dimension);
    PImage img;
    img = loadImage(filename);
    image(img,0,0,this.resizeWidth,this.resizeHeight);
    scrapeWindow(strips);
  }
}

class GifPattern extends CartesianPattern implements Pattern {
 int frame = 0;
 PImage[] frames;
 public GifPattern(PApplet window, String filename) {
   frames = Gif.getPImages(window, filename);
 }
 
  public void run(Strip[] strips) {
    image(frames[frame],0,0,dispWidth,dispHeight);
    scrapeWindow(strips);
    this.frame++;
    if (this.frame >= frames.length) this.frame = 0;
  }
}