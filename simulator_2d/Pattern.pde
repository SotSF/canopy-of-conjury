public interface Pattern {
  void run(Strip[] strips);
}

public class CartesianPattern {
  int dimension = dispWidth;
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
    // CONVERT TO CANOPY LAYOUT which is ass backwards
    thetaDegrees = (thetaDegrees + -90);
    if (thetaDegrees < 0) { thetaDegrees += 360; }
    int s = floor(thetaDegrees * NUM_STRIPS / 360);
    int l = floor(radius);
    return new CanopyCoord(s, l);
    
  }
  
  public void scrapeWindow(Strip[] strips) {
    clearStrips();
    for (int y = 0; y < dimension; y++) {
      for (int x = 0; x < dimension; x++) {
        CanopyCoord co = mapToCanopy(x,y);
        // the center of the cartesian plane doesn't play well with canopy coords
        int l = co.led - 20; 
        if (l < 0 || l >= NUM_LEDS_PER_STRIP) {
          continue;
        }
        if (get(x,y) != color(0)) {
          strips[co.strip].leds[l] = get(x,y);
        }
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