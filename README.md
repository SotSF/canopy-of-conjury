# canopy-of-conjury
This repository houses the code for the "Canopy of Luminous Conjury" project, including the simulator, Kinect interfacing, and other miscellaneous cyphers.

# Required Libraries
Easy to install through the Processing editor, through Sketch > Import Library... > Add Library...
- [PeasyCam](http://mrfeinberg.com/peasycam/)
- [Minim](http://code.compartmental.net/tools/minim/)

# Overview
The `Strip` class is a virtual LED strip, containing `color[] leds`. These control the simulator display, and will be used to push colors to the PixelPusher outputs (this code is still pending!) -- we’ll probably need to rename this to avoid confusion with the PixelPusher `Strip` class.

All Patterns must `implement Pattern`.

The Pattern’s `.run(Strip[] strips)` function manipulates the colors in each strip’s `color[] leds`.

There is a `CartesianPattern` class which contain some helper methods for drawing functions in the Cartesian plane and then mapping those colors to the Canopy coordinates.

An extension of the `CartesianPattern` must also `implement Pattern`, e.g.

```java
MyPattern extends CartesianPattern implements Pattern
```

NOTE: `CartesianPattern`s can’t be “drawn” directly to the window (from what I can tell??). You have to directly `set(x,y,color)`. I.e., using the built-in `ellipse(x,y,width,height)` Processing function won’t work. I don’t know why yet.

`CartesianPattern`s must call `scrapeWindow()` in their `run()` functions.


We can create Audio Visualizers by extending the `PatternAV` class, and overriding the `visualize(Strip[] strips)` function. This uses the Mimim library for audio processing and stuff. Currently, requires an audio file to work (can’t figure out how to read audio from speaker output line).

