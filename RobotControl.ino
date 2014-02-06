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

  new ChangePosition_Class(MIN_MILLIS_CC_1, MAX_MILLIS_CW_1),
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
    chPosition[0]->setPosition(70);
    chPosition[1]->setPosition(20);
    chPosition[2]->setPosition(120);
    chPosition[3]->setPosition(70);
    chPosition[4]->setPosition(70);
    chPosition[5]->setPosition(70);
  }

  if (inByte == 'b'){
    chPosition[0]->setPosition(90);
    chPosition[1]->setPosition(90);
    chPosition[2]->setPosition(90);
    chPosition[3]->setPosition(90);
    chPosition[4]->setPosition(90);
    chPosition[5]->setPosition(90);
  }

  if (inByte == 'c'){
    chPosition[0]->setPosition(100);
    chPosition[1]->setPosition(110);
    chPosition[2]->setPosition(110);
    chPosition[3]->setPosition(110);
    chPosition[4]->setPosition(110);
    chPosition[5]->setPosition(110);
  }

  ///MOVE THE SERVOS


  if(!chPosition[0]->reachedTarget){
    servoList[0]->writeMicroseconds(chPosition[0]->nextEasedStep());
  }

  if(!chPosition[1]->reachedTarget){
    servoList[1]->writeMicroseconds(chPosition[1]->nextEasedStep());
  }

  if(!chPosition[2]->reachedTarget){
    servoList[2]->writeMicroseconds(chPosition[2]->nextEasedStep());
  }

  if(!chPosition[3]->reachedTarget){
    servoList[3]->writeMicroseconds(chPosition[3]->nextEasedStep());
  }

  if(!chPosition[4]->reachedTarget){
    servoList[4]->writeMicroseconds(chPosition[4]->nextEasedStep());
  }

  if(!chPosition[5]->reachedTarget){
    servoList[5]->writeMicroseconds(chPosition[5]->nextEasedStep());
  }

  inByte = 0;

  delay(5);



}

