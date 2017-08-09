/*
* Relies on rendererClient to paint the sky
*/

class PatternInfiniteSky extends Pattern {
  Command cmd = new Command(new PVector(0,0,0),new PVector(0,0,0),"SKY");
  PatternInfiniteSky() {
    
  }
  void runDefault(Strip[] strips) {
    conjurer.mode = MODE_LISTENING;
    conjurer.cmdString = String.format("{\"origin\" : \"(%f,%f,%f)\"," +
                                   "\"vector\" : \"(%f,%f,%f)\"," +
                                   "\"action\" : \" %s \"" +
                                   "}",0.0,0.0,0.0,0.0,0.0,0.0,"SKY");
    conjurer.command = cmd;
    conjurer.cast();
    conjurer.mode = MODE_MANUAL;
  }
  
  void onClose(Strip[] strips) {
    conjurer.cmdString = String.format("{\"origin\" : \"(%f,%f,%f)\"," +
                                   "\"vector\" : \"(%f,%f,%f)\"," +
                                   "\"action\" : \" %s \"" +
                                   "}",0.0,0.0,0.0,0.0,0.0,0.0,"SKY_OFF");
    conjurer.command = cmd;
    conjurer.cast();
  }
}