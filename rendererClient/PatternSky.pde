class PatternSky extends Pattern {
  ArrayList<Cloud> clouds = new ArrayList<Cloud>();
  ArrayList<Star> stars = new ArrayList<Star>();
  ArrayList<ShootingStar> shooters = new ArrayList<ShootingStar>();
  int numClouds = 10;
  int numStars = 200;
  int starLifespan = 100;
  color morning = #79D1FF;
  color night = #2D2155;
  int time = 200;
  int timer = 0;
  boolean holdSky = false;
  int holdTimer = 0;
  int holdUntil = 50;
  int direction = 1;
  float[] steps = { (red(night) - red(morning))/time, (green(night) - green(morning))/time, (blue(night) - blue(morning))/time };
  void run() {
    clear();
    if (timer == time || timer == 0) {
      holdSky = true;
    }
    color sky = color(red(morning) + steps[0] * timer, green(morning) + steps[1] * timer, blue(morning) + steps[2] * timer);
    background(sky);
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
    
    if (timer > 0 && timer < time * 0.8 && direction == 1) {
      if (clouds.size() < numClouds && random(100) > 30) {
        Cloud cloud = new Cloud(new Position(random(dimension), random(dimension)), int(random(100,300)));
        clouds.add(cloud);
      }
    }
   
    if (timer > time * 0.66 && timer < time) {
      if (stars.size() < numStars) {
        if (random(100) > 50) {
          Star star = new Star(new Position(int(random(dimension)), int(random(dimension))), 10);
          stars.add(star);
        }
        if (random(100) > 95) {
          ShootingStar star = new ShootingStar(new Position(int(random(dimension)), int(random(dimension))), 
                          new Position(int(random(dimension)), int(random(dimension))), int(random(5,9)));
          shooters.add(star);
        }
      }
    }
    
    for (int i = stars.size() - 1; i >= 0; i--) {
      Star star = stars.get(i);
      noStroke();
      fill(color(random(150,255), random(200,220), random(200,255), star.brightness));
      ellipse(star.pos.x, star.pos.y, 10, 10);
      star.update();
      
      if (star.timer >= starLifespan) { stars.remove(star); }
    }
    
    for (int i = shooters.size() - 1; i >= 0; i--) {
      ShootingStar star = shooters.get(i);
      color c = color(random(10,50), random(200,220), random(100,200));
      fill(c);
      noStroke();
      ellipse(star.head.x,star.head.y,20,20);
      star.update();
      if (star.head.x >= star.target.x && star.head.y >= star.target.y) {
        shooters.remove(star);
      }
    }
   
    for (int i = clouds.size() - 1; i >= 0; i--) {
      Cloud cloud = clouds.get(i);
      noStroke();
      
      for (int j = 0; j < cloud.particles.size(); j++) {
        Position p = cloud.particles.get(j);
        float size = cloud.sizes.get(j);
        float brightness = cloud.brightness.get(j);
        fill(color(255,255,255,brightness));
        ellipse(p.x, p.y, size, size);
      }
      cloud.update();
      if (cloud.remove) clouds.remove(i);
    }
    
    //scrapeWindow(strips);
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
    float xstep;
    float ystep;
    int speed;
    ShootingStar(Position p, Position t, int speed) {
      this.head = p;
      this.target = t;
      this.speed = speed;
      this.xstep = (t.x - p.x) / this.speed;
      this.ystep = (t.y - p.y) / this.speed;
    }
    void update() {
      if (target.x > head.x) { 
        head.x += xstep;
        if (head.x >= target.x) head.x = target.x;
      }
      else if (target.x < head.x) { 
        head.x -= xstep;
        if (head.x <= target.x) head.x = target.x;
      }
      if (target.y > head.y) { 
        head.y += ystep;
        if (head.y >= target.y) head.y = target.y;
      }
      else if (target.y < head.y) {
        head.y -= ystep;
        if (head.y <= target.y) head.y = target.y;
      }
    }
  }
  
  private class Cloud {
    ArrayList<Position> particles;
    ArrayList<Float> sizes;
    ArrayList<Float> brightness;
    ArrayList<Integer> direction;
    float speed;
    boolean remove = false;
    Cloud(Position base, int size) {
      speed = random(1); 
      particles = new ArrayList<Position>();
      sizes = new ArrayList<Float>();
      brightness = new ArrayList<Float>();
      direction = new ArrayList<Integer>();
      for (int i = 0; i < size; i++) {
        particles.add(new Position(base.x + i * random(-1,1) / 2, base.y + i * random(-0.5,0.5) / 2 ));
        sizes.add(random(20,40));
        brightness.add(random(3));
        direction.add(1);
      }
    }
    void update() {
      for (int i = 0; i < particles.size(); i++) {
        particles.get(i).x += speed;
        brightness.set(i, brightness.get(i) + direction.get(i) * 0.2);
        if (brightness.get(i) >= 30) direction.set(i, -1);
      }
      remove = true;
      for (int i = 0; i < brightness.size(); i++) {
        if (brightness.get(i) > 0) remove = false;
      }
    }
  }
  
  class Position {
    float x;
    float y;
    Position(float x, float y) {
      this.x = x;
      this.y = y;
    }
  }
}