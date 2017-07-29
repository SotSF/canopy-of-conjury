import controlP5.*;
import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import gifAnimation.*;
import processing.video.*;
import processing.net.*;

PeasyCam camera;

// == AUDIO VISUALIZER ===
Minim minim;
AudioInput audio; 
AudioPlayer player;
BeatDetect beat;
FFT fft;

Movie movie;

Server kinectServer;
Server renderServer;

// Constants
float FEET_PER_METER = 3.28084;
int TOTAL_LEDS = 7200;
int BASE_RADIUS_FEET = 8;
float STRIP_LENGTH_METERS = 2.5;
float STRIP_LENGTH_FEET = STRIP_LENGTH_METERS * FEET_PER_METER;
float APEX_RADIUS_FEET = 0.5;
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

int tick = 0;
GUI gui;
PMatrix3D currCameraMatrix;
PGraphics3D g3;

void setup() {
  kinectServer = new Server(this, 5111);
  renderServer = new Server(this, 5024);
  minim = new Minim(this);
  audio = minim.getLineIn(Minim.STEREO, 1024, 192000.0);
  for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i] = new Strip(new color[NUM_LEDS_PER_STRIP]);
  }
  size(750, 750, P3D);
  camera = new PeasyCam(this, 0, 0, 0, BASE_DIAMETER * 2);
  gui = new GUI(this);
  g3 = (PGraphics3D)g;
  getCatenaryCoords();
  conjurer = new Conjurer(this);   
  pattern = new EmptyPattern();
}

JPGEncoder jpg = new JPGEncoder();

void draw() {
  clearStrips();
  if (conjurer.mode == MODE_LISTENING) {
    if (kinectServer != null) {
      Client client = kinectServer.available();
      if (client != null) {
        String cmd = client.readString();
        parseCmd(cmd);
      }
    }
    if (renderServer != null) {
      Client client = renderServer.available();
      if (client != null) {
        byte[] byteBuffer = client.readBytes();
        try {
          PImage img = jpg.decode(byteBuffer);
          conjurer.paint(img);
        } 
        catch (Exception e) {
        }
      }
    }
  }
  switch (conjurer.mode) {
    case MODE_MANUAL: 
      if (isFadingOut){ fadeStrips(); }
      else { pattern.run(ledstrips); }
      break;
    case MODE_LISTENING: 
      conjurer.cast();
      break;
  }
  
 
  /** TODO: push from ledstrips to PixelPusher strips - this will require some math
  * Which of the two PixelPushers (0-47 will be on PP1, 48-95 will be on PP2)
  * Which of the 8 outputs, and then which of the LEDs on that output correspond to the LED we're targeting.
  * Each output will have 450 LEDs, using out (from apex)-in-out-in-out-in configuration, 
  * making 6 out of 96 of our strips per output.
  */

  rotateZ(PI);
  renderCanopy();
  tick++;
  gui.run();
}


void renderCanopy() {
  background(50);
  
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
    float[] coord = catenaryCoords[j];
    pushMatrix();
    translate(coord[0], coord[1]);
    fill(s.leds[j]);
    stroke(s.leds[j]);
    box(1,1,1);
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
  
  public void clear() {
    for (int i = 0; i < leds.length; i++) {
      leds[i] = color(0);
    }
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