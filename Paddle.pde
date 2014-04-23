class Paddle {
  float x;
  float y;
  float len;
  Float hit;
  char up;
  char down;
  
  Paddle(float x, char up, char down) {
    this.x = x;
    this.y = buffer.height/2;
    this.len = buffer.height/4;
    this.up = up;
    this.down = down;
  }

  void play() {
      // Controls handling
    if (keyPressed && key == up) {
      y -= 1.5;
      if (y<0) y=0;
    }
    else if (keyPressed && key == down) {
      y += 1.5;
      if (y>buffer.height) y=buffer.height;
    }
  
    // If we hit the ball, reverse, speed up, and tweak angle
    hit = this.hit();
    if (hit != null) {
      ball.angle = PI-ball.angle;
      ball.speed *= 1.1;
      ball.angle -= PI/4 * hit;
      ball.constrainAngle();
      
      if (this.x < buffer.width/2) 
        ball.lastx = ball.x = this.x + 2;
      else 
        ball.lastx = ball.x = this.x - 2;   
    } 
  }
  
  void draw() {
    buffer.fill(255);
    buffer.stroke(200);
    buffer.rectMode(CENTER);
    buffer.rect(x,y,2,len,2);
  }
  
  // Returns between -1.0 and 1.0 representing where the paddle strikes the ball, returns null otherwise.  
  Float hit() {
    if (ball.x >= this.x && ball.lastx <= this.x ||
       ball.x <= this.x && ball.lastx >= this.x)
    {
      if (ball.y >= this.y - len/2 && ball.y <= this.y + len/2) {
        return (ball.y - this.y) / (len/2);  
      }
    }
    
    return null;
  }
}

