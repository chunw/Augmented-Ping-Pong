import processing.serial.*;
 
BallPositionSensor sensor;

ParticleSystem ps;
PVector destPosition;
float rho = 1;

PVector ballPosition = new PVector(0, 0);

void setup() {
  size(1900, 900);
  //fullScreen();
  
  colorMode(RGB, 255, 255, 255, 100);
  background(0);

  PImage mask = loadImage("texture.gif");
  PImage img = new PImage(mask.width, mask.height);
  for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = color(255);
  img.mask(mask);
  ps = new ParticleSystem(0, new PVector(width/2, height/2),img);
  
  destPosition = ps.getOrigin();;
  smooth();
  
  sensor = new BallPositionSensor(this);
}

void draw() {
  background(0);
  
  noFill();
  stroke(200, 100, 100, 200);
  ellipse (destPosition.x, destPosition.y, 44, 44);
  ellipse (destPosition.x, destPosition.y, 43, 43);
  ellipse (destPosition.x, destPosition.y, 42, 42);
  ellipse (destPosition.x, destPosition.y, 41, 41);
  ellipse (destPosition.x, destPosition.y, 40, 40);
  PVector origin = ps.getOrigin();
  
  Hit ballLocation = sensor.readHit();
  if (ballLocation != null && sensor.isRealHit()) {
    rho = 1;
    destPosition = ballLocation.getPixelVector_raw(); 
  }
  
  if (origin.x != destPosition.x) {
    ps.setOrigin(new PVector(origin.x*rho + (1-rho) * destPosition.x, origin.y*rho + (1-rho) * destPosition.y));
    rho -= 0.02;
    float dx = (origin.x - destPosition.x)/500;
    float dy = (origin.y - destPosition.y)/500;
    PVector wind = new PVector(dx,dy,0); 
    ps.add_force(wind);
  }
  
  ps.run();
  for (int i = 0; i < 10; i++) {
    ps.addParticle();
  }
}

void mouseClicked() {
   destPosition = new PVector(mouseX, mouseY);
   rho = 1;
}