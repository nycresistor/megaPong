class Ball {
  public float speed = 0;
  public float angle = 0;
  public float x = 0;
  public float y = 0;
  public float lastx = 0;
    
  Ball() {
    reset();
  }

  void reset() {    
    lastx = x = buffer.width/2;
    y = buffer.height/2;
    
    if (score.left>14) angle=PI;
    else if (score.right>14) angle=0;
    else {
      angle = PI/6 + random(THIRD_PI);
      if (score.left>score.right) angle=PI-angle;
    }
    constrainAngle();
    
    speed = 2 + random(2);
  }

  void play() {
    if (score.left>14 || score.right>14) return;
    
    lastx = x;
    x = x + cos(angle) * speed;
    y = y + sin(angle) * speed;
    
    if (y > buffer.height) {
      angle = -angle;
      y = buffer.height;
    }
    else if (y < 0) {
      angle = -angle;
      y = 0;
    }
    else if (lastx>buffer.width) {
      println("Score left player");
      score.scoreLeft();
      reset();
    }
    else if (lastx<0) {
      println("Score right player");
      score.scoreRight();
      reset();
    }
  }  
  void draw() {
    buffer.colorMode(HSB, 255);    
    buffer.stroke(frameCount % 255, 255, 200);
    buffer.fill(frameCount % 255, 255, 255);
    buffer.ellipseMode(CENTER);
    buffer.ellipse(x,y,3,3);
    buffer.colorMode(RGB, 255);
  }
  
  void constrainAngle() {    
    // Normalize
    while(angle < 0) angle += TWO_PI;
    while(angle > TWO_PI) angle -= TWO_PI;
    
    // Constrain
    if (angle > HALF_PI && angle < TWO_THIRDS_PI) 
      angle = TWO_THIRDS_PI;
    else if (angle > FOUR_THIRDS_PI && angle < THREE_HALF_PI) 
      angle = FOUR_THIRDS_PI;
    else if (angle > THREE_HALF_PI && angle < FIVE_THIRDS_PI)
      angle = FIVE_THIRDS_PI;
    else if (angle > THIRD_PI && angle < HALF_PI)
      angle = THIRD_PI;
  }  
}

