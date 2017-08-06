/*
* Conjurer class has a bank of patterns it can pull from that
* will correspond to a user's action. When the Conjurer is idling
* it can direct the global IPattern, looping through static patterns.
*
* Commands are received in the simulator.draw() method as a string, 
* and then sent to parseCmd(), which then passes a Command to the Conjurer.
*
* The Conjurer can also receive PImages, passed to the Canopy from a 
* Renderer client sketch. These images are added to the Canopy via the
* ConjurerCanvas.
*/
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;


final int MODE_MANUAL = 0;
final int MODE_LISTENING = 1; //listening for commands from Kinect

class Conjurer {
  int mode = 0; // 0 = manual, 1 = kinect
  PImage drawing;
  int drawingTimer = 0;
  String cmdString;
  Command command;
  PatternBurst burst;
  PatternRainbowRings rainbowRing;
  ConjurerCanvas canvas;
  public Conjurer(PApplet window) {
    burst = new PatternBurst(window);
    rainbowRing = new PatternRainbowRings();
    canvas = new ConjurerCanvas();
  }
  public void sendCommand(Command cmd) {
    this.command = cmd;
  }
  
  public void castOFF() {
    canvas.run(ledstrips);
  }
  
  public void cast() {
    if (this.command != null) {
      switch (command.action) {
        case "CLAP":
          burst.addBurst(command.origin,command.vector);
          break;
        case "WAVE":
          rainbowRing.addRing();
          break;
        case "TEST":
          renderServer.write(cmdString + "\n");
          break;
        case "VECTOR":
          //lightPath.addPath(command.origin, command.vector);
          break;
      }
      this.command = null;
    }
    burst.run(ledstrips);
    rainbowRing.run(ledstrips);
    canvas.run(ledstrips);
  }
  
  public void paint(PImage img) {
    if (img != null) canvas.drawing = img;
  }
}

class ConjurerCanvas extends CartesianPattern {
  PImage drawing;
  public void run(Strip[] strips) {
    clearWindow();
    if (drawing != null) {
      scrapeImage(drawing, strips);
    }   
  }
}

class Command {
  Point origin;
  Point vector;
  String action;
  Command(Point origin, Point vector, String action) {
    this.origin = origin;
    this.vector = vector;
    this.action = action;
  }
}

// describe a point in R3, for interfacing the the Kinect
class Point {
  float x;
  float y;
  float z;
  Point(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

/* Given the Canopy coordinates by strip and LED position, determine coordinate in R3 */
Point transformReal(int s, int l) {
  float angle = s * (2 * PI) / NUM_STRIPS;
  float x = cos(angle) * catenaryCoords[l][0] + sin(angle) * 0;
  float y = catenaryCoords[l][1];
  float z = -sin(angle) * catenaryCoords[l][0] + cos(angle) * 0;
  return new Point(x,y,z);
}

void parseCmd(String cmd) {
    println(cmd);
    JSONObject json = parseJSONObject(cmd);
    String origin = json.getString("origin").trim(); // x,y,z
    String[] oCoords = origin.split(",");
    Point o = new Point(float(oCoords[0]), float(oCoords[1]), float(oCoords[2]));
    String vector = json.getString("vector").trim(); // (v1,v2,v3);
    String[] vCoords = vector.split(",");
    Point v = new Point(float(vCoords[0]), float(vCoords[1]), float(vCoords[2]));
    String action = json.getString("action").trim();
    conjurer.cmdString = cmd;
    conjurer.command = new Command(o,v,action);
}



class JPGEncoder {
  byte[] encode(PImage img) throws IOException {
    ByteArrayOutputStream imgbaso = new ByteArrayOutputStream();
    ImageIO.write((BufferedImage) img.getNative(), "jpg", imgbaso);

    return imgbaso.toByteArray();
  }

  PImage decode(byte[] imgbytes) throws IOException {
    BufferedImage imgbuf = ImageIO.read(new ByteArrayInputStream(imgbytes));
    PImage img = new PImage(imgbuf.getWidth(), imgbuf.getHeight(), RGB);
    imgbuf.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();
    return img; 
  }

}
