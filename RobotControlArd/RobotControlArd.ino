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

const int servoPins[] = {2, 3, 4, 5, 6, 7};
const int ledPin = 13;

bool BaseIswaitingToMoveLeft      = false;
bool BaseIswaitingToMoveRight     = false;
bool WristIswaitingToMoveLeft     = false;
bool WristIswaitingToMoveRight    = false;
bool ShoulderIswaitingToMoveLeft  = false;
bool ShoulderIswaitingToMoveRight = false;
bool ElbowIswaitingToMoveLeft     = false;
bool ElbowIswaitingToMoveRight    = false;
bool HandIswaitingToMoveLeft      = false;
bool HandIswaitingToMoveRight     = false;
bool ClawIswaitingToMoveLeft    = false;
bool ClawIswaitingToMoveRight   = false;

bool serialReady = false;


int bMinDegree = 0;
int wMinDegree = 0;
int sMinDegree = 0;
int eMinDegree = 0;
int hMinDegree = 0;
int cMinDegree = 0;

int bMaxDegree = 180;
int wMaxDegree = 180;
int sMaxDegree = 180;
int eMaxDegree = 180;
int hMaxDegree = 180;
int cMaxDegree = 180;

int b = 90;
int w = 0;
int s = 30;
int e = 140;
int h = 90;
int c = 90;
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
  Serial.begin(115200);

  for (int i = 0; i < 6; ++i)
  {
    servoList[i]->attach(servoPins[i]);
    //Serial.println(testAttach);
  }
  pinMode(ledPin, OUTPUT);
  parkPosition();
  
} 
 
 
void loop() 
{ 
 
  if(Serial.available() > 0){
    inByte = Serial.read();
    // Serial.println("Incoming Byte");
    if(inByte == 40){

    serial.write(41);
    serialReady = true;

   }



    if (inByte == 65) {
      BaseIswaitingToMoveLeft = true; 
    }
    if (inByte == 66) {
      BaseIswaitingToMoveRight = true; 
    }
    if (inByte == 67) {
      WristIswaitingToMoveLeft = true;
    }
    if (inByte == 68) {
      WristIswaitingToMoveRight = true;
    }
    if (inByte == 69) {
      ShoulderIswaitingToMoveLeft = true;
    }
    if (inByte == 70) {
      ShoulderIswaitingToMoveRight = true;
    }
    if (inByte == 71) {
      ElbowIswaitingToMoveLeft = true;
    }
    if (inByte == 72) {
      ElbowIswaitingToMoveRight = true;
    }
    if (inByte == 73) {
      HandIswaitingToMoveLeft = true;
    }
    if (inByte == 74) {
      HandIswaitingToMoveRight = true;
    }
    if (inByte == 75) {
      ClawIswaitingToMoveLeft = true;
    }
    if (inByte == 76) {
      ClawIswaitingToMoveRight = true;
    }
  inByte = 0;

  }  



   //******* Setting Target Position *******

  //******* Base *******
    if (BaseIswaitingToMoveLeft and b >= bMinDegree){
      b -= 8; 
      chPosition[0]->setPosition(b);
      BaseIswaitingToMoveLeft = false;
    }else if (BaseIswaitingToMoveLeft) { b = bMinDegree;}
    
    if (BaseIswaitingToMoveRight and b <= bMaxDegree){
      b += 8;
      chPosition[0]->setPosition(b);
      BaseIswaitingToMoveRight = false;
    }else if (BaseIswaitingToMoveRight){ b = bMaxDegree;  }
  

  //******* Wrist *******
    if (WristIswaitingToMoveLeft and w >= wMinDegree){
      w -= 8;
      chPosition[1]->setPosition(w);
      WristIswaitingToMoveLeft = false;
    }else if(WristIswaitingToMoveLeft) { w = wMinDegree; }
    
    if (WristIswaitingToMoveRight and w <= wMaxDegree){
      w += 8;
      chPosition[1]->setPosition(w);
      WristIswaitingToMoveRight = false;
    }else if (WristIswaitingToMoveRight){ w = wMaxDegree; }
  

  //******* Shoulder *******
    if (ShoulderIswaitingToMoveLeft and s >= sMinDegree){
      s -= 8;
      chPosition[2]->setPosition(s);
      ShoulderIswaitingToMoveLeft = false;
    }else if (ShoulderIswaitingToMoveLeft) { s = sMinDegree; }
    
    if (ShoulderIswaitingToMoveRight and s <= sMaxDegree){
      s += 8;
      chPosition[2]->setPosition(s);
      ShoulderIswaitingToMoveRight = false;
    }else if (ShoulderIswaitingToMoveRight) { s = sMaxDegree; }
  

  //******* Elbow *******
    if (ElbowIswaitingToMoveLeft and e >= eMinDegree){
      e -= 8;
      chPosition[3]->setPosition(e);
      ElbowIswaitingToMoveLeft = false;
    }else if (ElbowIswaitingToMoveLeft) { e = eMinDegree; }
   
    if (ElbowIswaitingToMoveRight and e <= eMaxDegree){
      e += 8;
      chPosition[3]->setPosition(e);
      ElbowIswaitingToMoveRight = false;
    }else if (ElbowIswaitingToMoveRight) { e = eMaxDegree; }
  

  //******* Hand *******  
    if (HandIswaitingToMoveLeft and h >= hMinDegree){
      h -= 8;
      chPosition[4]->setPosition(h);
      HandIswaitingToMoveLeft = false;
    }else if (HandIswaitingToMoveLeft) { h = hMinDegree; }
    
    if (HandIswaitingToMoveRight and h <= hMaxDegree){
      h += 8;
      chPosition[4]->setPosition(h);
      HandIswaitingToMoveRight = false;
    }else if (HandIswaitingToMoveRight) { h = hMaxDegree; }
  

  //******* Claw ******* 
    if (ClawIswaitingToMoveLeft and c >= cMinDegree){
      c -= 8;
      chPosition[5]->setPosition(c);
      ClawIswaitingToMoveLeft = false;
    }else if (ClawIswaitingToMoveLeft) { c = cMinDegree; } 
    
    if (ClawIswaitingToMoveRight and c <= cMaxDegree){
      c += 8;
      chPosition[5]->setPosition(c);
      ClawIswaitingToMoveRight = false;
    }else if (ClawIswaitingToMoveRight){ c = cMaxDegree; }

    






//******* MOVE THE SERVOS *******


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

  
  //delay(1);


}
void blink(){
  digitalWrite(ledPin, HIGH);   // set the LED on
  delay(200);                  // wait for a second
  digitalWrite(ledPin, LOW);    // set the LED off
  delay(1000); 
}

void parkPosition(){

  chPosition[0]->setPosition(b);
  chPosition[1]->setPosition(w);
  chPosition[2]->setPosition(s);
  chPosition[3]->setPosition(e);
  chPosition[4]->setPosition(h);
  chPosition[5]->setPosition(c);
}

