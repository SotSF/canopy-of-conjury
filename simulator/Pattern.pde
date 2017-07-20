public interface Pattern {
  void run(Strip[] strips);
}

public class CartesianPattern {
  int dimension = 500;
  float maxRadius = sqrt(2 * dimension * dimension);
  
  // helper classes
  public int mapCartesian(int x) {
    return x - dimension / 2;
  }
  
  public CanopyCoord mapToCanopy(int x, int y) {
    int x2 = this.mapCartesian(x);
    int y2 = this.mapCartesian(y);
    float theta = 0;
    if (x2 == 0) {
      if (y2 > 0) theta = PI / 2;
      if (y2 < 0) theta = -PI / 2;
      if (y2 == 0) theta = 0;
    } else {
      theta = atan2(y2,x2);
    }
    float radius = sqrt(x2 * x2 + y2 * y2);
    
    float thetaDegrees = theta * 180 / PI;
    if (thetaDegrees < 0) { thetaDegrees += 360; }
    int s = floor(thetaDegrees * NUM_STRIPS / 360);
    int l = floor(radius / 3);
    return new CanopyCoord(s, l);
    
  }
  
  public void scrapeWindow(Strip[] strips) {
    clearStrips();
    for (int y = 0; y < dimension; y++) {
      for (int x = 0; x < dimension; x++) {
        CanopyCoord co = mapToCanopy(x,y);
        // the center of the cartesian plane doesn't play well with canopy coords
        int l = co.led - 5; 
        if (l < 0 || l >= NUM_LEDS_PER_STRIP) {
          continue;
        }
        
        strips[co.strip].leds[l] = get(x,y);
      }
    }
  }
  
  public void scrapeImage(PImage img, Strip[] strips) {
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        CanopyCoord co = mapToCanopy(x,y);
        // the center of the cartesian plane doesn't play well with canopy coords
        int l = co.led - 5; 
        if (l < 0 || l >= NUM_LEDS_PER_STRIP) {
          continue;
        }
         color c = img.get(x,y);
        strips[co.strip].leds[l] = c;
        
      }
    }
  }
  
  public void clearWindow() {
    clear();
  }
  
  public class CanopyCoord {
    int strip;
    int led;
    public CanopyCoord(int s, int l) {
      this.strip = s;
      this.led = l;
    }
  }
}

class ImgPattern extends CartesianPattern implements Pattern {
  String filename;
  PImage img;
  public ImgPattern(String filename) {
    this.filename = filename;
    img = loadImage(filename);
    img.resize(dimension,dimension);
  }
  
  public void run(Strip[] strips) {
    scrapeImage(img, strips);
  }
}

class GifPattern extends CartesianPattern implements Pattern {
 int frame = 0;
 PImage[] frames;
 public GifPattern(PApplet window, String filename) {
   frames = Gif.getPImages(window, filename);
 }
 
  public void run(Strip[] strips) {
    PImage img = frames[frame];
    img.resize(dimension,dimension);
    scrapeImage(img, strips);
    this.frame++;
    if (this.frame >= frames.length) this.frame = 0;
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
    //image(movie,0,0, dimension, dimension);
    //movie.resize(dimension,dimension);
    scrapeImage(movie,strips);
  }
}

void movieEvent(Movie m) { 
  m.read(); 
}