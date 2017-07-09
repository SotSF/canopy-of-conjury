
import peasy.*;

PeasyCam camera;

// Constants
float FEET_PER_METER = 3.28084;
int TOTAL_LEDS = 7200;

int numStrips = 96;
int numLedsPerStrip = TOTAL_LEDS / numStrips;
int stripLengthMeters = 5;
float stripLengthFeet = stripLengthMeters * FEET_PER_METER;
float apexRadiusFeet = 0.5;

// Height is configurable
float hFeet = 3;
float rFeet = deriveBaseWidth();

int scaleFactor = 20;
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

void setup() {
  size(500, 500, P3D);
  camera = new PeasyCam(this, 0, 0, 0, d * 2);
  print(rFeet);
}

void draw() {
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
  float angle = i * (2 * PI) / numStrips;
  float xSmall = apexR * sin(angle);
  float ySmall = 0;
  float zSmall = apexR * cos(angle);
  float xLarge = r * sin(angle);
  float yLarge = -h;
  float zLarge = r * cos(angle);
  
  line(xSmall, ySmall, zSmall, xLarge, yLarge, zLarge);
  
  /**
   * Draw the LEDs -- this is currently WAY too slow. Methinks rendering 7200
   * spheres slows things down too much. Need to look into a workaround...
   *
   * for (int j = 0; j < numLedsPerStrip; j++) {
   *   // Interpolate them equally along the length of the strip
   *   float xLed = (xLarge - xSmall) * j / numLedsPerStrip;
   *   float yLed = (yLarge - ySmall) * j / numLedsPerStrip;
   *   float zLed = (zLarge - zSmall) * j / numLedsPerStrip;
   * 
   *   pushMatrix();
   *   translate(xLed, yLed, zLed);
   *   stroke(255 / 75 * j);
   *   sphere(2);
   *   popMatrix();
   * }
   */
}