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
     String action = "TRACE";
     //String data = "{ \"x\":"+ int(random(500)) + ",\"y\":" + int(random(500)) + ", \"action\":" + action + "}";
     //String action = "VECTOR";
     float x = random(0,500);
     float y = random(0,500);
     float z = 0;
     float x1 = random(0,500);
     float y1 = random(0,500);
     float z1 = 0;
     float v1 = random(-2,2);
     float v2 = random(0,5);
     float v3 = random(-2,2);
     String data = String.format("{\"origin\" : \"(%f,%f,%f)\"," +
                                   "\"destination\" : \"(%f,%f,%f)\"," +
                                   "\"vector\" : \"(%f,%f,%f)\"," +
                                   "\"action\" : \" %s \"" +
                                   "}",x,y,z,x1,y1,z1,v1,v2,v3,action);
     client.write(data); // send data to 127.0.0.1:5111
    
  }
  tick++;
}