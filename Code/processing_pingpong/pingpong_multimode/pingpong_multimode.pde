import processing.serial.*;
import processing.sound.*;

int mode = 1;

BallPositionSensor sensor;
PVector ballPosition = new PVector(0, 0);

Serial cloudPort;

SoundFile soundfile;

int gameStartTime;
boolean showGameTimer = false;
int gameTimerCount = 0;
float gameTimeCheckInterval = 1; // in number of minutes
float nextGameTimeCheck = gameTimeCheckInterval;

int lastHitTime = 0;
int hitCount = 0;
float inactiveGameThreshold = 1; // in number of minutes

int scorePlayer1 = 0;
int scorePlayer2 = 0;

void setup() {
  
  size(1000, 800);
  
  //fullScreen();
  
  sensor = new BallPositionSensor(this);
  
  //println(Serial.list());
  cloudPort = new Serial(this, Serial.list()[Params.cloudPort], 9600);
  gameStartTime = millis();
  myFont = createFont("Courier New", 40);
  textFont(myFont);
  reset();
}

// allow user to manully select visual mode and enter score
void keyPressed() {
    if (key == '1') {
      mode = 1;
      reset();
    } else if (key == '2') {
      mode = 2;
      reset();
    } else if (key == '3') {
      mode = 3;
      reset();
    } else if (key == 'z') {
      scorePlayer1++;
    } else if (key == 'm') {
      scorePlayer2++;
    }
}

void draw() {
  // read sensor
  Hit ballLocation = sensor.readHit();
  if (ballLocation != null) {
    ballPosition = ballLocation.getPixelVector_raw();
  }
  if (sensor.isRealHit()) {
    // hit
    lastHitTime = millis();
    hitCount++;
  } else {
    // no hit
    if (mode != 2 && (millis() - lastHitTime) / 1000 / (60 * inactiveGameThreshold) > 1) {
      mode = 2;
      gameStartTime = 0;
      reset();
    }
  }
  
  if (isModeSelected_koiPond()) {
    drawMode_koiPond();
  } else if (isModeSelected_prey()) {
    drawMode_prey();
  }
  
  drawScores();
  drawGameTimer();
}

void reset() {
  if (isModeSelected_koiPond()) {
     setupMode_koiPond();
     cloudPort.write('2');      
  } else if (isModeSelected_prey()) {
     setupMode_prey();
     cloudPort.write('1');
  }
}

boolean isModeSelected_prey() {
  return (mode == 1);
}

boolean isModeSelected_koiPond() {
  return (mode == 2);
}

boolean isModeSelected_distraction() {
  return (mode == 3);
}

void drawScores() {
  fill(Params.score_board_color);
  textSize(Params.score_board_font_size);
  text(scorePlayer1 + " : " + scorePlayer2 + "      " + scorePlayer1 + " : " + scorePlayer2,  width/2 - 400, Params.score_board_height);
}

void drawGameTimer() {
  int elapsed = millis() - gameStartTime;
  if (float(elapsed) / 1000 / (60 * nextGameTimeCheck) > 1) {
    showGameTimer = true;
  }
  if (showGameTimer && gameTimerCount == 0) {
    println("elapsed = " + (millis() - gameStartTime) / 1000 + " sec");
    println("hit count = " + hitCount);
    
    // hit frequecy controls the predators' speed in PREY mode (mode 1)
    if (hitCount < 2) {
      creatureMaxSpeed = 2;
    } else {
      creatureMaxSpeed = log(hitCount);
    }
    
    hitCount = 0;
  }
  if (showGameTimer && gameTimerCount < Params.game_timer_showing_time) {
    fill(Params.score_board_color);
    textSize(Params.score_board_font_size);
    gameTimerCount++;
    text("GAME TIMER: " + int(nextGameTimeCheck) + " min elapsed ", 10, height/2);
  } else {
    if (gameTimerCount == Params.game_timer_showing_time) {
      nextGameTimeCheck += gameTimeCheckInterval;
    }
    showGameTimer = false;
    gameTimerCount = 0;
  }
}

void drawText() {
  fill(Params.score_board_color);
  textSize(Params.score_board_font_size);
  //text(sensor.getRawData(), 50, 600);
  //println(sensor.getSensorDataDisplayString());
  text(sensor.getRealHitPin(), width/2, height/2);
  //text(ballPosition.x + "   " + ballPosition.y, width/2, height/2 + 70);
}