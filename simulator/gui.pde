boolean isFadingOut = false;
int pulseCount = 20;
int fadeSpeed = 10;
boolean stopCurrentAudio = true;
boolean videoMuted = false;
String selectedAudio; 
String selectedImg;
String selectedGif;
String selectedVid;
boolean listeningToMic = false;

class GUI {
  public ControlP5 cp5;
  
  public GUI(PApplet window) {
    cp5 = new ControlP5(window);
     ScrollableList imgDropdown = cp5.addScrollableList("ImgFiles").setLabel("Select JPG/PNG").setSize(200,200).setPosition(170, 90).setOpen(false);
    imgDropdown.setDirection(PApplet.UP);
     imgDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        UpdateDropdownList((ScrollableList)e.getController(), "/images");
      }
    });
    
    ScrollableList vidDropdown = cp5.addScrollableList("VidFiles").setLabel("Select Video File").setSize(200,200).setPosition(170,50).setOpen(false);
     vidDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        UpdateDropdownList((ScrollableList)e.getController(), "/data");
      }
    });
    
    ScrollableList audioDropdown = cp5.addScrollableList("AudioFiles").setLabel("Select Sound File").setSize(200,200).setPosition(170, 10).setOpen(false);
    audioDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        UpdateDropdownList((ScrollableList)e.getController(), "/audio");
        ((ScrollableList)e.getController()).addItem("Speaker Audio", "Speaker Audio");
      }
    });
    
    cp5.addButton("PlayAudio").setLabel("Play Audio").setPosition(400,10);
    cp5.addButton("PauseAudio").setLabel("Pause Audio").setPosition(475,10);
    cp5.addButton("StopAudio").setLabel("Stop Audio").setPosition(550, 10);
    
    cp5.addButton("PlayVieo").setLabel("Play Video").setPosition(400,50);
    cp5.addButton("PauseVideo").setLabel("Pause Video").setPosition(475,50);
    cp5.addButton("StopVideo").setLabel("Stop Video").setPosition(550, 50);
    cp5.addButton("MuteVideo").setLabel("Toggle Video Audio").setPosition(625, 50).setSize(100,19);
    
    // ADD PARAM BUTTONS HERE
    
    // ======================
    ScrollableList patternList = cp5.addScrollableList("PatternSelect").setLabel("Select Pattern").setSize(150,200).setPosition(10,10).setOpen(false);
    addPatterns(patternList);

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

void UpdateDropdownList(ScrollableList list, String folder) {
  list.clear();
  String path = sketchPath() + folder;
  String[] filenames = listFileNames(path);
  for (String s : filenames) {
    list.addItem(s, folder + "/" + s);
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

void controlEvent(ControlEvent theEvent) {
  if (theEvent.getController().getName() == "PatternSelect") {
   ScrollableList d = (ScrollableList)theEvent.getController();
   println(d.getValue());
   setPattern(int(d.getValue()));
  }
  // AUDIO
  if (theEvent.getController().getName() == "AudioFiles") {
    ScrollableList d = (ScrollableList)theEvent.getController();
    int index = int(d.getValue());
    println("[AUDIO SELECTED]" + d.getItem(index).get("value"));
    selectedAudio = d.getItem(index).get("value").toString();
    if (selectedAudio.equals("Speaker Audio")) {
      listeningToMic = true;
      fft = new FFT(audio.bufferSize(), audio.sampleRate());
    }
    else {
      listeningToMic = false;
      player = minim.loadFile(selectedAudio, 1024);
      fft = new FFT(player.bufferSize(), player.sampleRate());
    }
  }
  // GIF and IMGs
  if (theEvent.getController().getName() == "ImgFiles") {
    ScrollableList d = (ScrollableList)theEvent.getController();
    int index = int(d.getValue());
    File f = new File(d.getItem(index).get("value").toString());
    println(getFileExtension(f).toLowerCase().trim());
    if (getFileExtension(f).toLowerCase().trim().equals("gif")) {
      println("[GIF SELECTED]" + d.getItem(index).get("value").toString());
      selectedGif = d.getItem(index).get("value").toString();
    } else {
      println("[IMAGE SELECTED]" + d.getItem(index).get("value").toString());
      selectedImg = d.getItem(index).get("value").toString();
    }
  }
  // VIDEO
  if (theEvent.getController().getName() == "VidFiles") {
    ScrollableList d = (ScrollableList)theEvent.getController();
    int index = int(d.getValue());
    println("[VIDEO SELECTED]" + d.getItem(index).get("name").toString());
    selectedVid = d.getItem(index).get("name").toString();
    movie = new Movie(this, selectedVid);
  }
}

 String getFileExtension(File file) {
    String fileName = file.getName();
    if(fileName.lastIndexOf(".") != -1 && fileName.lastIndexOf(".") != 0)
    return fileName.substring(fileName.lastIndexOf(".")+1);
    else return "";
}

String[] patterns = {"Empty", "Swirls", "Pulse", "Heart Beat", "Sound", "Gradient Pulse", "Rainbow Rings", "Still Image", "GIF", "Video"};
void addPatterns(ScrollableList list) {
  
  for (int i = 0; i < patterns.length; i++) {
    list.addItem(patterns[i], i);
  }
   
}

void setPattern(int val) {
  String name = patterns[val];
  FadeLEDs();
  switch (name) {
    case "Empty":
      pattern = new EmptyPattern(); break;
    case "Swirls":
      pattern = new PatternSwirly(color(255,0,0), 500, 0, false); break;
    case "Pulse":
      pattern = new PatternPulseMulti(20, color(10,255,10)); break;
    case "Heart Beat":
      pattern = new PatternHeartPulse(0.08, -0.1, 3, 0.5); break;
    case "Sound":
      pattern = new PatternSound(); break;
    case "Gradient Pulse":
      pattern = new PatternGradientPulse(); break;
    case "Rainbow Rings":
      pattern = new PatternRainbowRings(); break;
    case "Still Image":
      if (selectedImg == null) { println("[WARNING] Still image not selected"); }
      else { pattern = new ImgPattern(selectedImg); }
      break;
    case "GIF":
      if (selectedGif == null) { println("[WARNING] GIF not selected"); }
      else { pattern = new GifPattern(this, selectedGif); }
      break;
    case "Video":
      if (selectedVid == null) { println("[WARNING] No video selected"); }
      else { pattern = new MoviePattern(true, false); }
      break;
  }
}
 
void PlayAudio() {
  if (player == null) {
    if (selectedAudio == null) { println("[WARNING] No audio selected!"); } 
    else {
      player = minim.loadFile(selectedAudio, 1024);
      fft = new FFT(player.bufferSize(), player.sampleRate());
    }
  }
  if (!player.isPlaying() && !listeningToMic) {
    player.play();
  }
}

void StopAudio() {
  if (player != null && player.isPlaying()) { player.pause(); player.rewind(); }
}

void PauseAudio() {
  if (player != null && player.isPlaying()) { player.pause(); }
}

void PlayVideo() {
  if (movie != null) { movie.play(); }
}

void PauseVideo() {
  if (movie != null) { movie.pause(); }
}

void StopVideo() {
  if (movie != null) { movie.stop(); }
}

void MuteVideo() {
  if (movie != null) { 
    if (videoMuted) { movie.volume(100); videoMuted = false; }
    else { movie.volume(0); videoMuted = true; }
  }
  
}
  