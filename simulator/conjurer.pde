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
          burst.addBurst(command.x, command.y);
          break;
        case "WAVE":
          rainbowRing.addRing();
          break;
        case "TEST":
          renderServer.write("TEST\n");
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
  int x;
  int y;
  String action;
  public Command(int x, int y, String action) {
    this.x = x;
    this.y = y;
    this.action = action;
  }
}

void parseCmd(String cmd) {
    println(cmd);
    JSONObject json = parseJSONObject(cmd);
    int x = json.getInt("x");
    int y = json.getInt("y");
    String action = json.getString("action");
    conjurer.command = new Command(x,y,action);
}



public class JPGEncoder {
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