import processing.net.*;


final int dimension = 500;
Client client;
Renderer render;
int tick = 0;
void setup() {
  noSmooth();
  client = new Client(this, "127.0.0.1", 5024);
  size(500, 500);
  background(color(0));
  render = new Renderer();
}

void draw() {
  if (tick % 5 == 0) {
    if (render.isDrawing) {
      render.pattern.run();
    }
    sendImg();
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

void clientEvent(Client client) {
  String cmd = client.readStringUntil('\n'); //read until newline char
  if (cmd != null) {
    parseCmd(cmd);
  }
}

void parseCmd(String cmd) {
  println(cmd);
  // TODO : SWITCH (CMD)
  if (render.pattern == null) {
    render.pattern = new Pattern();
    render.isDrawing = true;
  }
  
}

class Renderer {
  boolean isDrawing = false;
  Pattern pattern;
}