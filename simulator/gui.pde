int fadeSpeed = 10;
int playlistRuntime = 3 * 1000;
boolean isFadingOut = false;
boolean stopCurrentAudio = true;
boolean videoMuted = false;
String selectedAudio;
String selectedImg;
String selectedGif;
String selectedVid;
String selectedPlaylist;
boolean listeningToMic = false;
PatternSelect selectedPattern = PatternSelect.EMPTY;

Button modebtn;

enum PatternSelect {
  EMPTY("Empty"),
  BEAT_DETECT("Beat Detect"),
  FLOWER("Blossom"),
  DIAMONDS("Diamonds"),
  FIREFLIES("Fireflies"),
  BURST("Fireworks"),
  GRADIENT_PULSE("Gradient Pulse"),
  GRADIENT("Gradient"),
  HEART_BEAT("Heart Beat"),
  INFINITE_SKY("Infinite Sky"),
  INFINITE_NIGHT("Infinite Night"),
  PULSE("Pulse"),
  RAINBOW_RINGS("Rainbow Rings"),
  SOUND("Sound"),
  SOUND_BLOB("Sound Blob"),
  SUNFLOWER("Sunflower"),
  SWIRLS("Swirls"),
  STILL_IMAGE("Still Image"),
  GIF_IMAGE("Gif"),
  VIDEO("Video"),
  PLAYLIST("Playlist"),
  TEST_SNAKE("Snake (Test)"),
  TEST_ID_TRIPLETS("Identify Triple Zigs (Test)"),
  TEST_ID_STRIP_0("Identify Strip Zero (Test)"),
  TEST_RED_RING("Red Ring (Test)");

  private final String displayName;
  private PatternSelect(String displayName) {
    this.displayName = displayName;
  }
};

class GUI {
  public ControlP5 cp5;

  public GUI(PApplet window) {
    cp5 = new ControlP5(window);

    // Playlist picker
    ScrollableList playlistDropdown = cp5.addScrollableList("PlaylistFolders")
                                          .setLabel("Select Playlist Folder")
                                          .setSize(200,200)
                                          .setPosition(170,130)
                                          .setOpen(false);
    playlistDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        AddPlaylists((ScrollableList)e.getController());
      }
    });


    // Kinect mode toggle button
    modebtn = cp5.addButton("ToggleMode")
                 .setLabel("Switch to Kinect Mode")
                 .setPosition(400,90)
                 .setSize(100,20);

    // Image picker
    ScrollableList imgDropdown = cp5.addScrollableList("ImgFiles")
                                    .setLabel("Select JPG/PNG")
                                    .setSize(200,200)
                                    .setPosition(170, 90)
                                    .setOpen(false);
    imgDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        UpdateDropdownList((ScrollableList)e.getController(), "/images");
      }
    });

    // Video picker
    ScrollableList vidDropdown = cp5.addScrollableList("VidFiles")
                                    .setLabel("Select Video File")
                                    .setSize(200,200)
                                    .setPosition(170,50)
                                    .setOpen(false);
    vidDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        UpdateDropdownList((ScrollableList)e.getController(), "/data");
      }
    });

    // Audio picker
    ScrollableList audioDropdown = cp5.addScrollableList("AudioFiles")
                                      .setLabel("Select Sound File")
                                      .setSize(200,200)
                                      .setPosition(170, 10)
                                      .setOpen(false);
    audioDropdown.onClick(new CallbackListener() {
      void controlEvent(CallbackEvent e) {
        UpdateDropdownList((ScrollableList)e.getController(), "/audio");
        ((ScrollableList)e.getController()).addItem("Speaker Audio", "Speaker Audio");
      }
    });


    cp5.addButton("PlayAudio").setLabel("Play Audio").setPosition(400,10);
    cp5.addButton("PauseAudio").setLabel("Pause Audio").setPosition(475,10);
    cp5.addButton("StopAudio").setLabel("Stop Audio").setPosition(550, 10);

    cp5.addButton("PlayVideo").setLabel("Play Video").setPosition(400,50);
    cp5.addButton("PauseVideo").setLabel("Pause Video").setPosition(475,50);
    cp5.addButton("StopVideo").setLabel("Stop Video").setPosition(550, 50);
    cp5.addButton("MuteVideo").setLabel("Toggle Video Audio").setPosition(625, 50).setSize(100,19);

    // ADD PARAM BUTTONS HERE

    // ======================
    ScrollableList patternList = cp5.addScrollableList("PatternSelect")
                                    .setLabel("Select Pattern")
                                    .setSize(150,200)
                                    .setPosition(10,10)
                                    .setOpen(false);
    addPatterns(patternList);

    cp5.addButton("DebugLedstrips").setLabel("Debug").setPosition(0,220);
    cp5.setAutoDraw(false);
  }

  public void run() {
    currCameraMatrix = new PMatrix3D(g3.camera);
    camera();
    cp5.draw();
    g3.camera = currCameraMatrix;
    pattern.renderAuxiliary();
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

void AddPlaylists(ScrollableList list) {
    // Adds the folders under /playlists to a dropdown list to be selected from
    list.clear();
    String path = sketchPath() + "/playlists";
    File playlistFolder = new File(path);
    String[] folders = playlistFolder.list();
    for (String f : folders) {
        File fhandle = new File(path+"/"+f);
        println(f);
        if (fhandle.isDirectory()) {
            list.addItem(f, path + "/" + f);
        }
    }
}

void UpdateDropdownList(ScrollableList list, String folder) {
  list.clear();
  String path = sketchPath() + folder;
  String[] filenames = listFileNames(path);
  for (String s : filenames) {
    list.addItem(s, path + "/" + s);
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
   String patternName = d.getItem(int(d.getValue())).get("value").toString();
   setPattern(PatternSelect.valueOf(patternName));
  }
  // AUDIO
  if (theEvent.getController().getName() == "AudioFiles") {
    ScrollableList d = (ScrollableList)theEvent.getController();
    int index = int(d.getValue());
    println("[AUDIO SELECTED]" + d.getItem(index).get("value"));
    selectedAudio = d.getItem(index).get("value").toString();
    if (player != null) player.mute();
    if (selectedAudio.equals("Speaker Audio")) { //<>// //<>// //<>// //<>// //<>//
      listeningToMic = true;
      fft = new FFT(audio.bufferSize(), audio.sampleRate());
      fft.logAverages(11, 1);
    }
    else {
      listeningToMic = false;
      player = minim.loadFile(selectedAudio, 1024);
      fft = new FFT(player.bufferSize(), player.sampleRate());
      fft.logAverages(11, 1);
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
      setPattern(PatternSelect.GIF_IMAGE);
    } else {
      println("[IMAGE SELECTED]" + d.getItem(index).get("value").toString());
      selectedImg = d.getItem(index).get("value").toString();
      setPattern(PatternSelect.STILL_IMAGE);
    }
  }
  // VIDEO
  if (theEvent.getController().getName() == "VidFiles") {
    ScrollableList d = (ScrollableList)theEvent.getController();
    int index = int(d.getValue());
    println("[VIDEO SELECTED]" + d.getItem(index).get("name").toString());
    selectedVid = d.getItem(index).get("name").toString();
    movie = new Movie(this, selectedVid);
    setPattern(PatternSelect.VIDEO);
  }

  // PLAYLIST
  if (theEvent.getController().getName() == "PlaylistFolders") {
    ScrollableList d = (ScrollableList)theEvent.getController();
    int index = int(d.getValue());
    println("[PLAYLIST SELECTED]" + d.getItem(index).get("value").toString());
    selectedPlaylist = d.getItem(index).get("value").toString();
    setPattern(PatternSelect.PLAYLIST);
  }
}

String getFileExtension(File file) {
    String fileName = file.getName();
    if(fileName.lastIndexOf(".") != -1 && fileName.lastIndexOf(".") != 0)
    return fileName.substring(fileName.lastIndexOf(".")+1);
    else return "";
}

void addPatterns(ScrollableList list) {
  PatternSelect[] patternNames = PatternSelect.values();
  for (int i = 0; i < patternNames.length; i++) {
    list.addItem(((PatternSelect)patternNames[i]).displayName, patternNames[i]);
  }
}

void setPattern(PatternSelect val) {
  pattern.onClose(ledstrips);
  FadeLEDs();
  switch (val) {
    case EMPTY:
      pattern = new EmptyPattern(); break;  
    case BEAT_DETECT:
      pattern = new PatternBeatDetect(); break;
    case SWIRLS:
      pattern = new PatternSwirly(color(255,0,0), 500, 1, false); break;
    case PULSE:
      pattern = new PatternPulseMulti(20, color(10,255,10)); break;
    case BURST:
      pattern = new PatternBurst(this); break;
    case SUNFLOWER:
      pattern = new PatternSunflower(); break;
    case FIREFLIES:
      pattern = new PatternFireFlies(); break;
    case FLOWER:
      pattern = new PatternBlossom(); break;
    case HEART_BEAT:
      pattern = new PatternHeartPulse(0.1, -0.07, 5, 0.5); break;
    case INFINITE_SKY:
      pattern = new PatternInfiniteSky(false); break;
    case INFINITE_NIGHT:
      pattern = new PatternInfiniteSky(true); break;
    case SOUND:
      pattern = new PatternSound(); break;
    case SOUND_BLOB:
      pattern = new PatternSoundBlob(); break;
    case GRADIENT_PULSE:
      pattern = new PatternGradientPulse(); break;
    case GRADIENT:
      pattern = new PatternGradient(); break;
    case RAINBOW_RINGS:
      pattern = new PatternRainbowRings(); break;
    case DIAMONDS:
      pattern = new PatternDiamonds(); break;
    case TEST_SNAKE:
      pattern = new Snakes(); break;
    case TEST_ID_TRIPLETS:
      pattern = new IdentifyTripleZigs(); break;
    case TEST_ID_STRIP_0:
      pattern = new IdentifyStripZero(); break;
    case TEST_RED_RING:
      pattern = new RedRing(); break;
    case STILL_IMAGE:
      if (selectedImg == null) { println("[WARNING] Still image not selected"); }
      else { pattern = new ImgPattern(selectedImg); }
      break;
    case GIF_IMAGE:
      if (selectedGif == null) { println("[WARNING] GIF not selected"); }
      else { pattern = new GifPattern(this, selectedGif); }
      break;
    case VIDEO:
      if (selectedVid == null) { println("[WARNING] No video selected"); }
      else { pattern = new MoviePattern(true, false); }
      break;
    case PLAYLIST:
      if (selectedPlaylist == null ) { println("WARNING] No playlist selected"); }
      else {
        println("in: setPattern, selectedPlaylist = "+selectedPlaylist);
        pattern = new PlaylistPattern(this, selectedPlaylist, playlistRuntime);
      }
      break;
  }
  selectedPattern = val;
  pattern.initialize();
}

void PlayAudio() {
  if (player == null) {
    if (selectedAudio == null) { println("[WARNING] No audio selected!"); }
    else {
      player = minim.loadFile(selectedAudio, 1024);
      fft = new FFT(player.bufferSize(), player.sampleRate());
      fft.logAverages(11, 1);
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
  if (movie != null) {
    if (selectedPattern != PatternSelect.VIDEO) {
      setPattern(PatternSelect.VIDEO);
    }
    if (selectedPattern == PatternSelect.VIDEO) {
      movie.play();
    }
  }
}

void PauseVideo() {
  if (movie != null) {
     if (selectedPattern == PatternSelect.VIDEO) {
      movie.pause();
    }
  }
}

void MuteVideo() {
  if (movie != null) {
    if (videoMuted) { movie.volume(100); videoMuted = false; }
    else { movie.volume(0); videoMuted = true; }
  }
}

void StopVideo() {
  if (movie != null) {
    if (selectedPattern == PatternSelect.VIDEO) {
      movie.stop();
      setPattern(PatternSelect.EMPTY);
      FadeLEDs();
      movie = new Movie(this, selectedVid);
    }
  }
}

void ToggleMode() {
  FadeLEDs();
  if (conjurer.mode == MODE_MANUAL) {
    conjurer.mode = MODE_LISTENING;
    modebtn.setLabel("Switch to Manual Mode");
  }
  else if (conjurer.mode == MODE_LISTENING) {
    conjurer.mode = MODE_MANUAL;
    modebtn.setLabel("Switch to Kinect Mode");
    kinectServer = null;
  }

  println(conjurer.mode);
}