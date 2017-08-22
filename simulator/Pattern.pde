public interface IPattern {
  // Rendering methods
  void run(Strip[] strips);
  void runDefault(Strip[] strips);
  void visualize(Strip[] strips);
  void renderAuxiliary();

  // Event methods
  void onMousePressed  ();
  void onMouseReleased ();
  void onMouseClicked  ();
  void onMouseDragged  ();
  void onKeyPressed    ();

  // Set up and tear down
  void initialize();
  void onClose(Strip[] strips);
}

class EmptyPattern implements IPattern {
  // Rendering methods
  public void run(Strip[] strips) { clearStrips(); }
  public void runDefault(Strip[] strips) { run(strips); }
  public void visualize(Strip[] strips) { run(strips); }
  public void renderAuxiliary() {};

  // Event methods
  void onMousePressed  () {};
  void onMouseReleased () {};
  void onMouseClicked  () {};
  void onMouseDragged  () {};
  void onKeyPressed    () {};

  // Set up and tear down
  public void initialize() {};
  public void onClose(Strip[] strips) { run(strips); }
}

class Pattern implements IPattern {
  BeatListener bl;
  // Rendering methods
  public void run(Strip[] strips) {
    if (listeningToMic){
      fftForward();
      visualize(strips);
    } else {
      if (player != null && player.isPlaying()) {
        fftForward();
        visualize(strips);
      } else {
        runDefault(strips);
      }
    }
  }

  public void runDefault(Strip[] strips) { clearStrips(); }
  public void visualize(Strip[] strips) { runDefault(strips); }
  public void renderAuxiliary() {};

  // Event methods -- by default no action is taken. Inheriting pattern classes
  // can implement pattern-specific behavior
  void onMousePressed  () {};
  void onMouseReleased () {};
  void onMouseClicked  () {};
  void onMouseDragged  () {};
  void onKeyPressed    () {};

  // Set up and tear down
  public void initialize() {};
  public void onClose(Strip[] strips) { runDefault(strips); }

  // Audio sampling rate
  public int sampleRate = 44100;
  
  public void fftForward() {
    if (beat == null) { 
      if (listeningToMic) beat = new BeatDetect(audio.bufferSize(), audio.sampleRate());
      else beat = new BeatDetect(player.bufferSize(), player.sampleRate());
      beat.setSensitivity(120);
      bl = new BeatListener(beat);
    }
    if (listeningToMic) fft.forward(audio.mix);
    else fft.forward(player.mix);
  }
  
  public float getAmplitudeForBand(int band) {
     int lowFreq;
    if ( band == 0 ) { lowFreq = 0; } 
    else { lowFreq = (int)((sampleRate/2) / (float)Math.pow(2, 12 - band)); }
    int hiFreq = (int)((sampleRate/2) / (float)Math.pow(2, 11 - band));

    // we're asking for the index of lowFreq & hiFreq
    int lowBound = fft.freqToIndex(lowFreq); // freqToIndex returns the index of the frequency band that contains the requested frequency
    int hiBound = fft.freqToIndex(hiFreq); 
    
    // calculate the average amplitude of the frequency band
    float avg = fft.calcAvg(lowBound, hiBound);
    return avg;
  }
}

public class CartesianPattern extends Pattern {
  int dimension = 500;
  float maxRadius = sqrt(2 * dimension * dimension);
  PGraphics image = createGraphics(dimension, dimension);
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

  public void scrapeImage(PImage img, Strip[] strips) {
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        CanopyCoord co = mapToCanopy(x,y);
        // the center of the cartesian plane doesn't play well with canopy coords
        int l = co.led - 10; 
        if (l < 0 || l >= NUM_LEDS_PER_STRIP) {
          continue;
        }
        color c = img.get(x,y);
        if (c == color(0) || c == 0) { continue; }
        strips[co.strip].leds[l] = c;

      }
    }
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
  private AudioInput input;
  
  BeatListener(BeatDetect beat) {
    if (listeningToMic) {
      this.input = audio;
      this.input.addListener(this);
      this.beat = beat;
    } else 
    {
      this.source = player;
      this.source.addListener(this);
      this.beat = beat;
    }
  }

  synchronized void samples(float[] samps)
  {
    if (listeningToMic) { 
      beat.detect(audio.mix);
    }
    else {
      checkSource();
      beat.detect(source.mix);
    }
  }

  synchronized void samples(float[] sampsL, float[] sampsR)
  {
    if (listeningToMic) { //<>//
      beat.detect(audio.mix);
    }
    else { 
      checkSource();
      beat.detect(source.mix);
    }
  }
  
  synchronized void checkSource() {
    if (!listeningToMic && this.source == null) {
      this.source = player;
      this.source.addListener(this);
    }
  }
}