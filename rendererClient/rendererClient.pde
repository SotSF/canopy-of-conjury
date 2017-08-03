/* TODO : there's some transformations we need to account for before sending the image to the Canopy */

import processing.net.*;
boolean testing = false;
final int dimension = 500;
Client client;
Renderer render;
int tick = 0;
void setup() {
  noSmooth();
  if (!testing) client = new Client(this, "127.0.0.1", 5024);
  size(500, 500);
  background(color(0));
  render = new Renderer();
}

void draw() {
    if (tick % 3 == 0){ 
     clear();
     if (testing) {
       if (random(100) > 50) { render.pattern = PatternSelect.WISP; }
       render.run();
     }
     else {
       render.run();
       sendImg();
     }
  }
  tick++;
}

JPGEncoder jpg = new JPGEncoder();
void sendImg() {
  PImage img = get(0, 0, dimension, dimension);
  try { 
    byte[] encoded = jpg.encode(img);
    client.write(encoded);
  }
  catch (IOException e) {
  }
}

// TODO receive additional kinect info, e.g. trails, coordinates, etc.
void clientEvent(Client client) {
  String cmdString = client.readStringUntil('\n');
  if (cmdString != null) {
    parseCmd(cmdString);
  }
}

void parseCmd(String cmd) {
    println(cmd);
    JSONObject json = parseJSONObject(cmd);
    String origin = json.getString("origin").trim(); // (x,y,z)
    String[] oCoords = origin.substring(1,origin.length() - 1).split(",");
    Point o = new Point(float(oCoords[0]), float(oCoords[1]), float(oCoords[2]));
    String vector = json.getString("vector").trim(); // (v1,v2,v3);
    String[] vCoords = vector.substring(1,vector.length() - 1).split(",");
    Point v = new Point(float(vCoords[0]), float(vCoords[1]), float(vCoords[2]));
    String action = json.getString("action").trim();
    
    render.setCommand(new Command(o,v,action));
 }


class Renderer {
  Command command;
  PatternSelect pattern;
  PatternWillOWisp wisp = new PatternWillOWisp();
  void run() {
    if (pattern != null) { 
      switch(pattern) {
        case EMPTY:
          break;
        case WISP:
          wisp.addWisp(random(dimension), random(dimension), random(dimension), random(dimension));
          break;
      }
    }

    wisp.run(); 
    pattern = PatternSelect.EMPTY;
  }
  
  void setCommand(Command cmd) {
    this.command = cmd;
    switch (cmd.action) {
      case "TEST":
        this.pattern = PatternSelect.WISP; break;
    }
  }
}

class Command {
  Point origin;
  Point vector;
  String action;
  public Command(Point origin, Point vector, String action) {
    this.origin = origin;
    this.vector = vector;
    this.action = action;
  }
}

/* drawing in 2D - the z-coord can be used to control alpha values to give an illusion of depth */
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