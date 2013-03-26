/* Macklin Underdown
 * 3D visualization test
 *
 * Data downloaded from http://www-958.ibm.com/software/data/cognos/manyeyes/datasets/umcp-tenure-faculty-mean-salary-us-2/versions/1
 * cleaned up and saved as a ".tsv" file
 * 
 * Data is formatted like so:
 * 
 * College  Assist. Prof. Female Mean Salary (USD)  Assist. Prof. Male Mean Salary (USD)  Assoc. Prof. Female Mean Salary (USD)  Assoc. Prof. Male Mean Salary (USD)  Prof. Female Mean Salary (USD)  Prof. Male Mean Salary (USD)
 * AGNR  84802.40  84218.17  106375.20  93356.97  117593.00  124074.19
 * ARCH  67672.00  69894.50  82941.00  100548.60  113023.00  107422.00
 * ARHU  60549.57  60284.30  73770.50  77839.06  102495.30  100074.24
 *
 * 
 * 
 *
 */
import de.looksgood.ani.*;

FryTable salaryTable; // Processing's built-in Table class (2.0+) wasn't working natively, so I used the one from Ben Fry's Visualizing Data
Table saveTable;
Scrollbar[] scrollbars;
int rowCount;
int colCount;
float[] x, y, z; // three data sets I'm using to
String[] labels;
String onRunTime;

float mx, my, diameter;
float cameraY, fov, cameraZ, aspect;

float xMin, yMin, zMin;
float xMax, yMax, zMax;
// camera variables
float eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ;
boolean showGUI = true;

String[] cameraNames = {
  "eyeX", "eyeY", "eyeZ", "centerX", "centerY", "centerZ", "upX", "upY", "upZ"
};
float[] cameraValues = new float[cameraNames.length];

void setup() {
  size(1280, 720, P3D);
  smooth();
  noStroke();
  colorMode(HSB, 360);
  createSaveTable();
  loadData("salary.tsv");

  mx = my = 0.5;
  fov = mx * PI/2;
  cameraY = height/2.0;
  cameraZ = cameraY / tan(fov / 2.0);
  aspect = float(width)/float(height);

  onRunTime = timestamp();

  scrollbars = new Scrollbar[cameraNames.length];

  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i] = new Scrollbar(0, i * 20 + 20, width/2, 15, 8, scrollbars, cameraNames[i]);
  }

  //eyeX; eyeY; eyeZ; centerX; centerY; centerZ; upX; upY; upZ;
}

void draw() {
  background(300);
  // allow for interactive camera via mouse position
  camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
  //camera(mouseX, height/2, (height/2) / tan(PI/6), mouseX, height/2, 0, 0, 1, 0);
  lights();
  directionalLight(255, 255, 255, 0, 0, 1);

  /*
  pushMatrix();
   translate(0, 0, -700);
   rect(-width, -height, width*2, height*2);
   popMatrix();
   */
  drawAxes();
  drawData();

  // 2D code goes here
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  if (showGUI) drawScrollbars();
  hint(ENABLE_DEPTH_TEST);
}

void drawScrollbars() {
  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i].update();
    scrollbars[i].display();
  }
  //assignScrollbars();
}

/*
// Need to figure out why this won't work
 void assignScrollbar(float in, Scrollbar s) {
 textSize(12);
 fill(20);
 in = constrain(map(s.getPos(), 0, s.sposMax, 0, width), 0, width);
 text(map(in, 0, width, 0, 1), s.sposMax, s.ypos + s.sheight/2);
 }
 */
void assignScrollbars() {
  textSize(12);
  fill(20);
  eyeX = constrain(map(scrollbars[0].getPos(), 0, scrollbars[0].sposMax, 0, width), 0, width);
  text("eyeX", scrollbars[0].sposMin, scrollbars[0].ypos + scrollbars[0].sheight/2 + textAscent()/2);
  text(map(eyeX, 0, width, 0, 1), scrollbars[0].sposMax, scrollbars[0].ypos + scrollbars[0].sheight/2);
  eyeY = constrain(map(scrollbars[1].getPos(), 0, scrollbars[1].sposMax, 0, width), 0, width);
  text("eyeY", scrollbars[1].sposMin, scrollbars[1].ypos + scrollbars[1].sheight/2 + textAscent()/2);
  text(map(eyeY, 0, width, 0, 1), scrollbars[1].sposMax, scrollbars[1].ypos + scrollbars[1].sheight/2);
  eyeZ = constrain(map(scrollbars[2].getPos(), 0, scrollbars[2].sposMax, 0, width / tan(PI*30.0 / 180.0)), 0, width / tan(PI*30.0 / 180.0));
  text("eyeZ", scrollbars[2].sposMin, scrollbars[2].ypos + scrollbars[2].sheight/2 + textAscent()/2);
  text(map(eyeZ, 0, width / tan(PI*30.0 / 180.0), 0, 1), scrollbars[2].sposMax, scrollbars[2].ypos + scrollbars[2].sheight/2);
  centerX = constrain(map(scrollbars[3].getPos(), 0, scrollbars[3].sposMax, 0, width), 0, width);
  text("centerX", scrollbars[3].sposMin, scrollbars[3].ypos + scrollbars[3].sheight/2 + textAscent()/2);
  text(map(centerX, 0, width, 0, 1), scrollbars[3].sposMax, scrollbars[3].ypos + scrollbars[3].sheight/2);
  centerY = constrain(map(scrollbars[4].getPos(), 0, scrollbars[4].sposMax, 0, width), 0, width);
  text("centerY", scrollbars[4].sposMin, scrollbars[4].ypos + scrollbars[4].sheight/2 + textAscent()/2);
  text(map(centerY, 0, width, 0, 1), scrollbars[4].sposMax, scrollbars[4].ypos + scrollbars[4].sheight/2);
  centerZ = constrain(map(scrollbars[5].getPos(), 0, scrollbars[5].sposMax, 0, width), 0, width);
  text("centerZ", scrollbars[5].sposMin, scrollbars[5].ypos + scrollbars[5].sheight/2 + textAscent()/2);
  text(map(centerZ, 0, width, 0, 1), scrollbars[5].sposMax, scrollbars[5].ypos + scrollbars[5].sheight/2);
  upX = constrain(map(scrollbars[6].getPos(), 0, scrollbars[6].sposMax, 0.0, 1.0), 0.0, 1.0);
  text("upX", scrollbars[6].sposMin, scrollbars[6].ypos + scrollbars[6].sheight/2 + textAscent()/2);
  text(upX, scrollbars[6].sposMax, scrollbars[6].ypos + scrollbars[6].sheight/2);
  upY = constrain(map(scrollbars[7].getPos(), 0, scrollbars[7].sposMax, 0.0, 1.0), 0.0, 1.0);
  text("upY", scrollbars[7].sposMin, scrollbars[7].ypos + scrollbars[7].sheight/2 + textAscent()/2);
  text(upY, scrollbars[7].sposMax, scrollbars[7].ypos + scrollbars[7].sheight/2);
  upZ = constrain(map(scrollbars[8].getPos(), 0, scrollbars[8].sposMax, -1.0, 1.0), -1.0, 1.0);
  text("upZ", scrollbars[8].sposMin, scrollbars[8].ypos + scrollbars[8].sheight/2 + textAscent()/2);
  text(upZ, scrollbars[8].sposMax, scrollbars[8].ypos + scrollbars[8].sheight/2);
}

void mouseReleased() {
  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i].releaseEvent();
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) ;
  }
  if (key == 's' || key == 'S') {
    TableRow newRow = saveTable.addRow();
    newRow.setFloat("eyeX", eyeX);
    newRow.setFloat("eyeY", eyeY);
    newRow.setFloat("eyeZ", eyeZ);
    newRow.setFloat("centerX", centerX);
    newRow.setFloat("centerY", centerY);
    newRow.setFloat("centerZ", centerZ);
    newRow.setFloat("upX", upX);
    newRow.setFloat("upY", upY);
    newRow.setFloat("upZ", upZ);
    saveTable(saveTable, "data/animation/" + onRunTime + "_cameraPoints.csv");
  }

  if (key == 'h' || key == 'H') showGUI = !showGUI;
}

void createSaveTable() {
  saveTable = createTable();
  saveTable.addColumn("eyeX");
  saveTable.addColumn("eyeY");
  saveTable.addColumn("eyeZ");
  saveTable.addColumn("centerX");
  saveTable.addColumn("centerY");
  saveTable.addColumn("centerZ");
  saveTable.addColumn("upX");
  saveTable.addColumn("upY");
  saveTable.addColumn("upZ");
}


void rotatePlanes() {
  rotateX(-PI/6* mouseX/float(width));
  rotateY(PI/3 * PI * mouseY/float(height));
  rotateZ(mouseX/float(width) * PI);
}

void drawAxes() {
  fill(0);
  strokeWeight(1);
  stroke(0, 360, 360, 360);
  line(0, 0, 0, width, 0, 0);
  textSize(48);
  text("x", width, 0, 0);
  stroke(127, 360, 360, 360);
  line(0, 0, 0, 0, height, 0);
  text("y", 0, height, 0);
  stroke(255, 360, 360, 360);
  line(0, 0, -height/2, 0, 0, height/2);
  text("z", 0, 0, -height/2);
}

void drawData() {
  for (int i = 0; i < x.length; i++) {
    float tx = map(x[i], xMin, xMax, 0, width);
    float ty = map(y[i], yMin, yMax, 0, height);
    float tz = map(z[i], zMin, zMax, -height/2, height/2);
    int hue = int(map(x[i], xMin, xMax, 200, 50));
    float sz = map(x[i], xMin, xMax, 5, 15);
    pushMatrix();
    noStroke();
    fill(hue, 360, 360);
    ambient(255, 26, 160);
    translate(tx, ty, tz);
    sphere(sz);
    popMatrix();
  }
}

//////////////////////
// HELPER FUNCTIONS //
//////////////////////

void loadData(String filename) {
  xMin = yMin = zMin = MAX_FLOAT;
  xMax = yMax = zMax = MIN_FLOAT;

  salaryTable = new FryTable("salary.tsv"); // load data file
  rowCount = salaryTable.getRowCount(); // get number of rows
  colCount = salaryTable.data[0].length;
  // initialize arrays
  x = y = z = new float[rowCount - 1]; // the first row contains a string, so make the array size one less than that
  labels = new String[colCount];
  // store data in x, y, z arrays
  for (int row = 1; row < rowCount; row++) {
    // starting at row = 1 and using [row - 1] to prevent storing the string that heads each row
    x[row - 1] = salaryTable.getFloat(row, 2);
    y[row - 1] = salaryTable.getFloat(row, 4);
    z[row - 1] = salaryTable.getFloat(row, 6);
  }
  // get labels in case they are used
  for (int col = 0; col < colCount; col++) {
    labels[col] = salaryTable.getString(0, col);
  }
  // find the minimum and maximum values in each data set
  setMinMax();
  /*
  // cannot set Min and Max with this created function
   // not sure why
   findMinMax(x, xMin, xMax);
   findMinMax(y, yMin, yMax);
   findMinMax(z, zMin, zMax);
   */
}

void findMinMax(float[] arr, float minimum, float maximum) {
  for (int i = 0; i < arr.length; i++) {
    float value = arr[i];
    if (value > maximum) maximum = value;
    if (value < minimum) minimum = value;
  }
}

void setMinMax() {
  for (int i = 0; i < x.length; i++) {
    float value = x[i];
    if (value > xMax) xMax = value;
    if (value < xMin) xMin = value;
  }
  for (int i = 0; i < y.length; i++) {
    float value = y[i];
    if (value > yMax) yMax = value;
    if (value < yMin) yMin = value;
  }
  for (int i = 0; i < z.length; i++) {
    float value = z[i];
    if (value > zMax) zMax = value;
    if (value < zMin) zMin = value;
  }
}

String timestamp() {
  String currentTime = str(year()) 
    + nf(month(), 2)
      + nf(day(), 2)
        + "_"
          + nf(hour(), 2)
          + nf(minute(), 2)
            + nf(second(), 2);
  return currentTime;
}

