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

int w = 1280, h = 720;

int rowCount;
int colCount;
float[] x, y, z; // three data sets I'm using to
String[] labels;
String onRunTime;

int cur = 1;

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
float[] cameraValuesLo = {
  0, 0, 0, 0, 0, 0, 0, 0, -1.0
};
float[] cameraValuesHi = {
  w, w, w / tan(PI*30.0 / 180.0), w, w, w, 1.0, 1.0, 1.0
};

String[] lines;
String[][] csv;
int csvWidth = 0;

void setup() {
  // sketch initialization
  size(w, h, P3D);
  smooth();
  noStroke();
  colorMode(HSB, 360);
  // prepare data
  createSaveTable();
  loadData("salary.tsv");
  lines = loadStrings(dataPath("animation/20130327_015220_cameraPoints.csv"));
  for (int i = 0; i < lines.length; i++) {
    String [] chars = split(lines[i], ",");
    if (chars.length > csvWidth) {
      csvWidth = chars.length;
    }
  }
  csv = new String [lines.length][csvWidth];
  for (int i = 0; i < lines.length; i++) {
    String [] temp = new String [lines.length];
    temp= split(lines[i], ",");
    for (int j = 0; j < temp.length; j++) {
      csv[i][j] = temp[j];
    }
  }
  onRunTime = timestamp();
  scrollbars = new Scrollbar[cameraNames.length];
  for (int i = 0; i < scrollbars.length; i++) {
    scrollbars[i] = new Scrollbar(0, i * 20 + 20, width/2, 15, 8, scrollbars, cameraNames[i], cameraValuesLo[i], cameraValuesHi[i]);
  }
}

void draw() {
  background(300);
  // allow for interactive camera via mouse position
  setCamera();
  camera(cameraValues[0], cameraValues[1], cameraValues[2], cameraValues[3], cameraValues[4], cameraValues[5], cameraValues[6], cameraValues[7], cameraValues[8]);
  lights();
  directionalLight(255, 255, 255, 0, 0, 1);
  drawAxes();
  drawData();

  // 2D code goes here
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  if (showGUI) drawScrollbars();
  hint(ENABLE_DEPTH_TEST);
}

void setCamera() {
  for (int i = 0; i < scrollbars.length; i++) {
    cameraValues[i] = scrollbars[i].getValue();
  }
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
      cur = constrain(--cur, 1, lines.length);
      if (test != cur) {
        for (int i = 0; i < csvWidth; i++) {
          scrollbars[i].setValue(parseFloat(csv[cur][i]));
        }
      }
    }
    if (keyCode == RIGHT) {
      int test = cur;
      cur = constrain(++cur, 1, lines.length - 1);
      if (test != cur) {
        for (int i = 0; i < csvWidth; i++) {
          scrollbars[i].setValue(parseFloat(csv[cur][i]));
        }
      }
    }
  }
  if (key == 's' || key == 'S') {
    TableRow newRow = saveTable.addRow();
    for (int i = 0; i < cameraNames.length; i++) {
      newRow.setFloat(cameraNames[i], cameraValues[i]);
    }
    saveTable(saveTable, "data/animation/" + onRunTime + "_cameraPoints.csv");
  }
  if (key == 'h' || key == 'H') showGUI = !showGUI;
}

void createSaveTable() {
  saveTable = createTable();
  for (int i = 0; i < cameraNames.length; i++) {
    saveTable.addColumn(cameraNames[i]);
  }
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
    if (dist(mouseX, mouseY, screenX(tx, ty, tz), screenY(tx, ty, tz)) < sz) fill(hue, 360, 360, 220);
    else fill(hue, 360, 360);
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

