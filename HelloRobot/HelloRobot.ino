#include <Arduino.h>
#include <Funken.h>
#include <ServoEasing.h>

const int SERVO1_PIN = 7;
const int SERVO2_PIN = 8;

ServoEasing Servo1;
ServoEasing Servo2;
Funken fnk;

void setup() {
  fnk.begin(57600, 0, 0);
  fnk.listenTo("STARTWAVING", startWaving);

  Servo1.attach(SERVO1_PIN, DEFAULT_MICROSECONDS_FOR_0_DEGREE, DEFAULT_MICROSECONDS_FOR_180_DEGREE);
  Servo2.attach(SERVO2_PIN, DEFAULT_MICROSECONDS_FOR_0_DEGREE, DEFAULT_MICROSECONDS_FOR_180_DEGREE);
  Servo1.setEasingType(EASE_SINE_IN_OUT);
  Servo2.setEasingType(EASE_SINE_IN_OUT);

  Servo1.write(90);
  Servo2.write(90);
}

void loop() {
  fnk.hark();
}

void startWaving(char *c) {
  char *token = fnk.getToken(c);

  int turnValue = atoi(fnk.getArgument(c));
  Servo1.startEaseTo(turnValue, 90);

  for (int i = 0; i < 5; i++) {
    Servo2.startEaseTo(70, 90);
    delay(500);
    Servo2.startEaseTo(110, 90);
    delay(500);
  }
  
  Servo2.startEaseTo(90, 90);
}
