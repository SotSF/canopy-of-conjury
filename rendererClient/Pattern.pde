interface IPattern {
  void run();
}

class Pattern implements IPattern {
  void run() {
    background(0);
  }
}

enum PatternSelect {
  EMPTY,
  WISP
}