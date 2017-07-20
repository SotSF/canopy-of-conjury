


// ======================================
class PatternDiagonalGradient {
  int _x = 0;
  int _y = 0;
  int _c = color(255,100,35);
  
  public void run() {
     set(_x,_y,_c);
     getNextPixel();
     getNextColor();
  }
  
  public void getNextPixel() {
    _x += 1;
    int r = (int)random(100);
    if (r < 10) { _y += -1; }
    else { _y += 1; }
    
    // check params
    if (_x > dispWidth) { _x = 0; }
    if (_x < 0) { _x = dispWidth; }
    if (_y > dispHeight) { _y = 0; }
    if (_y < 0) { _y = dispHeight; }
  }
  
  public void getNextColor() {
    int d = (int)random(10);
    int direction = 1;
    if (d > 5) direction = -1;
    int r = (int)random(3);
    int red = (_c >> 16) & 0xFF;
    int green = (_c >> 8) & 0xFF;
    int blue = _c & 0xFF;  
    
    switch (r) {
      case 0: //red
        red += 20 * direction;
        break;
      case 1:
        green += 20 * direction;
        break;
      case 2:
        blue += 20 * direction;
        break;
    }
    
    _c = color(red, green, blue);
    
  }
}

class TestPattern extends CartesianPattern implements Pattern {
  public void run(Strip[] strips) {
      fill(color(255,0,0));
      ellipse(0,0,10,10);
      ellipse(50,50,10,10);
      ellipse(dispWidth / 4 * 3, dispHeight/2, 10,10);
      fill(color(0,255,0));
      ellipse(150,50,10,10);
      ellipse(dispWidth / 4 * 2, dispHeight/4 * 3, 10,10);
      fill(color(255,255,0));
      ellipse(150,150,10,10);
      ellipse(dispWidth / 4 , dispHeight/4 * 2, 10,10);
      fill(color(0,0,255));
      ellipse(50,150,10,10);
      ellipse(dispWidth / 4 * 2, dispHeight/4, 10,10);
    
    // center
    fill(255,255,255);
    ellipse(100,100,30,30);
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