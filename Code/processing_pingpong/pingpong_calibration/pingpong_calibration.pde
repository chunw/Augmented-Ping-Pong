import processing.serial.*;

/* This class is useful to learn each sensor's location
 * mapped to the (X,Y) position in Processing sketch and
 * store in Params, when the ping pong table is setup for
 * the first time.
 *
 * Then I use a shell script to update all the Processing
 * visualizations to use these latest Params.
 */
BallPositionSensor sensor;
PVector ballPosition = new PVector(0, 0);

void setup() {
  //size(1000, 800);
  fullScreen();
  background(0);
  sensor = new BallPositionSensor(this);
}

void draw() {
  background(255);
  Hit ballLocation = sensor.readHit();
  if (ballLocation != null) {
    //ballPosition = ballLocation.getPixelVector_raw();
  } 
  drawText();
  drawBallPosition();
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

void drawText() {
  fill(0);
  textSize(Params.score_board_font_size);
  text(sensor.getRealHitPin(), width/2, height/2 + 100);
  text(mouseX + ", " + mouseY, width/2, height/2 + 180);
  text(sensor.getRawData(), 50, 600);
  println(sensor.getRawData());
  
  // make sure text used by the game are projected fine
  fill(Params.score_board_color);
  textSize(Params.score_board_font_size);
  text("0 : 0" + "         " + "0 : 0",  width/2 - 400, Params.score_board_height);
  text("GAME TIMER: 1 min elapsed ", Params.game_timer_width, height/2);
}

void mouseClicked() {
   ballPosition = new PVector(mouseX, mouseY);
}