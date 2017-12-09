int NO_RECORD = 0;

struct Hit {
  int pin1;
  int pin2;
  int pin3;
  int pin4;
  int pin5;
  int pin6;
  int pin7;
  int pin8;
};

Hit curHit = {
  NO_RECORD, 
  NO_RECORD, 
  NO_RECORD, 
  NO_RECORD, 
  NO_RECORD, 
  NO_RECORD, 
  NO_RECORD, 
  NO_RECORD
};

int numPins = 8;
int allPins[] = {1, 2, 3, 4, 5, 6, 7, 8};

void setup() {
  Serial.begin(9600);

  for (int i = 0; i < numPins; i++) {
    int pinNumber = allPins[i];
    pinMode(pinNumber, INPUT);
  }
}

void loop() {
  readPins(allPins);

  if (isCompleteHit(&curHit)) {
    Serial.println(
      "hit: " + 
      String(curHit.pin1) + " " + 
      String(curHit.pin2) + " " + 
      String(curHit.pin3) + " " + 
      String(curHit.pin4) + " " + 
      String(curHit.pin5) + " " + 
      String(curHit.pin6) + " " +
      String(curHit.pin7) + " " + 
      String(curHit.pin8)
      );
      delay(300);
  } else {
    //Serial.println("no hit");
  }
}

void readPins(int* pinList) {
  for (int i = 0; i < numPins; i++) {
    int pinNumber = pinList[i];
    int pinValue = analogRead(pinNumber);
    updateCorner(pinNumber, pinValue);
  }
}

void updateCorner(int pinNumber, int pinValue) {
  int *sidePins;
  sidePins = allPins;

  if (pinNumber == sidePins[0]) {
    curHit.pin1 = pinValue;
  }
  else if (pinNumber == sidePins[1]) {
    curHit.pin2 = pinValue;
  }
  else if (pinNumber == sidePins[2]) {
    curHit.pin3 = pinValue;
  }
  else if (pinNumber == sidePins[3]) {
    curHit.pin4 = pinValue;
  }
  else if (pinNumber == sidePins[4]) {
    curHit.pin5 = pinValue;
  }
  else if (pinNumber == sidePins[5]) {
    curHit.pin6 = pinValue;
  }
  else if (pinNumber == sidePins[6]) {
    curHit.pin7 = pinValue;
  }
  else if (pinNumber == sidePins[7]) {
    curHit.pin8 = pinValue;
  }
}

boolean isCompleteHit(struct Hit *hit) {
  return hit->pin1 != NO_RECORD || hit->pin2 != NO_RECORD || hit->pin3 != NO_RECORD || hit->pin4 != NO_RECORD ||
    hit->pin5 != NO_RECORD || hit->pin6 != NO_RECORD || hit->pin7 != NO_RECORD || hit->pin8 != NO_RECORD;
}
