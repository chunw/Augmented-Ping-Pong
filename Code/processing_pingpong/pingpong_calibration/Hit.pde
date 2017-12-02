class Hit {
  float x;
  float y;
  
  Hit(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  PVector getPixelVector_raw() {
    return new PVector(x, y);
  }
}