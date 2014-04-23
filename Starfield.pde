// Visual effect to show the angle of the incoming ball to the players

class Starfield {
  int STARS = 200;
  Star[] stars;

  
  class Star {
    float x;
    float y;
    float speed;
    
    Star() {
      x = random(buffer.width);
      y = random(buffer.height);
      speed = 1+random(4);
    }
    
    void draw() {
      x = x + cos(ball.angle) * (ball.speed / speed);
      y = y + sin(ball.angle) * (ball.speed / speed);

      if (x > buffer.width) x = 0;
      else if (x < 0) x = buffer.width;
      
      if (y > buffer.height) y = 0;
      else if (y < 0) y = buffer.height;
      
      buffer.stroke(floor((5-speed)/5*200));
      buffer.point(x,y);
    }
  }


  Starfield() {
    stars = new Star[STARS];
    for (int i=0; i<stars.length; i++) {
      stars[i] = new Star();
    }
  }

  void draw() {
    for (int i=0; i<stars.length; i++) {
      stars[i].draw();
    }
  }
}

