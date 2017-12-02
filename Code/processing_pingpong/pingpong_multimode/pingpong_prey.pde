import processing.serial.*;
 
float creatureMaxSpeed = 2;
 
ArrayList<Creature> creatures;
ArrayList<Wall> walls;

float wallx1, wallx2, wally1, wally2;
boolean creatingWall = false;
boolean wallBuildingMode = false;
int gridSnap = 32;
PFont myFont;

int PREDATOR = 1;
int PREY = 2;

float predator_radius = 40;
float prey_radius = 10;

float LARGENUM = 1000000000000000.0;

void setupMode_prey() {
  creatures = new ArrayList<Creature>();
  walls = new ArrayList<Wall>();
  for (int i = 0; i < 16; i++) {
    creatures.add(new Creature(random(gridSnap, width - gridSnap), random(gridSnap, height-gridSnap), PREDATOR, predator_radius) );
  }
  if (soundfile != null) {
    soundfile.stop();
  }
  soundfile = new SoundFile(this, "Ping Pong Song.mp3");
  soundfile.loop();
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

  if ( wallBuildingMode == true ) {
    stroke(0);
    float snapX = round(mouseX/gridSnap)*gridSnap;
    float snapY = round(mouseY/gridSnap)*gridSnap;
    line(snapX-gridSnap/2, snapY, snapX+gridSnap/2, snapY);
    line(snapX, snapY-gridSnap/2, snapX, snapY+gridSnap/2);
  }

  Creature c;
  for (int i = 0; i < creatures.size (); i++) {
    c = creatures.get(i);
    c.applyBehaviors(creatures, walls);
    c.update();
    c.display();
    // if creature falls outside then kill it
    /*PVector theLoc = c.getLoc();
    if ( (theLoc.x < gridSnap) || (theLoc.x > (width-gridSnap)) || (theLoc.y < gridSnap) || (theLoc.y > (height-gridSnap)) ) {
      creatures.remove(i);
    }*/
  }

  for (Wall w : walls) {
    w.display();
  }

  if (creatingWall == true) {
    //strokeWeight(10);
    //stroke(Params.prey_mode_wall_color);
    line(wallx1, wally1, mouseX, mouseY);
  }

  drawText();
  
  // NOTE: DO NOT READ SENSOR DATA IN THIS SKETCH; IT HAS BEEN READ IN THE MAIN SKETCH DRAW() LOOP!
  
  //println("in pinpong_prey: sensor.isRealHit()? + " + sensor.isRealHit() + " ballloc is not null? " + (ballPosition != null));
  if (ballPosition != null && sensor.isRealHit()) {
    drawBallPosition();
    //println("added target at x = " + ballPosition + " y = " + ballPosition.y);
    addTarget(ballPosition.x, ballPosition.y); // TODO - randomize a little bit
    //creatures.add(new Creature(random(gridSnap, width - gridSnap), random(gridSnap, height-gridSnap), PREDATOR, predator_radius) );
  }
  
  if (mousePressed) {
    if (wallBuildingMode == false) {
      addTarget(mouseX, mouseY);
      creatures.add(new Creature(random(gridSnap, width - gridSnap), random(gridSnap, height-gridSnap), PREDATOR, predator_radius) );
    } else {
     if (creatingWall == false) {
        creatingWall = true;
        wallx1 = mouseX;
        wally1 = mouseY;
      } else {
        wallx2 = mouseX;
        wally2 = mouseY;
        if ( (abs(wally2-wally1) > gridSnap) || (abs(wallx2-wallx1) > gridSnap) ) {
          creatingWall = false;
          walls.add( new Wall(wallx1, wally1, wallx2, wally2) );
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

void mousePressed() {
   
}

void addRandomPrey() {
  creatures.add(new Creature(random(gridSnap, width - gridSnap), random(gridSnap, height-gridSnap), PREY, prey_radius) );
}

void addTarget(float x, float y) {
  if ( detectTarget(x, y) == false ) { // targets shouldn't overlap
    creatures.add(new Creature(x, y, PREY, prey_radius) );
  }
}

boolean detectTarget(float x, float y) {
  float desiredseparation, xd, yd;
  PVector theTarget;
  // For every boid in the system, check if it's too close
  for (int i = 0; i < creatures.size (); i++) {
    theTarget = creatures.get(i).getLoc();
    desiredseparation = prey_radius*prey_radius;
    xd = (x - theTarget.x);
    yd = (y - theTarget.y);
    if ((xd*xd+yd*yd) <= desiredseparation) { // target has been eaten
      return true;
    }
  }
  return false;
}

class Wall {
  PVector loc1;
  PVector loc2;
  color wallColor;

  Wall(float x1, float y1, float x2, float y2) {
    wallColor = color(127);
    loc1 = new PVector(round(x1/gridSnap)*gridSnap, round(y1/gridSnap)*gridSnap);
    loc2 = new PVector(round(x2/gridSnap)*gridSnap, round(y2/gridSnap)*gridSnap);
  }

  void display() {
    stroke(255);
    //strokeWeight(10);
    line(loc1.x, loc1.y, loc2.x, loc2.y);
  }

  void setColorBlack() {
    wallColor = color(100);
  }

  void setColorRed() {
    wallColor = color(255, 0, 0);
  }
}

class Creature {
  PVector loc;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  color bodyColor;
  int nMembranePoints;
  float[] membraneDeviation;
  float[] membraneLocX;
  float[] membraneLocY;
  int creatureType;

  // Constructor initialize all values
  Creature(float x, float y, int theCreatureType, float radius) {
    loc = new PVector(x, y);
    r = radius;
    maxspeed = creatureMaxSpeed;
    maxforce = 0.2;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    nMembranePoints = 32; // make this even number, preferably 2^n
    creatureType = theCreatureType;

    // make it look like a funky creature
    bodyColor = color(random(255), random(255), random(255)); // set a random color
    if (theCreatureType == PREY) {
      bodyColor = color(0, random(200, 255), 0); // set a random color
      maxforce /= 4;
      maxspeed /= 4;
      nMembranePoints /= 2;
    }
    // precalc location for random membrane
    membraneDeviation = new float[nMembranePoints];
    membraneLocX = new float[nMembranePoints];
    membraneLocY = new float[nMembranePoints];

    for (int i = 0; i < nMembranePoints; i++) {
      membraneDeviation[i] = 0.0;
      float angle = i * (360 / nMembranePoints);
      membraneLocX[i] = cos(radians(angle));
      membraneLocY[i] = sin(radians(angle));
    }
  }

  PVector getLoc() {
    return loc;
  }

  void applyForce(PVector force) {
    acceleration.add(force); //could add mass here if we want A = F / M
  }

  float getR() {
    return r;
  }

  PVector getClosestTarget(ArrayList<Creature> creatures, PVector currentLocation, int myType) {
    PVector theTarget;
    PVector bestTarget = null;
    float d;
    float closest = LARGENUM;
    for (int i = 0; i < creatures.size (); i++) {
      theTarget = creatures.get(i).getLoc();
      d = theTarget.dist(currentLocation, theTarget);
      if (d < closest) {
        if (myType != creatures.get(i).creatureType) {
          bestTarget = theTarget;
          closest = d;
        }
      }
    }
    /*
    if (bestTarget == null && myType == PREDATOR) {
      for (int i = 0; i < 2; i++) {
        addRandomPrey();
      }
    }*/
    return bestTarget;
  }


  void applyBehaviors(ArrayList<Creature> creatures, ArrayList<Wall> walls) {

    PVector separateForce = separate(creatures, walls);
    PVector theTarget = getClosestTarget(creatures, loc, creatureType);

    if (theTarget == null) {
      theTarget = loc;
    }

    PVector seekForce = seek(theTarget);
    //line(loc.x, loc.y, theTarget.x, theTarget.y); // debug

    separateForce.mult(2);
    seekForce.mult(1);
    applyForce(separateForce);
    applyForce(seekForce);

    //collideWall(walls); // debug
  }

  // A method that calculates a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector theTarget) {
    PVector desired = PVector.sub(theTarget, loc);  // A vector pointing from the location to the target

    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(creatureMaxSpeed);
    PVector steer = PVector.sub(desired, velocity); // steering = Desired minus velocity
    steer.limit(maxforce);  // limit to maximum steering force
    if (creatureType == PREY) {
      steer.mult(-1.0); // go away from predator
    }
    return steer;
  }

  // Separation
  // Method checks for nearby creatures and steers away
  PVector separate (ArrayList<Creature> creatures, ArrayList<Wall> walls) {
    float desiredseparation = r*2;
    PVector sum = new PVector();
    int count = 0;
    // For everyone in the system, check if it's too close
    Creature other;
    for (int i = 0; i < creatures.size(); i++) {
      other = creatures.get(i);
      float d = PVector.dist(loc, other.loc);
      desiredseparation = r + other.r;
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation) ) {
        if (creatureType == other.creatureType) {
          // Calculate vector pointing away from neighbor
          PVector diff = PVector.sub(loc, other.loc);
          diff.normalize();
          diff.div(d);        // Weight by distance
          sum.add(diff);
          count++;            // Keep track of how many
        } else if ( (creatureType == PREDATOR) && (other.creatureType == PREY) ) { // eat the prey
          creatures.remove(i);
        }
      }
    }

    // for each wall, check to see if it is too close
    desiredseparation = r;
    PVector closest;
    for (Wall w : walls) {
      //if ( isCollision(w.loc1.x, w.loc1.y, w.loc2.x, w.loc2.y, location.x, location.y, r) ) {
      closest = getClosestPointToCenter(w.loc1.x, w.loc1.y, w.loc2.x, w.loc2.y, loc.x, loc.y, r);
      float d = closest.dist(loc, closest);
      if ( d <= desiredseparation ) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc, closest);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }   

    // Average -- divide by how many
    if (count > 0) {
      sum.div(count);
      // Our desired vector is the average scaled to maximum speed
      sum.normalize();
      sum.mult(creatureMaxSpeed);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }

  // if creature collides with wall, then bounce away
  void collideWall(ArrayList<Wall> walls) {
    PVector closest;
    for (Wall w : walls) {
      closest = getClosestPointToCenter(w.loc1.x, w.loc1.y, w.loc2.x, w.loc2.y, loc.x, loc.y, r);
      if ( closest.dist(loc, closest) <= r ) {
        w.setColorRed();
      } else {
        w.setColorBlack();
      }
    }
  }

  void update() {
    velocity.add(acceleration);
    if (creatureType == PREDATOR) {
      velocity.limit(creatureMaxSpeed);
    } else if (creatureType == PREY) {
      velocity.limit(creatureMaxSpeed / 4);
    }
    
    loc.add(velocity);
    acceleration.mult(0); // Reset accelertion to 0 each cycle
  }

  void display() {
    fill(bodyColor);
    stroke(0);
    pushMatrix();

    translate(loc.x, loc.y);
    float theta = velocity.heading2D() + radians(90);
    rotate(theta);
    beginShape();
    float len = 0;
    float deviation = 0;
    float locX, locY;

    // draw the body
    for (int i = 0; i < nMembranePoints; i++) {
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
    int eyeIndex = round(nMembranePoints*5/8);
    float eyeDist = 0.6;
    len = r + membraneDeviation[eyeIndex];
    locX = membraneLocX[eyeIndex];
    locY = membraneLocY[eyeIndex];
    fill(255);
    ellipse(len*locX*eyeDist, len*locY*eyeDist, len/1.5, len/1.5);
    fill(0);
    ellipse(len*locX*eyeDist, len*locY*eyeDist, len/(4+(1-creatureType)*4), len/(4+(1-creatureType)*4));
    eyeIndex = round(nMembranePoints*7/8);
    len = r + membraneDeviation[eyeIndex];
    locX = membraneLocX[eyeIndex];
    locY = membraneLocY[eyeIndex];
    fill(255);
    ellipse(len*locX*eyeDist, len*locY*eyeDist, len/1.5, len/1.5);
    fill(0);
    ellipse(len*locX*eyeDist, len*locY*eyeDist, len/(4+(1-creatureType)*4), len/(4+(1-creatureType)*4));
    popMatrix();
  }
}

// class to intersect lines and circles or to gest the closest point to a circle in a given segment
PVector getClosestPointToCenter(float x1, float y1, float x2, float y2, float cx, float cy, float r) {
  float dx;
  float dy;
  float sLength;
  float sx;
  float sy;
  float pLength;
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