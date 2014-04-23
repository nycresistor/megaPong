import oscP5.*;
import netP5.*;
import hypermedia.net.*;

int ZOOM = 2;
float THIRD_PI = PI/3;
float THREE_HALF_PI = 3*PI/2;
float TWO_THIRDS_PI = 2*PI/3;
float FOUR_THIRDS_PI = 4*PI/3;
float FIVE_THIRDS_PI = 5*PI/3;

Ball ball;
Paddle lPad;
Paddle rPad;
Starfield starfield;
Score score;
PGraphics buffer;
LEDDisplay display;

void setup() {
  frameRate(30);
  size(512*ZOOM,64*ZOOM);
  buffer = createGraphics(512,64);
  
  score = new Score();
  score.left=14; score.right=14;
  ball = new Ball();
  lPad = new Paddle(5,'q','a');
  rPad = new Paddle(buffer.width-7,'o','l');
  starfield = new Starfield();
  display = new LEDDisplay(this, buffer, 512, 64, 49153, true, "127.0.0.1", 9999);
}

void draw() {
  buffer.beginDraw();
  buffer.background(0);

  lPad.play();
  rPad.play();
  ball.play();
  
  starfield.draw();  
  ball.draw();
  lPad.draw();
  rPad.draw();
  score.draw();
  
  /*
  // Blank the middle to simulate actual gameplay
  buffer.noStroke();
  buffer.fill(50);
  buffer.rectMode(CENTER);
  buffer.rect(buffer.width/2, buffer.height/2, buffer.width/2, buffer.height);
  */
  buffer.endDraw();
  
  if (frameCount % 240 == 0) {
    println(frameRate);
  }
  
  image(buffer, 0, 0, width, height);
  
  display.sendData();
}

