class PatternSpace extends CartesianPattern {
  ArrayList<Star> stars = new ArrayList<Star>();
  ArrayList<ShootingStar> shooters = new ArrayList<ShootingStar>();
  int numStars = 150;
  int starLifespan = 100;
  color morning = #79D1FF;
  color night = #2D2155;
  int time = 300;
  int timer = 0;
  boolean holdSky = false;
  int holdTimer = 0;
  int holdUntil = 50;
  int direction = 1;
  float[] steps = { (red(night) - red(morning))/time, (green(night) - green(morning))/time, (blue(night) - blue(morning))/time };
  void runDefault(Strip[] strips) {
    clearWindow();
    if (timer == time || timer == 0) {
      holdSky = true;
    }
    color sky = color(red(morning) + steps[0] * timer, green(morning) + steps[1] * timer, blue(morning) + steps[2] * timer);
    if (holdSky) {
      holdTimer += 1;
      if (holdTimer == holdUntil) {
        holdTimer = 0;
        holdSky = false;
      }
    } 
    if (!holdSky) {
       timer += direction;
      if (timer > time) direction = -1;
      else if (timer < 0) direction = 1;
    }
   
    for (Strip s : strips) {
      for (int l = 0; l < NUM_LEDS_PER_STRIP; l++) {
        s.leds[l] = sky;
      }
    }
    if (timer > time * 0.66 && timer < time * 0.90) {
      if (stars.size() < numStars) {
        if (random(100) > 50) {
          Star star = new Star(new Position(int(random(dimension)), int(random(dimension))), 10);
          stars.add(star);
        }
        if (random(100) > 99) {
          ShootingStar star = new ShootingStar(new Position(int(random(dimension)), int(random(dimension))), 
                          new Position(int(random(dimension)), int(random(dimension))), int(random(5,9)));
          shooters.add(star);
        }
      }
    }
    for (int i = stars.size() - 1; i >= 0; i--) {
      Star star = stars.get(i);
      drawPoint(star.pos.x, star.pos.y, color(random(150,255), random(200,220), random(200,255), star.brightness));
      star.update();
      
      if (star.timer >= starLifespan) { stars.remove(star); }
    }
    
    for (int i = shooters.size() - 1; i >= 0; i--) {
      ShootingStar star = shooters.get(i);
      color c = color(random(10,50), random(200,220), random(100,200));
      drawPoint(star.head.x, star.head.y, c);
      drawPoint(star.head.x+2, star.head.y, c);
      drawPoint(star.head.x-2, star.head.y, c);
      drawPoint(star.head.x, star.head.y-2, c);
      drawPoint(star.head.x, star.head.y+2, c);
      star.update();
      if (star.head.x >= star.target.x && star.head.y >= star.target.y) {
        shooters.remove(star);
      }
    }
    
    scrapeWindow(strips);
  }
  
  
  void drawPoint(int x, int y, color c) {
     set(x,y,c);
     set(x, y+1, c);
     set(x,y-1,c);
     set(x+1, y, c);
     set(x-1, y, c);
     set(x+1, y+1, c);
     set(x-1, y+1, c);
  }
  
  private class Star {
    Position pos;
    int brightness;
    int direction = 1;
    int timer;
    Star(Position p, int b) {
      this.pos = p;
      this.brightness = b;
    }
     void update() {
      brightness += 10 * direction;
      if (brightness > 100) direction = -1;
      else if (brightness < 0) direction = 1;
      timer++;
      
      /*
        int x = pos.x - dimension / 2;
        int y = pos.y - dimension / 2;
        float theta = atan2(y,x);
        float rad = sqrt(x * x + y * y);
        theta += radians(1); 
        if (theta > 2 * PI) theta = 0;
        pos.x = round(rad * cos(theta)) + dimension / 2;
        pos.y = round(rad * sin(theta)) + dimension / 2;
      }
      */
    }
  }
  
  private class ShootingStar {
    Position head;
    Position target; 
    int xstep;
    int ystep;
    int speed;
    ShootingStar(Position p, Position t, int speed) {
      this.head = p;
      this.target = t;
      this.speed = speed;
      this.xstep = (t.x - p.x) / this.speed;
      this.ystep = (t.y - p.y) / this.speed;
    }
    void update() {
      if (target.x > head.x) head.x += xstep;
      else if (target.x < head.x) head.x -= xstep;
      if (target.y > head.y) head.y += ystep;
      else if (target.y < head.y) head.y -= ystep;
    }
  }
}