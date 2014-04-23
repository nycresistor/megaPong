class Score {
  PFont font;
  int left;
  int right;
  int counter;
  
  Score() {
    font = loadFont("Disorient-Diamonds-52.vlw");
    reset();
  }
  
  void reset() {
    left = 0;
    right = 0;
    counter = 255;
  }
  
  void display() {
      counter = (left>14 || right>14) ? 2048 : 255;
  }
  
  void draw() {
    if (counter > 0) {
      buffer.textFont(font);
      buffer.textSize(52);
      buffer.textAlign(CENTER,CENTER);
      buffer.colorMode(HSB, 255);
      buffer.fill(counter%255,255,255,counter);

      buffer.text(hex(left).charAt(7), 50, buffer.height/2);
      buffer.text(hex(right).charAt(7), buffer.width-50, buffer.height/2);
      buffer.colorMode(RGB,255);
    }
    else if (score.left>14 || score.right>14) {
      reset();
    }
    
    counter -= 8;
  }
  
  void scoreLeft() {
    left++;
    display();
  }
  
  void scoreRight() {
    right++;
    display();
  }
}


