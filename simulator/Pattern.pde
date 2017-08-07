public interface IPattern {
  void run(Strip[] strips);
  void runDefault(Strip[] strips);
  void visualize(Strip[] strips);
}

class EmptyPattern implements IPattern {
  public void run(Strip[] strips) {
    clearStrips();
  }
  public void runDefault(Strip[] strips) { run(strips); }
  public void visualize(Strip[] strips) { run(strips); }
}

class Pattern implements IPattern {
  public int sampleRate = 44100;
  public void run(Strip[] strips) {
    if (listeningToMic){
      visualize(strips);
    } else {
      if (player != null && player.isPlaying()) {
        visualize(strips);
      } else {
        runDefault(strips);
      }
    }
  }

  public void runDefault(Strip[] strips) {
    clearStrips();
  }

  public void visualize(Strip[] strips) {
    runDefault(strips);
  }

  public void fftForward() {
    if (listeningToMic) fft.forward(audio.mix);
    else fft.forward(player.mix);
  }
}

public class CartesianPattern extends Pattern {
  int dimension = 500;
  float maxRadius = sqrt(2 * dimension * dimension);

  public CanopyCoord mapToCanopy(int x, int y) {
    int x2 = floor(map(x,0,dimension,-dimension/2,dimension/2));
    int y2 = floor(map(y,0,dimension,-dimension/2,dimension/2));
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
    for (int y = 0; y < dimension; y++) {
      for (int x = 0; x < dimension; x++) {
        CanopyCoord co = mapToCanopy(x,y);
        // the center of the cartesian plane doesn't play well with canopy coords
        int l = co.led - 5;
        if (l < 0 || l >= NUM_LEDS_PER_STRIP) {
          continue;
        }
         color c = get(x,y);
        if (c == color(0) || c == 0) { continue; }
        strips[co.strip].leds[l] = c;
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
        if (c == color(0) || c == 0) { continue; }
        strips[co.strip].leds[l] = c;

      }
    }
  }

  public void clearWindow() {
    clear();
  }

  // describe a point on the Canopy, by strip number and LED number
  class CanopyCoord {
    int strip;
    int led;
    public CanopyCoord(int s, int l) {
      this.strip = s;
      this.led = l;
    }
  }

   // describe a point in the Cartesian plane, 0 <= x < 500 and 0 <= y < 500,
   // i.e., a point on our drawing window
  class Position {
     int x;
     int y;
     Position(int x, int y) {
       this.x = x;
       this.y = y;
     }
  }
}

class ImgPattern extends CartesianPattern {
  String filename;
  PImage img;
   public ImgPattern(PImage img) {
    this.img = img;
    this.img.resize(dimension,dimension);
  }

  public ImgPattern(String filename) {
    this.filename = filename;
    img = loadImage(filename);
    img.resize(dimension,dimension);
  }

  public void run(Strip[] strips) {
    scrapeImage(img, strips);
  }

}


class GifPattern extends CartesianPattern {
 int frame = 0;
 PImage[] frames;
 public GifPattern(PApplet window, String filepath) {
   frames = Gif.getPImages(window, filepath);
 }

  public void run(Strip[] strips) {
    PImage img = frames[frame];
    img.resize(dimension,dimension);
    scrapeImage(img, strips);
    this.frame++;
    if (this.frame >= frames.length) this.frame = 0;
  }

}

class PlaylistPattern extends CartesianPattern {
    int startTime;
    int runTime;
    int playlistIndex;
    int playlistLength;
    String foldername;
    PApplet window;
    GifPattern currentGif;

    public PlaylistPattern(PApplet window, String foldername, int runTime) {
        this.window = window;
        this.foldername = foldername;
        this.currentGif = new GifPattern(window, getNthGif(0));
        this.startTime = millis();
        this.runTime = runTime;
        this.playlistIndex = 0;
        this.playlistLength = listGifsInFolder().length;
        //println("in: initialization, this.foldername =" + this.foldername);
    }

    private String[] listGifsInFolder(){
        //println("in: listGifs, this.foldername =" + this.foldername);
        File playlistFolder = new File(foldername);
        String[] gifs = playlistFolder.list();
        return gifs;
    }

    private String getNthGif(int n){
        String[] gifs = listGifsInFolder();
        return foldername + "/"+gifs[n];
    }

    public void run(Strip[] strips) {
        int currentTime = millis();
        int currentDuration = currentTime - startTime;
        if (currentDuration > runTime) {
            playlistIndex++;
            if (playlistIndex == playlistLength)
                playlistIndex = 0;
            startTime = currentTime;
            currentGif = new GifPattern(window, getNthGif(playlistIndex));
        }
        currentGif.run(strips);
    }
}

class MoviePattern extends CartesianPattern {
  public MoviePattern(boolean loop, boolean sound) {
    if (loop) { movie.loop(); }
    else { movie.play(); }
    if (!sound) { movie.volume(0); }
  }

  public void run(Strip[] strips) {
    if (movie.width < 1 && movie.height < 1) return;
    PImage frame = movie.get();
    frame.resize(dimension,dimension);
    scrapeImage(frame,strips);
  }
}

void movieEvent(Movie m) {
  m.read();
}

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;

  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}
