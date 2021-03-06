/*
* Conjurer class has a bank of patterns it can pull from that
* will correspond to a user's action. When the Conjurer is idling
* it can direct the global IPattern, looping through static patterns.
*
* Commands are received in the simulator.draw() method as a string,
* and then sent to parseCmd(), which then passes a Command to the Conjurer.
*/

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
  PatternRainbowWaves rainbowWave;
  public Conjurer(PApplet window) {
    burst = new PatternBurst(window);
    rainbowRing = new PatternRainbowRings();
    rainbowWave = new PatternRainbowWaves();
  }
  public void sendCommand(Command cmd) {
    this.command = cmd;
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
        case "TRACE":
          rainbowWave.addWave(command.origin,command.destination);
          break;

      }
      this.command = null;
    }
    burst.run(ledstrips);
    rainbowRing.run(ledstrips);
    rainbowWave.run(ledstrips);
  }

  public void clean() {
    burst.targets.clear();
    rainbowRing.lightTracks.clear();
    rainbowWave.waves.clear();
  }

}


class Command {
  PVector origin;
  PVector destination;
  PVector vector;
  String action;
  Command(PVector origin, PVector destination, PVector vector, String action) {
    this.origin = origin;
    this.destination = destination;
    this.vector = vector;
    this.action = action;
  }
}

/* Given the Canopy coordinates by strip and LED position, determine coordinate in R3 */
PVector transformReal(int s, int l) {
  float angle = s * (2 * PI) / NUM_STRIPS;
  float x = cos(angle) * catenaryCoords[l][0] + sin(angle) * 0;
  float y = catenaryCoords[l][1];
  float z = -sin(angle) * catenaryCoords[l][0] + cos(angle) * 0;
  return new PVector(x,y,z);
}

void parseCmd(String cmd) {
    println(cmd);
    JSONObject json = parseJSONObject(cmd);
    String origin = json.getString("origin").trim(); // (x,y,z)
    String[] oCoords = origin.substring(1,origin.length() - 1).split(",");
    PVector o = new PVector(float(oCoords[0]), float(oCoords[1]), float(oCoords[2]));
    String destination = json.getString("destination").trim(); // (x,y,z)
    String[] dCoords = destination.substring(1,destination.length() - 1).split(",");
    PVector d = new PVector(float(dCoords[0]), float(dCoords[1]), float(dCoords[2]));
    String vector = json.getString("vector").trim(); // (v1,v2,v3);
    String[] vCoords = vector.substring(1,vector.length() - 1).split(",");
    PVector v = new PVector(float(vCoords[0]), float(vCoords[1]), float(vCoords[2]));
    String action = json.getString("action").trim();
    conjurer.cmdString = cmd;
    conjurer.command = new Command(o,d,v,action);
}
