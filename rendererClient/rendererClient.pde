import processing.net.*;
boolean testing = true;
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
 clear();
 if (testing) {
   render.command = PatternSelect.WISP;
   render.run();
 }
 else {
   if (tick % 3 == 0){ 
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
  String cmd = client.readStringUntil('\n'); //read until newline char
  if (cmd != null) {
    parseCmd(cmd);
  }
}

void parseCmd(String cmd) {
  println(cmd);
  switch (cmd.trim()) {
    case "TEST":
      render.command = PatternSelect.WISP; break; 
  }
}

class Renderer {
  PatternSelect command;
  PatternWillOWisp wisp = new PatternWillOWisp();
  void run() {
    if (command != null) { 
      switch(command) {
        case EMPTY:
          break;
        case WISP:
          if (wisp.timer >= 100) { wisp.reset(); }
          break;
      }
    }

    wisp.run(); 
    command = PatternSelect.EMPTY;
  }
}