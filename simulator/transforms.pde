
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
  private int offset = 0;
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
