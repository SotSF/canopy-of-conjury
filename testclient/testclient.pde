import processing.net.*;
/* A dummy client acting as a stand in Kinect sketch */
/* It's sending random commands to the Canopy Conjurer */
Client client;
int tick = 0;
int dimension = 500; // canopy canvas dimension
void setup() {
  size(500,500);
  client = new Client(this, "127.0.0.1", 5111);
}

void draw() {
  if (tick % 100 == 0) {
     String action = random(100) > 50 ? "CLAP" : "TEST";
     //String data = "{ \"x\":"+ int(random(500)) + ",\"y\":" + int(random(500)) + ", \"action\":" + action + "}";
     //String action = "VECTOR";
     float x = random(-200,200);
     float y = -200;
     float z = random(-200,200);
     float v1 = random(-2,2);
     float v2 = random(0,5);
     float v3 = random(-2,2);
     String data = String.format("{\"origin\" : \"(%f,%f,%f)\"," +
                                   "\"vector\" : \"(%f,%f,%f)\"," +
                                   "\"action\" : \" %s \"" +
                                   "}",x,y,z,v1,v2,v3,action);
     client.write(data); // send data to 127.0.0.1:5111
    
  }
  tick++;
}