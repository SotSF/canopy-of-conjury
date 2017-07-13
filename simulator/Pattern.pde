public interface Pattern {
  void run(Strip[] strips);
}

public class CartesianPattern {
  int dimension = 150;
  color[][] pixelWindow = new color[dimension][dimension]; // for writing in 2D, to convert to Polar/3D
  float maxRadius = sqrt(pixelWindow[0].length * pixelWindow[0].length + pixelWindow.length * pixelWindow.length);
  
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
    int s = floor(thetaDegrees * numStrips / 360);
    int l = floor(radius);
    return new CanopyCoord(s, l);
    
  }
  
  public void scrapeWindow(Strip[] strips) {
    clearStrips();
    for (int y = 0; y < pixelWindow.length; y++) {
      for (int x = 0; x < pixelWindow[y].length; x++) {
        CanopyCoord co = mapToCanopy(x,y);
        if (co.led >= numLedsPerStrip) {
          continue;
        }
        strips[co.strip].leds[co.led] = pixelWindow[y][x];
      }
    }
    
    // the Cartesian doesn't map neatly to Canopy coords in the center
    // grab the nearest neighbor
    for (int s = numStrips - 1; s >= 0; s--) {
      for (int l = 20; l >= 0; l--) {
         int l1 = l + 1 >= numLedsPerStrip ? l - 1 : l + 1;
         strips[s].leds[l] = strips[s].leds[l1];
      
      }
    }
  }
  
  public void clearWindow() {
    for (int y = 0; y < pixelWindow.length; y++) {
      for (int x = 0; x < pixelWindow[y].length; x++) {
        pixelWindow[y][x] = 0;
      }
    }
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