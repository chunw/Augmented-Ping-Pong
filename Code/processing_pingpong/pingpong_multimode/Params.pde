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
  static float activeHitThreshold = 15;
  
  static int tablePort = 1; 
  static int cloudPort = 2; 
  
  static int pin1_left_x = 186;
  static int pin1_left_y = 313;

  static int pin2_left_x = 629;
  static int pin2_left_y = 405;
  
  static int pin3_left_x = 606;
  static int pin3_left_y = 868;
  
  static int pin4_left_x = 134;
  static int pin4_left_y = 852;
  
  static int pin5_left_x = 1169; 
  static int pin5_left_y = 405;
  
  static int pin6_left_x = 1790; 
  static int pin6_left_y = 432;
  
  static int pin7_left_x = 1664; 
  static int pin7_left_y = 894;
  
  static int pin8_left_x = 1117; 
  static int pin8_left_y = 840;
  
  // TIMER
  static int game_timer_showing_time = 200;
  static int game_timer_width = 10; 
  
  // SCORE BOARD
  static int score_board_color = 255;
  static int score_board_font_size = 80;
  static int score_board_score1_width = 50;
  static int score_board_score2_width = 800;
  static int score_board_height = 200;  

  // PREY MODE
  static int prey_mode_score_board_bg_color = 0;
  static int prey_mode_wall_color = 255;
  
  // SOCIAL MEDIA MODE
  static int hit_range_margin = 100; //check
}