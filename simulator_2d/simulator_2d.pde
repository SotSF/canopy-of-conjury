// use this to control the pixel pusher simulator display
import gifAnimation.*;

int NUM_STRIPS = 96;
int NUM_LEDS_PER_STRIP = 75;
int ledSpacer = 7;
int ledSize = 5;
int columns = 124;
int rows = 60;

// Constants
float FEET_PER_METER = 3.28084;
int TOTAL_LEDS = 7200;
int BASE_RADIUS_FEET = 8;
float STRIP_LENGTH_METERS = 2.5;
float STRIP_LENGTH_FEET = STRIP_LENGTH_METERS * FEET_PER_METER;
float APEX_RADIUS_FEET = 0.5;
float MAX_HEIGHT_FEET = sqrt(pow(STRIP_LENGTH_FEET, 2) - pow(BASE_RADIUS_FEET - APEX_RADIUS_FEET, 2));

// Initialize the height
int scaleFactor = 30;
float BASE_RADIUS = BASE_RADIUS_FEET * scaleFactor;
float h = MAX_HEIGHT_FEET * scaleFactor;
float APEX_RADIUS = APEX_RADIUS_FEET * scaleFactor;

float BASE_DIAMETER = BASE_RADIUS * 2;
float APEX_DIAMETER = APEX_RADIUS * 2;

int dispWidth = 200;
int dispHeight = 200;

Strip[] ledstrips = new Strip[NUM_STRIPS];
Pattern pattern;

// run once
void setup() {
   for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i] = new Strip(new color[NUM_LEDS_PER_STRIP]);
  }
  
  noSmooth(); // turn of anti-aliasing for 1-to-1 pixel color
  // build display window, for GUI purpose
  fill(0);
  size(1500,1000);
  fill(0);
  rect(0,0,1500,1000);
  fill(color(0));
  stroke(color(255));
  strokeWeight(1);
  rect(-1,-1,dispWidth + 1,dispHeight + 1);
  
  /**
  For best results, images should be 200x200 pixels or larger.
  Core components should not be centered (the apex cuts the image center)
  **/
  pattern = new ImgPattern("./images/rainbow_Stripe.png", color(255));
  

  /** GIFS! **/
  //pattern = new GifPattern(this, "./images/fox_silhouette.gif");
  
  /* Test boundaries and cut-offs */
  //pattern = new TestPattern();
  
}

int _tick = 0;
void draw() {
  
  // speed control
  if (_tick % 2 == 0) {
    noStroke();
    pattern.run(ledstrips);
   
  }
  
  // this maps directly to strips/rads
  // we'll need a function that converts strips/rads to pixel pusher arrays (e.g. 8 of 6 of 75);
  renderCanopy(1000,500);
   _tick += 1;
}

// ======================

void renderCanopy(int x, int y) {
  translate(x, y);
  // Render the strips
  for (int i = 0; i < NUM_STRIPS; i++) {
    renderStrip(i);
  }
}

void renderStrip(int i) {
  Strip s = ledstrips[i];
  pushMatrix();
  rotate(radians((float)360/NUM_STRIPS * i));
  strokeWeight(1);
  
  int l = 0;
  while (l < NUM_LEDS_PER_STRIP) {
    fill(s.leds[l]);
    stroke(s.leds[l] == color(0) || s.leds[l] == 0 ? color(150,150,150) : s.leds[l]);
    ellipse(0, NUM_STRIPS + (5 * l), 3,3);
    l++;
  }
  popMatrix();
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

void clearStrips() {
  for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i].clear();
  }
}