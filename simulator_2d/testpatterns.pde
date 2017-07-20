class TestPattern extends CartesianPattern implements Pattern {
  int currHue = 0;
  float pos = 0;
  float min = dimension / 2 - 5;
  public void run(Strip[] strips) {
    colorMode(HSB,100);
    while (pos <= min) {
      fill(color(currHue,100,100));
      rect(pos,pos,dimension-pos * 2,dimension-pos * 2);
      currHue += 10;
      if (currHue > 100) currHue = 0;
      pos += dimension / 20;
    }
    colorMode(RGB,255);
    scrapeWindow(strips);
  }
}

class ImgPattern extends CartesianPattern implements Pattern {
  String filename;
  int resizeWidth = dimension;
  int resizeHeight = dimension;
  public ImgPattern(String filename) {
    this.filename = filename;
  }
  
  public ImgPattern(String filename, int w, int h) {
    this.filename = filename;
    this.resizeWidth = w;
    this.resizeHeight = h;
  }
  
  public void run(Strip[] strips) {
    PImage img;
    img = loadImage(filename);
    image(img,0,0,this.resizeWidth,this.resizeHeight);
    scrapeWindow(strips);
  }
}

class MoviePattern extends CartesianPattern implements Pattern {
  Movie movie;
  public MoviePattern(PApplet window, String filename, boolean loop, boolean sound) {
    movie = new Movie(window, filename);
    if (loop) { movie.loop(); }
    else { movie.play(); } 
    if (!sound) { movie.volume(0); }
  }
  
  public void run(Strip[] strips) {
    image(movie,0,0, dimension, dimension);
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
    image(frames[frame],0,0,dimension,dimension);
    scrapeWindow(strips);
    this.frame++;
    if (this.frame >= frames.length) this.frame = 0;
  }
}