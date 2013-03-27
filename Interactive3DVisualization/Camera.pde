class Camera {
  int numParameters = 9;
  String[] id = {
    "eyeX", "eyeY", "eyeZ", "centerX", "centerY", "centerZ", "upX", "upY", "upZ"
  };
  float[] lo = {
    0, 0, 0, 0, 0, 0, -1.0, -1.0, -1.0
  };
  float[] hi = {
    w, w, w / tan(PI*30.0 / 180.0), w, w, w, 1.0, 1.0, 1.0
  };
  float[] values = new float[numParameters];

  Camera() {
  }

  void update(int i, Scrollbar s) {
    values[i] = s.getValue();
  }

  void display() {
    camera(values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8]);
  }

  String getId(int i) {
    return id[i];
  }

  float getLo(int i) {
    return lo[i];
  }

  float getHi(int i) {
    return hi[i];
  }

  float getValue(int i) {
    return values[i];
  }

  int getLength() {
    return id.length;
  }
}

