interface IPattern {
  void run();
}

class Pattern implements IPattern {
  public void run() {
    clear();
  }
}