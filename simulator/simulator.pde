import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

PeasyCam camera;

// == AUDIO VISUALIZER ===
Minim minim;
AudioInput audio; 
AudioPlayer player;
BeatDetect beat;
FFT fft;

// Constants
float FEET_PER_METER = 3.28084;
int TOTAL_LEDS = 7200;

int numStrips = 96;
int numLedsPerStrip = TOTAL_LEDS / numStrips;
float stripLengthMeters = 2.5;
float stripLengthFeet = stripLengthMeters * FEET_PER_METER;
float apexRadiusFeet = 0.5;

// Height is configurable
float hFeet = 3;
float rFeet = deriveBaseWidth();

int scaleFactor = 30;
float r = rFeet * scaleFactor;
float h = hFeet * scaleFactor;
float apexR = apexRadiusFeet * scaleFactor;

float d = r * 2;
float apexD = apexR * 2;

/**
 * Derives the width of the large circle based on trapezoidal geometry
 */
float deriveBaseWidth() {
  float theta = asin(hFeet / stripLengthFeet);
  float semiBaseWidth = stripLengthFeet * cos(theta);
  float stripSlope = hFeet / semiBaseWidth;
  float heightAdded = stripSlope * apexRadiusFeet;
  return apexRadiusFeet * ((hFeet / heightAdded) + 1);
}

Strip[] ledstrips = new Strip[numStrips];
Pattern pattern;

int tick = 0;

void setup() {
  minim = new Minim(this);
  for (int i = 0; i < numStrips; i++) {
    ledstrips[i] = new Strip(new color[numLedsPerStrip]);
  }
  size(750, 750, P3D);
  camera = new PeasyCam(this, 0, 0, 0, d * 2);
  
  /* implements Pattern */
  //pattern = new PatternSwirly(color(255,0,0), 500, 0, false);
  //pattern = new PatternPulseMulti(20, color(255,100,10));
  
  /* extends CartesianPattern implements Pattern */
  //pattern = new PatternRainbowScan();
  //pattern = new PatternHeartPulse(0.03, -0.03, 3.5, 0.25);
  
  /* audio visualizer */
  //pattern = new PatternAV("./audio/bloom.mp3");
  
  /* extends PatternAV */
  //pattern = new PatternAVIntersection("./audio/bloom.mp3");
  pattern = new PatternAVRainbowPulsar("./audio/bloom.mp3");
}

void draw() {
  pattern.run(ledstrips);
  /** TODO: push from ledstrips to PixelPusher strips - this will require some math
  * Which of the two PixelPushers (0-47 will be on PP1, 48-95 will be on PP2)
  * Which of the 8 outputs, and then which of the LEDs on that output correspond to the LED we're targeting.
  * Each output will have 450 LEDs, using out (from apex)-in-out-in-out-in configuration, 
  * making 6 out of 96 of our strips per output.
  */
  renderCanopy();
  tick++;
}


void renderCanopy() {
  background(50);
  
  // Large circle
  pushMatrix();
  translate(0, -h);
  rotateX(PI/2);
  stroke(255);
  noFill();
  ellipse(0, 0, d, d);
  popMatrix();
  
  // Small circle
  pushMatrix();
  rotateX(PI/2);
  stroke(255);
  noFill();
  ellipse(0, 0, apexD, apexD);
  popMatrix();
  
  // Render the strips
  for (int i = 0; i < numStrips; i++) {
    renderStrip(i);
  }
}

void renderStrip(int i) {
  Strip s = ledstrips[i]; // this has all of our colors
  float angle = i * (2 * PI) / numStrips;
  
  pushMatrix();
  rotateY(angle);
  float xSmall = apexR;
  float ySmall = 0;
  float zSmall = 0;
  float xLarge = r;
  float yLarge = -h;
  float zLarge = 0;
  
  stroke(50);
  line(xSmall, ySmall, zSmall, xLarge, yLarge, zLarge);
  
  /**
   * Draw the LEDs
   */
  for (int j = 0; j < numLedsPerStrip; j++) {
    // Interpolate them equally along the length of the strip
    float xLed = xSmall + (xLarge - xSmall) * j / numLedsPerStrip;
    float yLed = ySmall + (yLarge - ySmall) * j / numLedsPerStrip;
    float zLed = zSmall + (zLarge - zSmall) * j / numLedsPerStrip;
    pushMatrix();
    translate(xLed, yLed, zLed);
    fill(s.leds[j]);
    stroke(s.leds[j]);
    box(1,1,1);
    popMatrix();
  }
  
  popMatrix();
}

void clearStrips() {
  for (int i = 0; i < numStrips; i++) {
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