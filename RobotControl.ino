#include "helpers.h"
#include "MAPPINGS.h"
#include <CubicEase.h>
#include <Arduino.h>
#include "rServo.h"
#include "Servo.h"

//******* For Debugging *******\\
#define DEBUG
#include "debug.h"


//******* Declaration of Variables *******\\

const int servoPins[] = {3, 5, 6, 9, 10, 11};

int testServoList;
int testAttach;
char inByte;

//******* Declaration of Instances ******* \\ 

CubicEase cubic;

Servo *servoList[] = {
  new Servo(), 
  new Servo(),
  new Servo(),
  new Servo(),
  new Servo(),
  new Servo(),
};  

ChangePosition_Class *chPosition[] = {

  new ChangePosition_Class(700, 2233),
  new ChangePosition_Class(MIN_MILLIS_CC_2, MAX_MILLIS_CW_2),
  new ChangePosition_Class(MIN_MILLIS_CC_3, MAX_MILLIS_CW_3),
  new ChangePosition_Class(MIN_MILLIS_CC_4, MAX_MILLIS_CW_4),
  new ChangePosition_Class(MIN_MILLIS_CC_5, MAX_MILLIS_CW_5),
  new ChangePosition_Class(MIN_MILLIS_CC_6, MAX_MILLIS_CW_6),

};
 


//******* Programm Start ******* \\

void setup() 
{ 
  Serial.begin(9600);

  for (int i = 0; i < 6; ++i)
  {
    testAttach = servoList[i]->attach(servoPins[i]);
    //Serial.println(testAttach);

  }
  
} 
 
 
void loop() 
{ 
 
  if(Serial.available() > 0){
    inByte = Serial.read();
    Serial.println("Incoming Byte");
    }


  ///////////////Setting target

  if (inByte == 'a'){
    chPosition[0]->setPosition(180);
  }

  if (inByte == 'b'){
    //chPosition[0]->setPosition(100);
    chPosition[0]->setPosition(90);
  }

  if (inByte == 'c'){
    //chPosition[0]->setPosition(100);
    chPosition[0]->setPosition(0);
  }

  ///MOVE THE SERVOS


  if(!chPosition[0]->reachedTarget){
    testServoList = chPosition[0]->nextEasedStep();
    Serial.println(testServoList);
    servoList[0]->writeMicroseconds(testServoList);
  }

  inByte = 0;

  delay(5);



}

