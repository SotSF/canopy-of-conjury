# canopy-of-conjury
This repository houses the code for the "Canopy of Luminous Conjury" project, including the simulator, Kinect interfacing, and other miscellaneous cyphers.

# Required Libraries
Easy to install through the Processing editor, through Sketch > Import Library... > Add Library...
- [PeasyCam](http://mrfeinberg.com/peasycam/)
- [Minim](http://code.compartmental.net/tools/minim/)
- [Processing Video](https://processing.org:8443/reference/libraries/video/index.html)
- [ControlP5](http://www.sojamo.de/libraries/controlP5/)
- PixelPusher
- [GifAnimation](https://github.com/01010101/GifAnimation) <-- unzip, and drop the `GifAnimation-master` folder into your Processing > libraries folder. Rename `GifAnimation-master` --> `GifAnimation`. Will require you to restart the Processing GUI.

# Overview
The `Strip` class is a virtual LED strip, containing `color[] leds`. These control the simulator display, and the colors stored in each virtual strip will be pushed to their corresponding strip through the PixelPusher.

All Patterns must `extend Pattern` which `implements IPattern`. 

The `IPattern` interface contains three methods: `run()`, `runDefault()` for animating without audio, and `visualize()` for audio visualization. The Pattern’s `.run(Strip[] strips)` function manipulates the colors in each strip’s `color[] leds`. The Pattern parent class selects whether or not to play the default pattern `runDefault()` or to audio `visualize()` based on whether or not an audio file is playing or if we are listening for microphone input. The default `visualize()` just calls `runDefault()` if you aren't planning to implement audio visualization in your pattern. 

You can draw patterns on the PixelPusher by manipulating the virtuals Strips and their leds directly, as simple as `strips[0].leds[0] = color(255,0,0);`.

## Drawing to Canvas to PixelPusher with CartesianPattern

There is a `CartesianPattern` class which contains some helper methods for drawing functions in the Cartesian plane and then mapping those pixels to the Canopy coordinates. This is an extension of Pattern.

An extension of the `CartesianPattern`, e.g.

```java
MyPattern extends CartesianPattern
```

CartesianPatterns have a `PGraphics` object called `image`. We use `image` as a canvas to draw on in 2D space, and this image is then scraped and transformed to fit the Canopy.

```java
image.beginDraw();
/* All image drawing must be wrapped in a `.beginDraw()` and `.endDraw()` 
image.endDraw();
```

With this `image`, we can draw as if we were drawing straight to the Processing sketch window - only need to prepend `image`, e.g.,

```java
image.beginDraw();
image.background(0); // reset our canvas to black, i.e., wipe the image from the last `draw()` call
image.noStroke();
image.fill(color(255,0,0));
image.ellipse(image.width / 2, image.height / 2, 50, 50);
image.endDraw();
scrapeImage(image.get(), strips);
```

The image is scraped after the draw, and applied to the virtual LED strips.

## Sound Reactivity
We make use of the Minim library and its fast Fourier transform methods to analyze audio sources. There's good reading on the [Minim website](http://code.compartmental.net/2007/03/21/fft-averages/) if you're interested in how it works. For our purposes, we're looking at 12 logarithmically spaced averaged bands, each of which corresponds to an octave.

Using `getAmplitudeForBand(int band)`, we can get the average amplitude of each octave as a `float` value, and use that value to control anything we can think of--color values, including hue and brightness; sizes of objects; positions of objects; and so on. We're most interested in bands 5 through 11, with 5-7 corresponding to "bass-y", 8 and 9 to mids, and 10 and 11 to "treble-y". I've found it is enough to use just 7 for bass and 11 for treble visualization.

### visualize()-ing
The `Pattern` parent class contains a BeatListener object, which is a Minim audio listener that holds onto our sample buffers as we receive them from our audio source. It contains some `samples()` methods which are `synchronized` to our `visualize()` method to prevent our waveform from being made up of two different buffers. The `run()` method takes care of setting up our `BeatListener` and calling `fftFoward()` which performs the fast Fourier transform analysis on our audio source samples.

Using the `getAmplitudeForBand()` method, we can then get values to manipulate our drawing, and visualize the audio source.

```java
synchronized void visualize(Strip[] strips) {
 colorMode(HSB, 360);
 for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - each corresponds to an octave
    float amplitude = getAmplitudeForBand(i);
    // if the amplitude of a given octave is greater than 10, save it for later
    // we'll be using our amplitudes to control the brightness of an object
    if (amplitude > 10) { 
      brightness[i] = round(amplitude * 10); 
    }
  }
  image.beginDraw();
  image.clear();
  image.background(0);
  image.translate(dimension/2, dimension/2);
  for (int i = 0; i < 12; i++) {  // 12 frequency bands/ranges - these correspond to an octave
    float amplitude = getAmplitudeForBand(i);
    image.rotate(2 * PI / 12);
    if (amplitude > 10) { 
      brightness[i] = round(amplitude * 10);
    }
    // set the color based on octave i and it's corresponding brightness determined from amplitude
    image.fill(color(360 / 12 * i, 360, brightness[i]));
    image.noStroke();
    image.ellipse(0, 150, 80, 80);
    brightness[i] -= 50;
  }
  image.endDraw();
  scrapeImage(image.get(), strips);
  colorMode(RGB, 255);
}
```

The code above is available in `PatternBeatTest.pde`. It's typically enough to `getAmplitudeForBand(7)` for bass-y values and `getAmplitudeForBand(11)` for treble-y values, depending on what you're trying to animate.
