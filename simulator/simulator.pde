
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

Strip[] ledstrips = new Strip[numStrips];

void setup() {
  for (int i = 0; i < numStrips; i++) {
    ledstrips[i] = new Strip(new color[numLedsPerStrip]);
  }
  size(500, 500, P3D);
  camera = new PeasyCam(this, 0, 0, 0, d * 2);
  print(rFeet);
  
}

int count = 0;
int row = 0;
void draw() {
  // ====== PATTERN DRAWING GOES HERE =======
  clearStrips();
  for (int i = 0; i < 96; i++) {
    ledstrips[i].leds[row] = color(255,0,0);
  }
  row++;
  if (row >= numLedsPerStrip) {
    row = 0;
  }
  // ========================================
  
  renderCanopy();
  
}

void clearStrips() {
  for (int i = 0; i < numStrips; i++) {
    ledstrips[i].clear();
  }
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
  float xSmall = apexR * sin(angle);
  float ySmall = 0;
  float zSmall = apexR * cos(angle);
  float xLarge = r * sin(angle);
  float yLarge = -h;
  float zLarge = r * cos(angle);
  
  noStroke();
  line(xSmall, ySmall, zSmall, xLarge, yLarge, zLarge);
  
  /**
   * Draw the LEDs
   */
    for (int j = 0; j < numLedsPerStrip; j++) {
      // Interpolate them equally along the length of the strip
      float xLed = (xLarge - xSmall) * (j + 2) / numLedsPerStrip;
      float yLed = (yLarge - ySmall) * (j + 2) / numLedsPerStrip;
      float zLed = (zLarge - zSmall) * (j + 2) / numLedsPerStrip;
    
      pushMatrix();
      translate(xLed, yLed, zLed);
      //stroke(255 / 75 * j);
      //sphere(2);
      fill(s.leds[j]);
      stroke(s.leds[j]);
      box(0.5,0.5,0.5);
      popMatrix();
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
