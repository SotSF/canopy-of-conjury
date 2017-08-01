import processing.net.*;
/* A dummy client acting as a stand in Kinect sketch */
/* It's sending random commands to the Canopy Conjurer */
Client client;
int tick = 0;

void setup() {
  size(200,200);
  client = new Client(this, "127.0.0.1", 5111);
}

void draw() {
  if (tick % 100 == 0) {
     String action = random(100) > 50 ? "CLAP" : "WAVE";
     if (random(100) > 75) action = "TEST";
     String data = "{ \"x\":"+ int(random(500)) + ",\"y\":" + int(random(500)) + ", \"action\":" + action + "}";
     client.write(data); // send data to 127.0.0.1:5111
    
  }
  tick++;
}