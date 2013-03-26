class Scrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean press;
  boolean locked = false;
  boolean otherslocked = false;
  float ratio;
  float scrollbarMult, scrollbarActiveMult, scrollbarInactiveMult;
  float valueMult, valueInactiveMult, valueActiveMult;
  Scrollbar[] others;
  String id;
  PFont font;

  Scrollbar (float xp, float yp, int sw, int sh, int l, Scrollbar[] others, String id) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    this.others = others;
    this.id = id;

    Ani.init(Interactive3DVisualization.this);
    scrollbarActiveMult = .3;
    scrollbarInactiveMult = .86;
    scrollbarMult = scrollbarInactiveMult;

    valueInactiveMult = .05; 
    valueActiveMult = .97; 
    valueMult = valueInactiveMult;
    
    font = loadFont("Inconsolata.vlw");
    textFont(font);
  }

  void update() {
    // first test to see if the other scrollbars are being hovered over
    for (int i = 0; i < others.length; i++) {
      if (others[i].locked == true) {
        otherslocked = true;
        break;
      } 
      else {
        otherslocked = false;
      }
    }

    if (otherslocked == false) {
      overEvent();
      pressEvent();
    }

    if (locked) newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    if (abs(newspos - spos) > 1) spos = spos + (newspos-spos)/loose;
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  void overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      over = true;
    } 
    else {
      over = false;
    }
  }

  void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
    } 
    else {
      press = false;
    }
  }

  void releaseEvent() {
    locked = false;
  }

  void display() {
    noStroke();
    fill(204, 50);
    rect(xpos, ypos, swidth - sheight, sheight, 2);
    if (over || locked) {
      fill(148, 360*.49, 360*scrollbarMult);
      Ani.to(this, 0.3, "scrollbarMult", scrollbarActiveMult);
    } 
    else {
      fill(148, 360*.49, 360*scrollbarMult);
      Ani.to(this, 0.3, "scrollbarMult", scrollbarInactiveMult);
    }
    rect(xpos, ypos, spos, sheight, 2);
    // display the scrollbar ID and value ideally
    displayText();
  }

  private void displayText() {
    textSize(14);
    if (over || locked) {
      fill(150, 0, 360*valueMult);
      Ani.to(this, 0.3, "valueMult", valueActiveMult);
    } 
    else {
      fill(150, 0, 360*valueMult);
      Ani.to(this, 0.3, "valueMult", valueInactiveMult);
    }
    text(id, sposMin + 4, ypos + sheight/2 + textAscent()/2);
    fill(150, 0, 360*valueInactiveMult);
    text(map(getPos(), 0, width, 0, 1), sposMax, ypos + sheight - (textDescent() + textAscent())/2);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}

