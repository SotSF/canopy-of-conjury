void FadeLEDs() {
  //if (player != null && stopCurrentAudio) { player.pause(); } // fade out music?
  if (movie != null) { movie.stop(); } // fade out movie?
  isFadingOut = true;
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