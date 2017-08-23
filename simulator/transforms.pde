
class Transforms {
  private ArrayList<Transform> transforms;
  
  public Transforms (Transform transform) {
    transforms = new ArrayList<Transform>();
    transforms.add(transform);
  }
  
  Strip[] apply (Strip[] ledStrips) {
    // Copy the strips over
    Strip[] transformStrips = new Strip[NUM_STRIPS];
    for (int i = 0; i < NUM_STRIPS; i++) {
      transformStrips[i] = new Strip(ledStrips[i]);
    }
    
    for (Transform transform : transforms) {
      transformStrips = transform.apply(transformStrips);
    }
    return transformStrips;
  }
}


public interface ITransform {
  Strip[] apply(Strip[] strips);
}

abstract class Transform implements ITransform {
  Strip[] apply(Strip[] strips) {
    return strips;
  };
}

class RotationTransform extends Transform {
  private int offset = 0;
  Strip[] apply(Strip[] strips) {
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
    
    offset = (offset + 1) % NUM_STRIPS;
    return strips;
  }
}