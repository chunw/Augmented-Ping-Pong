import processing.serial.*;

/* This class contains the logic to read sensor data from Arduino, 
 * calculates ball hit location, and provides useful methods to query
 * these data.
 */
class BallPositionSensor {
  boolean realHit = false;
  boolean veryActiveHit = false;
  int NO_DATA = -1;
  int curHitPin = NO_DATA;
  float curHitX = NO_DATA;
  float curHitY = NO_DATA;
  String curHitData = "";

  Serial arduinoSerial;
  
  BallPositionSensor(PApplet applet) {
    println(Serial.list());
    if (Params.tablePort < Serial.list().length) {
      String portName = Serial.list()[Params.tablePort];
      println(portName);
      arduinoSerial = new Serial(applet, portName, 9600);
    }    
  }
  
  boolean isRealHit() {
    return realHit;
  }
  
  boolean veryActiveHit() {
    return veryActiveHit;
  }
  
  int getRealHitPin() {
    return curHitPin;
  }  
  
  String getRawData() {
    return curHitData;
  }
  
  String getSensorDataDisplayString() {
    return "data = " + getRawData() + ", pin = " + getRealHitPin();
  }

  Hit readHit() {
     String serialData = null;
     if (arduinoSerial != null && arduinoSerial.available() > 0) {
       serialData = arduinoSerial.readStringUntil('\n');
       curHitData = serialData;
       //println(curHitData);
     }
     if (serialData == null) {
      curHitData = "";
      return null;
     } else {
      String[] splitByLeftBracket = split(serialData, "hit: ");
      if (splitByLeftBracket != null && splitByLeftBracket.length > 1) {
       
        Hit hit = getHit(splitByLeftBracket[1]);
        return hit;
      } else {
        return null;
      }      
    }
  }

  private Hit getHit(String serialData) {
    String[] values = split(serialData, " ");
    PVector xy = calcXY(values);
    return new Hit(xy.x, xy.y);
  }

  // Determine the nearest sensor the ball hits
  PVector calcXY(String[] values) {
    if (values.length != 8) {
      return new PVector(curHitX, curHitY);
    }
    
    float value0 = float(values[0]);
    float value1 = float(values[1]);
    float value2 = float(values[2]);
    float value3 = float(values[3]);
    float value4 = float(values[4]);
    float value5 = float(values[5]);
    float value6 = float(values[6]);
    float value7 = float(values[7]);
    
    // compare values 
    float max = Params.triggerPinValue;
    int pinNumber = NO_DATA;
    float x = NO_DATA;
    float y = NO_DATA;

    if (value0 > max) {
      max = value0;
      pinNumber = 1;
      x = Params.pin1_left_x;
      y = Params.pin1_left_y;
    }
    if (value1 > max) {
      max = value1;
      pinNumber = 2;
      x = Params.pin2_left_x;
      y = Params.pin2_left_y;
    }
    if (value2 > max) {
      max = value2;
      pinNumber = 3;
      x = Params.pin3_left_x;
      y = Params.pin3_left_y;
    }
    if (value3 > max) {
      max = value3;
      pinNumber = 4;
      x = Params.pin4_left_x;
      y = Params.pin4_left_y;
    }
    if (value4 > max) {
      max = value4;
      pinNumber = 5;
      x = Params.pin5_left_x;
      y = Params.pin5_left_y;
    }
    if (value5 > max) {
      max = value5;
      pinNumber = 6;
      x = Params.pin6_left_x;
      y = Params.pin6_left_y;
    }
    if (value6 > max) {
      max = value6;
      pinNumber = 7;
      x = Params.pin7_left_x;
      y = Params.pin7_left_y;
    }
    if (value7 > max) {
      max = value7;
      pinNumber = 8;
      x = Params.pin8_left_x;
      y = Params.pin8_left_y;
    }
    
    if (pinNumber > NO_DATA) {
      curHitPin = pinNumber;
      curHitX = x;
      curHitY = y;
      realHit = true;
    } else {
      realHit = false;
    }
    
    if (max > Params.activeHitThreshold) {
      veryActiveHit = true;
    }
    
    return new PVector(x,y);
  }

}