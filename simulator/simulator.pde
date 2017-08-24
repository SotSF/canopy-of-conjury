import controlP5.*;
import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import gifAnimation.*;
import processing.video.*;
import processing.net.*;

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

// == AUDIO VISUALIZER ===
Minim minim;
AudioInput audio;
AudioPlayer player;
BeatDetect beat;
FFT fft;

Movie movie;

Server kinectServer;

TestObserver observer;
DeviceRegistry registry;

// Constants
float FEET_PER_METER = 3.28084;
int TOTAL_LEDS = 7200;
int BASE_RADIUS_FEET = 8;
float STRIP_LENGTH_METERS = 2.5;
float STRIP_LENGTH_FEET = STRIP_LENGTH_METERS * FEET_PER_METER;
float APEX_RADIUS_FEET = 1;
float MAX_HEIGHT_FEET = sqrt(pow(STRIP_LENGTH_FEET, 2) - pow(BASE_RADIUS_FEET - APEX_RADIUS_FEET, 2));

int NUM_STRIPS = 96;
int NUM_LEDS_PER_STRIP = TOTAL_LEDS / NUM_STRIPS;

// Initialize the height
int scaleFactor = 30;
float BASE_RADIUS = BASE_RADIUS_FEET * scaleFactor;
float h = MAX_HEIGHT_FEET * scaleFactor;
float APEX_RADIUS = APEX_RADIUS_FEET * scaleFactor;

float BASE_DIAMETER = BASE_RADIUS * 2;
float APEX_DIAMETER = APEX_RADIUS * 2;

float[][] catenaryCoords = new float[NUM_LEDS_PER_STRIP][2];

Strip[] ledstrips = new Strip[NUM_STRIPS];

Conjurer conjurer;
IPattern pattern;

final int backgroundColor = 50;
int tick = 0;
GUI gui;
PMatrix3D currCameraMatrix;
PGraphics3D g3;
Transforms transforms;

// == CAMERA STATE ===
PeasyCam camera;
final float CAMERA_INITIAL_DISTANCE = BASE_DIAMETER * 1.1;

void setup() {
  registry = new DeviceRegistry();
  observer = new TestObserver();
  registry.addObserver(observer);
  delay(500);
  kinectServer = new Server(this, 5111);
  minim = new Minim(this);
  audio = minim.getLineIn(Minim.STEREO, 1024, 192000.0);
  for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i] = new Strip(new color[NUM_LEDS_PER_STRIP]);
  }
  size(750, 750, P3D);
  camera = new PeasyCam(this, CAMERA_INITIAL_DISTANCE);
  gui = new GUI(this);
  g3 = (PGraphics3D)g;
  getCatenaryCoords();
  conjurer = new Conjurer(this);
  pattern = new EmptyPattern();
  transforms = new Transforms();
}

void draw() {
  if (conjurer.mode == MODE_LISTENING) {
    if (kinectServer != null) {
      Client client = kinectServer.available();
      if (client != null) {
        String cmd = client.readString();
        parseCmd(cmd);
      }
    }
  }
  switch (conjurer.mode) {
    case MODE_MANUAL:
      if (isFadingOut) { 
        fadeStrips();
      } else {  
        clearStrips(); 
        pattern.run(ledstrips);
      }
      break;
    case MODE_LISTENING:
      clearStrips();
      conjurer.cast();
      break;
    }
  
  background(backgroundColor);
  rotateZ(PI);

  // DEMO ONLY
  if (selectedPattern == PatternSelect.BURST) {
    for (PatternBurst.Burst b : ((PatternBurst)pattern).targets) {
      pushMatrix();
      translate(b.origin.x, b.origin.y, b.origin.z);
      noStroke();
      fill(255);
      sphere(5);
      stroke(color(255, 0, 255));
      line(0, 0, 0, b.vector.x * 500, b.vector.y * 500, b.vector.z * 500);
      popMatrix();
    }
  }

  transforms.apply(ledstrips);

  // Render to screen
  renderCanopy();
  gui.run();

  tick++; //<>//

  // Push to PixelPushers
  push();
}

void push() {
  if (!observer.hasStrips) { return; }
  registry.startPushing();
  
  // get the triple-zigs from the pixel pushers
  List<com.heroicrobot.dropbit.devices.pixelpusher.Strip> tripleZigs = registry.getStrips();
  
  // should be 8 triple zigs, each having out-in-out-in-out-in
  for (int i = 0; i < tripleZigs.size(); i++) {
    com.heroicrobot.dropbit.devices.pixelpusher.Strip tripleZig = tripleZigs.get(i);
    
    // should be 450 total LEDs in 1 triple zig (75 * 6)
    for (int l = 0; l < tripleZig.getLength(); l++) {
      int strip = floor(l / NUM_LEDS_PER_STRIP); // which strip on the triple zig
      int led = l - (NUM_LEDS_PER_STRIP * strip);
      if (strip % 2 != 0) { // we have an INNIE strip, go backwards
        led = NUM_LEDS_PER_STRIP - led - 1;
      }
      strip += 6 * i; // which strip in simulator ledstrips
      //if (i >= 8) strip += NUM_STRIPS / 2;
      tripleZig.setPixel(ledstrips[strip].leds[led], l);
    }
  }
}

void renderCanopy() {
  // axes - blue x, red y, green z
  stroke(color(0, 0, 255));
  line(-500, 0, 0, 500, 0, 0);
  stroke(color(255, 0, 0));
  line(0, -500, 0, 0, 500, 0);
  stroke(color(0, 255, 0));
  line(0, 0, -500, 0, 0, 500);
   for (int x = -10; x <= 10; x++) {
    stroke(color(0, 0, 255));
    line(x * scaleFactor, 0, -10, x * scaleFactor, 0, 10);
    stroke(color(255,0,0));  
    line(-10, x * scaleFactor, 0, 10, x * scaleFactor, 0);
    stroke(0,255,0);
    line(-10, 0, x * scaleFactor, 10, 0, x * scaleFactor);
  }
  
  // Large circle
  pushMatrix();
  rotateX(PI/2);
  stroke(255);
  noFill();
  ellipse(0, 0, BASE_DIAMETER, BASE_DIAMETER);
  popMatrix();

  // Small circle
  pushMatrix();
  translate(0, -h);
  rotateX(PI/2);
  stroke(255);
  noFill();
  ellipse(0, 0, APEX_DIAMETER, APEX_DIAMETER);
  popMatrix();

  // Render the strips
  for (int i = 0; i < NUM_STRIPS; i++) {
    renderStrip(i);
  }
}



void renderStrip(int i) {
  Strip s = ledstrips[i]; // this has all of our colors
  float angle = i * (2 * PI) / NUM_STRIPS;

  pushMatrix();
  rotateY(angle);

  // Draw the cord holding the LEDs
  int j;
  noFill();
  stroke(100);
  beginShape();
  for (j = 0; j < catenaryCoords.length; j++) {
    float[] coord = catenaryCoords[j];
    curveVertex(coord[0], coord[1]);
  }
  endShape();

  // Draw the LEDs
  for (j = 0; j < catenaryCoords.length; j++) {
    float[] coord = catenaryCoords[j]; //(x,y,0)
    pushMatrix();
    translate(coord[0], coord[1]);
    fill(s.leds[j]);
    stroke(s.leds[j]);
    box(1, 1, 1);
    popMatrix();
  }
  popMatrix();
}

void clearStrips() {
  for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i].clear();
  }
}

class Strip {
  color[] leds;
  public Strip(color[] leds) {
    this.leds = leds;
  }

  // Clones another strip
  public Strip(Strip otherStrip) {
    leds = new color[otherStrip.length()];
    for (int i = 0; i < otherStrip.length(); i++) {
      color otherStripLed = otherStrip.leds[i];
      leds[i] = color(otherStripLed);
    }
  }

  public void clear() {
    for (int i = 0; i < leds.length; i++) {
      leds[i] = color(0);
    }
  }

  public int length () {
    return leds.length;
  }
}

void keyPressed () {
  if (key == CODED) {
    if (keyCode == UP) {
      adjustApexHeight(-0.2);
    } else if (keyCode == DOWN) {
      adjustApexHeight(0.2);
    }
  }

  // camera manipulation shortcuts
  switch (key) {
    case 'B':
      camera.reset(0);
      camera.rotateX(-PI / 2);
      break;
    case 'T':
      camera.reset(0);
      camera.rotateX(PI / 2);
      break;
  }

  pattern.onKeyPressed();
}


/******************************************************************************
 * MOUSE EVENTS
 *****************************************************************************/
void mousePressed () {
  pattern.onMousePressed();
}

void mouseReleased () {
  pattern.onMouseReleased();
}

void mouseClicked () {
  pattern.onMouseClicked();
}

void mouseDragged () {
  pattern.onMouseDragged();
}


void adjustApexHeight (float deltaHeightFeet) {
  float newHeight = h + deltaHeightFeet * scaleFactor;
  if (abs(newHeight) > MAX_HEIGHT_FEET * scaleFactor) {
    newHeight = (newHeight > 0 ? MAX_HEIGHT_FEET : -MAX_HEIGHT_FEET) * scaleFactor;
  }

  // Update the height and coordinates
  h = newHeight;
  getCatenaryCoords();
}

/**
 * Updates the coordinates for the catenaries. Note that we downscale by `scaleFactor`
 * in order for the `catenary` function to be able to compute the catenary. For whatever
 * reason it can't handle larger inputs and totally barfs if you pass it the scaled
 * coordinates.
 */
void getCatenaryCoords () {
  float[] apexCoord = { APEX_RADIUS / scaleFactor, -h / scaleFactor };
  float[] baseCoord = { BASE_RADIUS / scaleFactor, 0 };
  float[][] newCoords = catenary(baseCoord, apexCoord, STRIP_LENGTH_FEET, NUM_LEDS_PER_STRIP);

  for (int i = 0; i < newCoords.length; i++) {
    catenaryCoords[i][0] = newCoords[i][0] * scaleFactor;
    catenaryCoords[i][1] = newCoords[i][1] * scaleFactor;
  }
}

class TestObserver implements Observer {
  public boolean hasStrips = false;
    public void update(Observable registry, Object updatedDevice) {
      this.hasStrips = true;
    }
}