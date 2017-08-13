/**
 * Draws a gently shifting gradient from the conter of the canopy to the rim
 **/

enum GradientTravelDirection {
  inwards,
  outwards;
}


class PatternGradient extends Pattern {
  ArrayList<RingColor> ringColors;
  color[] interpolation;
  ColorSelectionState colorState;

  // color selector attributes
  private PImage colorSelector;
  private int csDimensions = 150;
  private int csPadding = 10;
  private int csY = height - csDimensions - csPadding;
  private int csX = csPadding;

  // state attributes
  GradientTravelDirection curDirection;
  int curPosition;

  public PatternGradient() {
    this.ringColors = new ArrayList<RingColor>();
    this.curDirection = GradientTravelDirection.outwards;
    this.curPosition = 0;
    this.colorState = new ColorSelectionState();
  }

  public void initialize () {
    // Load the color selector image
    colorSelector = loadImage("color-selector.png");
  }

  public void runDefault(Strip[] strips) {
    // if no gradient has been initialized yet, don't do anything
    if (this.interpolation == null) return;

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

  public void renderAuxiliary () {
    image(colorSelector, csX, csY, csDimensions, csDimensions);
  }

  /**
   * Determine if the mouse press occurred within the color selector
   */
  public void onMousePressed (int x, int y) {
    boolean xInBounds = csX < x && x < csX + csDimensions;
    boolean yInBounds = csY < y && y < csY + csDimensions; 
    if (!xInBounds || !yInBounds) {
      // reset state
      this.colorState.reset();
      return;
    }

    // get the color. If it's the background color, they have clicked outside the
    // selector. Reset state
    color clickedColor = get(x, y);
    if (clickedColor == color(backgroundColor)) {
      this.colorState.reset();
      return;
    }

    // got a valid color, update the state
    this.colorState.addColor(x, y, clickedColor);
  }

  private void interpolateColors () {
    color[] interpolatedColors = new color[NUM_LEDS_PER_STRIP];

    // use HSB for this
    colorMode(HSB, 100);

    color color1 = this.colorState.active1;
    color color2 = this.colorState.active2;

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

    this.interpolation = interpolatedColors;
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

  private class ColorSelectionState {
    color active1;
    color active2;
    ColorCoord staged1;
    ColorCoord staged2;

    public ColorSelectionState () {
      this.staged1 = new ColorCoord();
      this.staged2 = new ColorCoord();
    }

    /**
     * Resets the staging colors. This will keep the active colors unchanged.
     * To reset the active colors as well, call `clear`
     */
    public void reset () {
      this.staged1.reset();
      this.staged2.reset();
    }

    /**
     * Updates the state with a new color. If the `staged1` ColorCoord isn't
     * set yet, we will add the color there. If it is set, then we'll add the
     * new color to `staged2` and then update the active colors
     */ 
    public void addColor (int x, int y, color c) {
      if (!this.staged1.isSet()) {
        this.staged1.setParams(x, y, c);
        return;
      }

      this.staged2.setParams(x, y, c);

      // move the colors into the active registries
      this.active1 = this.staged1.c;
      this.active2 = this.staged2.c;

      // regenerate the interpolated colors
      interpolateColors();

      // reset the staged state
      this.reset();
    }

    private class ColorCoord {
      int x;
      int y;
      color c;

      public ColorCoord () {
        this(-1, -1, 0);
      }

      public ColorCoord (int x, int y, color c) {
        this.x = x;
        this.y = y;
        this.c = c;
      }

      /**
       * If the color is 0, the ColorCoord has not been set
       */
      public boolean isSet () {
        return this.c != 0;
      }

      public void setParams (int x, int y, color c) {
        this.x = x;
        this.y = y;
        this.c = c;
      }

      public void reset () {
        this.x = -1;
        this.y = -1;
        this.c = 0;
      }
    }
  }
}