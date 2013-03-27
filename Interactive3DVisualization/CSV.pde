class CSV {

  String[] lines;
  String[][] csv;
  int csvWidth = 0;
  String filepath;

  CSV(String filepath) {
    this.filepath = filepath;
    parseCSV();
  }

  void parseCSV() {
    lines = loadStrings(filepath); // load CSV file
    // split by comma delimiter
    for (int i = 0; i < lines.length; i++) {
      String [] chars = split(lines[i], ",");
      if (chars.length > csvWidth) {
        csvWidth = chars.length;
      }
    }
    // create a 2D array based on the size of the csv row length and column length
    csv = new String [lines.length][csvWidth];
    for (int i = 0; i < lines.length; i++) {
      String [] temp = new String [lines.length];
      temp = split(lines[i], ",");
      for (int j = 0; j < temp.length; j++) {
        csv[i][j] = temp[j];
      }
    }
  }
  
  
  
  int getRowCount() {
    return lines.length;
  }
  
  int getColumnCount() {
    return csvWidth;
  }
  
  float getFloat(int col, int row) {
    return parseFloat(csv[col][row]);
  }
  
  int getInt(int col, int row) {
    return parseInt(csv[col][row]);
  }
  
  String getString(int col, int row) {
    return csv[col][row];
  }
  
}

