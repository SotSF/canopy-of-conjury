/**
 * Draws a gently shifting gradient from the conter of the canopy to the rim
 **/

enum GradientTravelDirection {
  inwards,
  outwards;
}

class PatternGradient extends Pattern {
  ArrayList<RingColor> ringColors;
  color color1;
  color color2;
  color[] interpolation;

  // state attributes
  GradientTravelDirection curDirection;
  int curPosition;

  public PatternGradient(color color1, color color2) {
    this.color1 = color1;
    this.color2 = color2;
    this.interpolation = this.interpolateColors();
    this.ringColors = new ArrayList<RingColor>();
    this.curDirection = GradientTravelDirection.outwards;
    this.curPosition = 0;
  }

  public void runDefault(Strip[] strips) {
    clearStrips();

    // add the next color to the front of the list
    color nextColor = this.getColor();
    ringColors.add(0, new RingColor(nextColor));

    // remove the last color if the list is now greater than the number of leds
    if (ringColors.size() > NUM_LEDS_PER_STRIP) {
      ringColors.remove(NUM_LEDS_PER_STRIP);
    }

    // go through every position in ringColors, and light up the corresponding LED in all strips
    for (int i = 0; i < ringColors.size(); i++) {
      for (int j = 0; j < NUM_STRIPS; j++) {
        Strip s = strips[j];
        s.leds[i] = ringColors.get(i).c;
      }
    }

    // Augment the position, flipping the color direction if appropriate
    curPosition++;
    if (curPosition == NUM_LEDS_PER_STRIP) {
      curPosition = 0;
      this.flipDirection();
    }
  }

  public void onClick (int x, int y) {
    println(x, y);
  }

  private color[] interpolateColors () {
    color[] interpolatedColors = new color[NUM_LEDS_PER_STRIP];

    // use HSB for this
    colorMode(HSB, 100);

    float hueStart    = hue(color1);
    float satStart    = saturation(color1);
    float brightStart = brightness(color1);
    float hueEnd      = hue(color2);
    float satEnd      = saturation(color2);
    float brightEnd   = brightness(color2);

    // augmentation values
    float hueAugment    = (hueEnd - hueStart) / (NUM_LEDS_PER_STRIP - 1);
    float satAugment    = (satEnd - satStart) / (NUM_LEDS_PER_STRIP - 1);
    float brightAugment = (brightEnd - brightStart) / (NUM_LEDS_PER_STRIP - 1);

    // iterate over the length of the LED strips and derive the interpolated value
    for (int i = 0; i < NUM_LEDS_PER_STRIP; i++) {
      interpolatedColors[i] = color(
        hueStart    + hueAugment * i,
        satStart    + satAugment * i,
        brightStart + brightAugment * i
      );
    }

    // switch the color mode back
    colorMode(RGB, 255);

    return interpolatedColors;
  }

  private color getColor () {
    // use the position, direction, and the pre-computed interpolation to retrieve the next color
    if (curDirection == GradientTravelDirection.outwards) {
      return interpolation[curPosition];
    } else {
      return interpolation[NUM_LEDS_PER_STRIP - curPosition - 1];
    }
  }

  private void flipDirection () {
    if (curDirection == GradientTravelDirection.outwards) {
      curDirection = GradientTravelDirection.inwards;
    } else {
      curDirection = GradientTravelDirection.outwards;
    }
  }

  private class RingColor {
    color c;
    public RingColor(color c) {
      this.c = c;
    }
  }
}