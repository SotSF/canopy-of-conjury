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
The `Strip` class is a virtual LED strip, containing `color[] leds`. These control the simulator display, and will be used to push colors to the PixelPusher outputs (this code is still pending!) -- we’ll probably need to rename this to avoid confusion with the PixelPusher `Strip` class.

All Patterns must `extend Pattern` which `implements IPattern`. 

The `IPattern` interface contains only three methods: `run()`, `runDefault()` for animating without audio, and `visualize()` for audio visualization. The default `visualize()` just calls `runDefault()` if you aren't planning to implement audio visualization in your pattern. 


The Pattern’s `.run(Strip[] strips)` function manipulates the colors in each strip’s `color[] leds`. By default, the Pattern parent class selects whether or not to play the default pattern or to audio visualize based on whether or not an audio file is playing or if we are listening for microphone input.

There is a `CartesianPattern` class which contain some helper methods for drawing functions in the Cartesian plane and then mapping those colors to the Canopy coordinates. This is an extension of Pattern.

An extension of the `CartesianPattern`, e.g.

```java
MyPattern extends CartesianPattern
```

NOTE: `CartesianPattern`s can’t be “drawn” directly to the window (from what I can tell??). You have to directly `set(x,y,color)`. I.e., using the built-in `ellipse(x,y,width,height)` Processing function won’t work (yet!).

`CartesianPattern`s must call `scrapeWindow()` in their `run()` functions.

