/*
* This class contains all the parameters that should be calibrated when
* the ping pong table is setup for the first time.
* 
* General tips for successful hit detections:
*    1. The Arduino board must use analog pins rather than digital pins as Inputs, and
*       piezo sensors must be connencted in parallel with 1M ohm resistors in a parallel circuit.
*    2. Check circuit wiring.
*    3. Make sure all piezo sensors are fastened to the table.
*/
static class Params {
  static float triggerPinValue = 4;
  
  static int tablePort = 1; //check
  static int cloudPort = 2; //check
  
  static int pin1_left_x = 1822;
  static int pin1_left_y = 588;

  static int pin2_left_x = 1259;
  static int pin2_left_y = 758;
  
  static int pin3_left_x = 1222;
  static int pin3_left_y = 247;
  
  static int pin4_left_x = 1711;
  static int pin4_left_y = 53;
  
  static int pin5_left_x = 861; 
  static int pin5_left_y = 821;
  
  static int pin6_left_x = 302; 
  static int pin6_left_y = 903;
  
  static int pin7_left_x = 287; 
  static int pin7_left_y =434;
  
  static int pin8_left_x = 799; 
  static int pin8_left_y = 290;
  
  // TIMER
  static int game_timer_showing_time = 200;
  static int game_timer_width = 10; // check
  
  // SCORE BOARD
  static int score_board_color = 255;
  static int score_board_font_size = 80;
  static int score_board_score1_width = 50;  // check
  static int score_board_score2_width = 800; // check
  static int score_board_height = 200;  // check

  // PREY MODE
  static int prey_mode_score_board_bg_color = 0;
  static int prey_mode_wall_color = 255;
}