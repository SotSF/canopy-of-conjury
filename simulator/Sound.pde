class Sound {
  Minim minim;
  AudioInput micSignal;
  AudioPlayer player;
  BeatDetect beat;
  FFT fft;
  BeatListener bl;
  boolean listeningToMic = false;
  // Audio sampling rate
  public int sampleRate = 44100;
  Sound(PApplet window) {
    minim = new Minim(window);
    micSignal = minim.getLineIn(Minim.STEREO, 1024, 192000.0);
  }

  public void processMicSignal() {
    setBeat();
    fft = new FFT(micSignal.bufferSize(), micSignal.sampleRate());
    fft.logAverages(11, 1);
  }

  public void processAudioFile(String selectedAudio) {
    player = minim.loadFile(selectedAudio, 1024);
    setBeat();
    fft = new FFT(player.bufferSize(), player.sampleRate());
    fft.logAverages(11, 1);
  }

  private void setBeat() {
    if (beat == null) {
      if (listeningToMic) beat = new BeatDetect(micSignal.bufferSize(), micSignal.sampleRate());
      else beat = new BeatDetect(player.bufferSize(), player.sampleRate());
      beat.setSensitivity(120);
      bl = new BeatListener(beat);
    }
  }

  public void fftForward() {
    if (listeningToMic) fft.forward(micSignal.mix);
    else fft.forward(player.mix);
  }

  public float getAmplitudeForBand(int band) {
    int lowFreq;
    if ( band == 0 ) {
      lowFreq = 0;
    } else {
      lowFreq = (int)((sampleRate/2) / (float)Math.pow(2, 12 - band));
    }
    int hiFreq = (int)((sampleRate/2) / (float)Math.pow(2, 11 - band));

    // we're asking for the index of lowFreq & hiFreq
    int lowBound = fft.freqToIndex(lowFreq); // freqToIndex returns the index of the frequency band that contains the requested frequency
    int hiBound = fft.freqToIndex(hiFreq);

    // calculate the average amplitude of the frequency band
    float avg = fft.calcAvg(lowBound, hiBound);
    return avg;
  }

  class BeatListener implements AudioListener
  {
    private BeatDetect beat;
    private AudioPlayer source;
    private AudioInput input;

    BeatListener(BeatDetect beat) {
      if (listeningToMic) {
        this.input = micSignal;
        this.input.addListener(this);
      } else
      {
        this.source = player;
        this.source.addListener(this);
      }
      this.beat = beat;
    }

    synchronized void samples(float[] samps)
    {
      if (listeningToMic) {
        beat.detect(micSignal.mix);
      } else {
        checkSource();
        beat.detect(source.mix);
      }
    }

    synchronized void samples(float[] sampsL, float[] sampsR)
    {
      if (listeningToMic) {
        beat.detect(micSignal.mix);
      } else {
        checkSource();
        beat.detect(source.mix);
      }
    }

    synchronized void checkSource() {
      if (!listeningToMic && this.source == null) {
        this.source = sound.player;
        this.source.addListener(this);
      }
    }
  }
}
