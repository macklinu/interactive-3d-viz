/** 
 * Macklin Underdown
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
Camera cam;
CSV readTable;

int w = 1280, h = 720;

int rowCount;
int colCount;
float[] x, y, z; // three data sets I'm using to
String[] labels;
String onRunTime;

int cur = 1;


float xMin, yMin, zMin;
float xMax, yMax, zMax;
float[] tx, ty, tz;
// camera variables
boolean showGUI = true;
boolean show3D = true;
boolean[] hoverOver;;

void setup() {
  // sketch initialization
  size(w, h, P3D);
  smooth();
  noStroke();
  colorMode(HSB, 360);
  onRunTime = timestamp();
  cam = new Camera();
  scrollbars = new Scrollbar[cam.getLength()];
  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i] = new Scrollbar(width/1.4, i * 20 + height/1.4, width/4, 15, 8, scrollbars, cam.getId(i), cam.getLo(i), cam.getHi(i));
  }

  // prepare data
  createSaveTable();
  loadData("salary.tsv");
  tx = ty = tz = new float[x.length];
  hoverOver = new boolean[x.length];
  readTable = new CSV(dataPath("animation/20130327_015220_cameraPoints.csv"));
}

void draw() {
  background(300);
  if (show3D) {
    for (int i = 0; i < scrollbars.length; i++) cam.update(i, scrollbars[i]);
    cam.display();
    lights();
    directionalLight(255, 255, 255, 0, 0, 1);
    drawAxes();
    drawData();
  }
  // 2D code goes here
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  if (show3D) {
    if (showGUI) {
      drawScrollbars();
    }
    for (int i = 0; i < x.length; i++) {
    if (hoverOver[i] == true) { 
      fill(34, 34, 34);
      textSize(12);
      text(x[i], mouseX, mouseY);
    }
    }
  }
  if (!show3D) {
    stroke(0);
    strokeWeight(2);
    textSize(48);
    text("2D mode", width/2, height/2);
  }
  hint(ENABLE_DEPTH_TEST);
}

void drawScrollbars() {
  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i].update();
    scrollbars[i].display();
  }
}

void mouseReleased() {
  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i].releaseEvent();
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      int test = cur;
      cur = constrain(--cur, 1, readTable.getRowCount());
      if (test != cur) {
        for (int i = 0; i < readTable.getColumnCount(); i++) {
          scrollbars[i].setValue(readTable.getFloat(cur, i));
        }
      }
    }
    if (keyCode == RIGHT) {
      int test = cur;
      cur = constrain(++cur, 1, readTable.getRowCount() - 1);
      if (test != cur) {
        for (int i = 0; i < readTable.getColumnCount(); i++) {
          scrollbars[i].setValue(readTable.getFloat(cur, i));
        }
      }
    }
  }
  if (key == 's' || key == 'S') {
    TableRow newRow = saveTable.addRow();
    for (int i = 0; i < cam.getLength(); i++) {
      newRow.setFloat(cam.getId(i), cam.getValue(i));
    }
    saveTable(saveTable, "data/animation/" + onRunTime + "_cameraPoints.csv");
  }
  if (key == 'h' || key == 'H') showGUI = !showGUI;
  if (key == '3') show3D = !show3D;
}

void createSaveTable() {
  saveTable = createTable();
  for (int i = 0; i < cam.getLength(); i++) {
    saveTable.addColumn(cam.getId(i));
  }
}

void drawAxes() {
  fill(0);
  strokeWeight(1);
  stroke(0, 360, 360, 360);
  line(0, 0, 0, width, 0, 0);
  box(30);
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
    if (dist(mouseX, mouseY, screenX(tx, ty, tz), screenY(tx, ty, tz)) < sz) { // 3D picking
      fill(hue, 360, 360, 220);
      hoverOver[i] = true;
    }
    else { 
      fill(hue, 360, 360);
      hoverOver[i] = false;
    }
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

