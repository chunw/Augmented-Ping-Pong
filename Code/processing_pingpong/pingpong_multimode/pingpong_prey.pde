/* "Active mode" visualization.
* Force system inspired by Diana Lange's fish sketch.
*/
import processing.serial.*;

int PREDATOR = 1;
int TARGET = 2;

float predator_radius = 40;
float target_radius = 10;

ArrayList<Creature> creatures;
ArrayList<Wall> walls;

float creatureMaxSpeed = 4;
float creatureMaxForce = 0.2;

float wallx1, wallx2, wally1, wally2;
boolean creatingWall = false;
boolean wallBuildingMode = false;
int snap = 32;

void setupMode_prey() {
  creatures = new ArrayList<Creature>();
  walls = new ArrayList<Wall>();
  for (int i = 0; i < 16; i++) {
    creatures.add(new Creature(random(snap, width-snap), random(snap, height-snap), PREDATOR, predator_radius));
  }
  if (player != null) {
    player.close();
  }
  player = minim.loadFile("Ping Pong Song.mp3");
  player.play();
}

void drawMode_prey() {
  background(Params.prey_mode_score_board_bg_color);
  if (keyPressed) {
    if (key == 'w') {
      wallBuildingMode = true;
    }
    if (key == 'q') {
      wallBuildingMode = false;
      creatingWall = false;
    }
  }

  if (wallBuildingMode) {
    stroke(0);
    float snapX = round(mouseX/snap)*snap;
    float snapY = round(mouseY/snap)*snap;
    line(snapX-snap/2, snapY, snapX+snap/2, snapY);
    line(snapX, snapY-snap/2, snapX, snapY+snap/2);
  }

  Creature c;
  for (int i = 0; i < creatures.size (); i++) {
    c = creatures.get(i);
    c.apply(creatures, walls);
    c.update();
    c.display();
  }

  for (Wall w : walls) {
    w.display();
  }
  if (creatingWall == true) {
    line(wallx1, wally1, mouseX, mouseY);
  }

  drawText();

  if (ballPosition != null && sensor.isRealHit()) {
    drawBallPosition();
    addTarget(ballPosition.x, ballPosition.y);
  }

  if (mousePressed) {
    if (wallBuildingMode == false) {
      addTarget(mouseX, mouseY);
    } else {
     if (creatingWall == false) {
        creatingWall = true;
        wallx1 = mouseX;
        wally1 = mouseY;
      } else {
        wallx2 = mouseX;
        wally2 = mouseY;
        if ( (abs(wally2-wally1) > snap) || (abs(wallx2-wallx1) > snap) ) {
          creatingWall = false;
          walls.add(new Wall(wallx1, wally1, wallx2, wally2));
        }
      }
    }
  }
}

void drawBallPosition() {
  noFill();
  stroke(200, 100, 100, 200);
  ellipse (ballPosition.x, ballPosition.y, 44, 44);
  ellipse (ballPosition.x, ballPosition.y, 43, 43);
  ellipse (ballPosition.x, ballPosition.y, 42, 42);
  ellipse (ballPosition.x, ballPosition.y, 41, 41);
  ellipse (ballPosition.x, ballPosition.y, 40, 40);
}

void addRandomPrey() {
  creatures.add(new Creature(random(snap, width - snap), random(snap, height-snap), TARGET, target_radius) );
}

void addTarget(float x, float y) {
  if ( detectTarget(x, y) == false ) { // targets shouldn't overlap
    creatures.add(new Creature(x, y, TARGET, target_radius) );
  }
}

boolean detectTarget(float x, float y) {
  float targetSeparation, xd, yd;
  PVector theTarget;
  for (int i = 0; i < creatures.size (); i++) {
    theTarget = creatures.get(i).getLoc();
    targetSeparation = target_radius *target_radius;
    xd = (x - theTarget.x);
    yd = (y - theTarget.y);
    if ((xd*xd + yd*yd) <= targetSeparation) { // target has been eaten
      return true;
    }
  }
  return false;
}

class Wall {
  PVector loc1, loc2;
  color wallColor;

  Wall(float x1, float y1, float x2, float y2) {
    wallColor = color(127);
    loc1 = new PVector(round(x1/snap)*snap, round(y1/snap)*snap);
    loc2 = new PVector(round(x2/snap)*snap, round(y2/snap)*snap);
  }

  void display() {
    stroke(255);
    strokeWeight(10);
    line(loc1.x, loc1.y, loc2.x, loc2.y);
  }
}

class Creature {
  PVector loc, velocity, acceleration;
  float r, maxforce, maxspeed;
  color bodyColor;
  int numMembranes;
  float[] membraneLocX, membraneLocY, membraneDeviation;
  int type;

  Creature(float x, float y, int theType, float radius) {
    loc = new PVector(x, y);
    r = radius;
    maxspeed = creatureMaxSpeed;
    maxforce = creatureMaxForce;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    numMembranes = 32;
    type = theType;

    float r = random(255);
    float g = random(255);
    float b = random(255);
    bodyColor = color(r, g, b);
    if (theType == TARGET) {
      bodyColor = color(0, random(200, 255), 0);
      maxforce /= 4;
      maxspeed /= 4;
      numMembranes /= 2;
    }
    membraneDeviation = new float[numMembranes];
    membraneLocX = new float[numMembranes];
    membraneLocY = new float[numMembranes];

    for (int i = 0; i < numMembranes; i++) {
      membraneDeviation[i] = 0.0;
      float angle = i * (360 / numMembranes);
      membraneLocX[i] = cos(radians(angle));
      membraneLocY[i] = sin(radians(angle));
    }
  }

  PVector getClosestTarget(ArrayList<Creature> creatures, PVector currentLocation, int myType) {
    PVector theTarget;
    PVector closestTarget = null;
    float d;
    float closest = 1000000000000000.0;
    for (int i = 0; i < creatures.size (); i++) {
      theTarget = creatures.get(i).getLoc();
      d = theTarget.dist(currentLocation, theTarget);
      if (d < closest) {
        if (myType != creatures.get(i).type) {
          closestTarget = theTarget;
          closest = d;
        }
      }
    }
    return closestTarget;
  }

  PVector getLoc() {
    return loc;
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void apply(ArrayList<Creature> creatures, ArrayList<Wall> walls) {
    PVector separateForce = getSeparateForce(creatures, walls);
    PVector closestTarget = getClosestTarget(creatures, loc, type);
    if (closestTarget == null) {
      closestTarget = loc;
    }
    PVector seekForce = getSeekForce(closestTarget);
    separateForce.mult(2);
    seekForce.mult(1);
    applyForce(separateForce);
    applyForce(seekForce);
  }

  PVector getSeekForce(PVector targetLoc) {
    PVector desired = PVector.sub(targetLoc, loc);
    desired.normalize();
    desired.mult(creatureMaxSpeed);
    PVector force = PVector.sub(desired, velocity);
    force.limit(maxforce);
    if (type == TARGET) {
      force.mult(-1.0);
    }
    return force;
  }

  PVector getSeparateForce(ArrayList<Creature> creatures, ArrayList<Wall> walls) {
    float targetSeparation = r*2;
    PVector sum = new PVector();
    int count = 0;
    Creature other;
    for (int i = 0; i < creatures.size(); i++) {
      other = creatures.get(i);
      float d = PVector.dist(loc, other.loc);
      targetSeparation = r + other.r;
      if ((d > 0) && (d < targetSeparation) ) {
        if (type == other.type) {
          PVector diff = PVector.sub(loc, other.loc);
          diff.normalize();
          diff.div(d);
          sum.add(diff);
          count++;
        } else if ( (type == PREDATOR) && (other.type == TARGET) ) { // eat the target
          creatures.remove(i);
        }
      }
    }

    targetSeparation = r;
    PVector closest;
    for (Wall w : walls) {
      closest = findClosestPointToCenter(w.loc1.x, w.loc1.y, w.loc2.x, w.loc2.y, loc.x, loc.y);
      float d = closest.dist(loc, closest);
      if ( d <= targetSeparation ) {
        PVector diff = PVector.sub(loc, closest);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(creatureMaxSpeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }

  void update() {
    velocity.add(acceleration);
    if (type == PREDATOR) {
      velocity.limit(creatureMaxSpeed);
    } else if (type == TARGET) {
      velocity.limit(creatureMaxSpeed / 4);
    }
    loc.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    fill(bodyColor);
    stroke(0);
    strokeWeight(1);
    pushMatrix();

    translate(loc.x, loc.y);
    float theta = velocity.heading2D() + radians(90);
    rotate(theta);
    beginShape();
    float len = 0;
    float deviation = 0;
    float locX, locY;

    // draw the body
    for (int i = 0; i < numMembranes; i++) {
      deviation = membraneDeviation[i];
      deviation += r*0.05*random(-1, 1);
      deviation *= 0.95;
      membraneDeviation[i] = deviation;
      len = r + deviation;
      locX = membraneLocX[i];
      locY = membraneLocY[i];
      vertex(len*locX, len*locY);
    }
    endShape(CLOSE);
    // draw the eyes
    stroke(0);
    int eyeIndex = round(numMembranes*5/8);
    float eyeDistance = 0.6;
    len = r + membraneDeviation[eyeIndex];
    locX = membraneLocX[eyeIndex];
    locY = membraneLocY[eyeIndex];
    fill(255);
    ellipse(len*locX*eyeDistance, len*locY*eyeDistance, len/1.5, len/1.5);
    fill(0);
    ellipse(len*locX*eyeDistance, len*locY*eyeDistance, len/(4+(1-type)*4), len/(4+(1-type)*4));
    eyeIndex = round(numMembranes*7/8);
    len = r + membraneDeviation[eyeIndex];
    locX = membraneLocX[eyeIndex];
    locY = membraneLocY[eyeIndex];
    fill(255);
    ellipse(len*locX*eyeDistance, len*locY*eyeDistance, len/1.5, len/1.5);
    fill(0);
    ellipse(len*locX*eyeDistance, len*locY*eyeDistance, len/(4+(1-type)*4), len/(4+(1-type)*4));
    popMatrix();
  }
}

// helper method
PVector findClosestPointToCenter(float x1, float y1, float x2, float y2, float cx, float cy) {
  float dx, dy, sLength, sx, sy, pLength;
  dx = x2-x1;
  dy = y2-y1;
  sLength = sqrt(dx*dx + dy*dy);
  sx = dx/sLength;
  sy = dy/sLength;
  pLength = (cx-x1)*sx + (cy-y1)*sy;

  if (pLength < 0) {
    return new PVector(x1, y1);
  } else if (pLength > sLength) {
    return new PVector(x2, y2);
  }
  return new PVector(x1 + sx*pLength, y1 + sy * pLength);
}