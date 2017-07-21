boolean isFadingOut = false;
int pulseCount = 20;
int fadeSpeed = 10;
boolean stopAudio = true;

String selectedAudio;
class GUI {
  public ControlP5 cp5;
  
  public GUI(PApplet window) {
    cp5 = new ControlP5(window);
    cp5.addButton("FadeLEDs").setLabel("Fade Out").setPosition(0,0);
    cp5.addSlider("UpdateFadeSpeed").setLabel("Fade Speed").setSize(100,20).setRange(10,30).setNumberOfTickMarks(5).setPosition(120,0).setValue(10);
    cp5.addButton("PlayPatternSwirly").setLabel("Swirls").setPosition(0,30);
    cp5.addButton("PlayPatternPulseMulti").setLabel("Pulse").setPosition(0,60);
    cp5.addSlider("UpdatePulseCount").setLabel("Pulse Rings").setSize(100,20).setRange(5,50).setNumberOfTickMarks(10).setPosition(120,60).setValue(20);
    
    cp5.addToggle("ToggleAudioTransition").setLabel("End Song on Fade").setPosition(5,90);
    cp5.addButton("PlayPatternAVPulse").setLabel("AV - Pulse").setPosition(0, 130);
    cp5.addButton("PlayPatternAVRainbowPulse").setLabel("AV - Rainbow Pulse").setSize(100,20).setPosition(0, 160);
    DropdownList audioDropdown = cp5.addDropdownList("AudioFiles").setLabel("Select Sound File").setSize(200,200).setPosition(300, 10);
    UpdateAudioList(audioDropdown);
    cp5.addButton("DebugLedstrips").setLabel("Debug").setPosition(0,220);
    cp5.setAutoDraw(false);
  }
  
  public void run() {
    currCameraMatrix = new PMatrix3D(g3.camera);
    camera();
    cp5.draw();
    g3.camera = currCameraMatrix;
  }
  
  
}

void DebugLedstrips() {
  for (Strip s : ledstrips) {
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      color c = s.leds[l];
      int red = (c >> 16) & 0xFF;
      int green = (c >> 8) & 0xFF;
      int blue = c & 0xFF;
      print("(" + red + "," + green + "," + blue + ")");
    }
    println();
  }
  println(allLedsOff());
}

boolean allLedsOff() {
  int count = 0;
  for (Strip s : ledstrips) {
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      color c = s.leds[l];
      if (c == 0 || c == color(0)) count++;
    }
  }
  return count == TOTAL_LEDS;
}

void FadeLEDs() {
  pattern = new EmptyPattern();
  if (player != null && stopAudio) { player.pause(); } // fade out music?
  if (movie != null) { movie.stop(); } // fade out movie?
  isFadingOut = true;
}

void UpdateFadeSpeed(int val) {
  fadeSpeed = val;
}

void fadeStrips() {
  for (Strip s : ledstrips) {
    for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
      color c = s.leds[l];
      int red = (c >> 16) & 0xFF;
      int green = (c >> 8) & 0xFF;
      int blue = c & 0xFF;  
      if (red > 0) red -= fadeSpeed;
      if (green > 0) green -= fadeSpeed;
      if (blue > 0) blue -= fadeSpeed;
      s.leds[l] = color(red,green,blue);
    }
  }
  if (allLedsOff()) {
    isFadingOut = false;
  }
}

void PlayPatternSwirly() {
  FadeLEDs();
  pattern = new PatternSwirly(color(255,0,0), 500, 0, false);
}

void PlayPatternPulseMulti() {
  FadeLEDs();
  pattern = new PatternPulseMulti(pulseCount, color(10,255,10));
}

void UpdatePulseCount(int val) {
  pulseCount = val;
}

void UpdateAudioList(DropdownList d) {
  String path = sketchPath() + "/audio";
  String[] filenames = listFileNames(path);
  for (String s : filenames) {
    d.addItem(s, s);
  }
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

void PlayPatternAVPulse() {
  if (selectedAudio == null) { println("[WARNING] No audio selected"); }
  else {
    FadeLEDs();
    pattern = new PatternAVTestPulse(selectedAudio);
  } 
}

void PlayPatternAVRainbowPulse() {
  if (selectedAudio == null) { println("[WARNING] No audio selected"); }
  else { 
    FadeLEDs();
    pattern = new PatternAVRainbowPulsar(selectedAudio);
  }
}

void ToggleAudioTransition(boolean value) {
  stopAudio = value;
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.
  if (theEvent.getController().getName() == "AudioFiles") {
    DropdownList d = (DropdownList)theEvent.getController();
    println("[AUDIO SELECTED]" + d.getValueLabel().getText());
    selectedAudio = "./audio/" + d.getValueLabel().getText();
  }
}