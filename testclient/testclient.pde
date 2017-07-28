import processing.net.*;
/* a dummy client to stand in place of the Kinect sketch for testing purposes */
Client thisClient;
int tick = 0;

void setup() {
  size(200,200);
  thisClient = new Client(this, "127.0.0.1", 5111);
}

void draw() {
  if (tick % 100 == 0) {
     String action = random(100) > 50 ? "CLAP" : "WAVE";
     if (random(100) > 75) action = "TEST";
     String data = "{ \"x\":"+ int(random(500)) + ",\"y\":" + int(random(500)) + ", \"action\":" + action + "}";
     thisClient.write(data);
    
  }
  tick++;
}