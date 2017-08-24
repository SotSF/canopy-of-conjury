
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
  void apply(Strip[] strips);
}

abstract class BaseTransform implements ITransform {
  void apply(Strip[] strips) {};
}

class RotationTransform extends BaseTransform {
  // Indicates the current position of the rotation. Ranges from 0 to NUM_STRIPS - 1.
  // A value of 0 will cause no rotation to occur; a value of NUM_STRIPS / 4 will
  // cause the pattern to rotate 90 degrees.
  private int offset = NUM_STRIPS / 4;

  // Controls the direction of the rotation as well as the speed. Positive values
  // will cause clockwise rotations (when viewed from overhead) while negative
  // values cause counterclockwise rotations. The magnitude of the velocity indicates
  // how many strips the pattern will be rotated by with each iteration of the draw
  // loop.
  private int velocity = 1;

  void apply(Strip[] strips) {
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

    offset = (offset + direction) % NUM_STRIPS;
    if (offset < 0) offset += NUM_STRIPS;
  }
}
