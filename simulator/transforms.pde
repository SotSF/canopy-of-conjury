
class Transforms {
  private ArrayList<BaseTransform> transforms;

  public Transforms (BaseTransform transform) {
    transforms = new ArrayList<BaseTransform>();
    transforms.add(transform);
  }

  public Transforms () {
    transforms = new ArrayList<BaseTransform>();
  }

  public void addTransform (BaseTransform transform) {
    transforms.add(transform);
  }

  void apply (Strip[] ledStrips) {
    for (BaseTransform transform : transforms) {
      transform.apply(ledStrips);
    }
  }
}


public interface ITransform {
  void apply  (Strip[] strips);
  void _apply (Strip[] strips);
}

abstract class BaseTransform implements ITransform {
  // Keeps track of the number of iterations through the draw loop the transform has been operating.
  int timeStep = 0;
  void apply(Strip[] strips) {
    this._apply(strips);
    timeStep += 1;
  };
}

class RotationTransform extends BaseTransform {
  // Controls the direction of the rotation as well as the speed. Positive values
  // will cause clockwise rotations (when viewed from overhead) while negative
  // values cause counterclockwise rotations. The magnitude of the velocity indicates
  // how many strips the pattern will be rotated by with each iteration of the draw
  // loop.
  private int velocity = 1;

  void _apply(Strip[] strips) {
    // Indicates the current position of the rotation. Ranges from 0 to NUM_STRIPS - 1.
    // A value of 0 will cause no rotation to occur; a value of NUM_STRIPS / 4 will
    // cause the pattern to rotate 90 degrees.
    int offset = timeStep % NUM_STRIPS;

    // strip list that will be moved to the front
    Strip[] lastStrips = new Strip[offset];
    for (int i = 0; i < offset; i++) {
      lastStrips[i] = strips[strips.length - offset + i];
    }

    // Move all strips over by offset
    for (int i = strips.length - offset - 1; i >= 0; i--) {
      strips[(i + offset)] = strips[i];
    }

    // Append the last strips to the front of the array
    for (int i = 0; i < offset; i++) {
      strips[i] = lastStrips[i];
    }
  }

  void changeDirection () {
    velocity = velocity * -1;
  }
}


boolean hsvTransformAutoSlide = false;
void toggleHsvTransformMode () {
  hsvTransformAutoSlide = !hsvTransformAutoSlide;
  if (hsvTransformAutoSlide) println("HSV auto mode engaged");
  else println("HSV auto mode terminated");
}

class HSVTransform extends BaseTransform {
  Slider slider;
  Button sliderModeButton;

  private int sliderHeight = 200;
  private int padding = 20;
  private int sliderY = height - padding - sliderHeight;
  private int sliderX = padding;
  private int amplitude = 1;
  private int sliderScaleFactor = 100;
  private float hertz = 0.5;
  private float stepsPerLap = 50;

  public HSVTransform () {
    super();

    // add a vertical slider
    slider = gui.cp5.addSlider("saturation")
     .setPosition(sliderX, sliderY)
     .setSize(20, sliderHeight)
     .setRange(0, amplitude * sliderScaleFactor)
     .setValue(amplitude * sliderScaleFactor)
     .setSliderMode(Slider.FLEXIBLE);

   sliderModeButton = gui.cp5.addButton("toggleHsvTransformMode")
     .setLabel("Auto")
     .setPosition(50, height - 50)
     .setSize(50, 20);
  }

  void _apply (Strip[] strips) {
    colorMode(HSB, 360, 100, 100);

    // Move the value automatically if auto mode is engaged
    if (hsvTransformAutoSlide) {
      println(TWO_PI, hertz, timeStep, stepsPerLap, TWO_PI * hertz * timeStep / stepsPerLap);
      float halfAmplitude = amplitude / 2.;
      float newValue = halfAmplitude * sin(TWO_PI * hertz * timeStep / stepsPerLap) + halfAmplitude;
      slider.setValue(newValue * sliderScaleFactor);
    }

    for (Strip strip : strips) {
      for (int i = 0; i < strip.length(); i++) {
        color curColor = strip.leds[i];
        strip.leds[i] = color(
          hue(curColor),
          saturation(curColor) * slider.getValue() / (float)sliderScaleFactor,
          brightness(curColor)
        );
      }
    }

    colorMode(RGB, 255);
  }
}
