import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

boolean testing = true;
boolean bypassSimulator = true;
final int dimension = 500;
TestObserver observer;
DeviceRegistry registry;
int NUM_STRIPS = 96;
int NUM_LEDS_PER_STRIP = 75;
Strip[] ledstrips;

Pattern pattern;
int tick = 0;
void setup() {
  registry = new DeviceRegistry();
  observer = new TestObserver();
  registry.addObserver(observer);
  delay(500);

  noSmooth();
  size(500, 500);
  ledstrips = new Strip[NUM_STRIPS];
  for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i] = new Strip();
  }
  //pattern = new IdentifyStripZero();
  //pattern = new IdentifyTripleZigs();
  pattern = new Snakes();
  //pattern = new RedRing();
}

void draw() {
  if (tick % 3 == 0) {
  translate(250, 250);
  clearStrips();
  clear();
  pattern.runDefault(ledstrips);
  renderCanopy();
  push();
  }
  tick++;
}


void push() {
   if (!observer.hasStrips) { return; }
   registry.startPushing();
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
       if (i >= 8) strip += NUM_STRIPS / 2;
       tripleZig.setPixel(ledstrips[strip].leds[led], l);
     }
   }
}

void renderCanopy() {
  pushMatrix();
  for (int s = 0; s < NUM_STRIPS; s++) {
    rotate(2 * PI / NUM_STRIPS);
    stroke(25);
    line(0, 0 + 20, 0, NUM_LEDS_PER_STRIP * 3 + 20);
  }
  popMatrix();
  renderStrips();
}

void renderStrips() {
  for (int s = 0; s < NUM_STRIPS; s++) {
    rotate(2 * PI / NUM_STRIPS);
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      stroke(ledstrips[s].leds[l]);
      point(0, l * 3 + 20);
    }
  }
}

void clearStrips() {
  for (int i = 0; i < NUM_STRIPS; i++) {
    ledstrips[i].clear();
  }
}


class Strip {
  color[] leds = new color[NUM_LEDS_PER_STRIP];

  public void clear() {
    for (int i = 0; i < leds.length; i++) {
      leds[i] = color(0);
    }
  }

  public int length () {
    return leds.length;
  }
}

class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    this.hasStrips = true;
  }
}