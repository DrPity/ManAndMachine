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

int parameterArray[6];
int splitArray[6]; 

bool robotIsReadyToMove   = true;
bool requestNextPos = false;
bool jointReachedTarget []   = {false,false,false,false,false,false};


bool serialReady    = false;
bool watchdogActive = false;
bool robotData      = false;


int bMinDegree = 0;
int wMinDegree = 0;
int sMinDegree = 0;
int eMinDegree = 0;
int hMinDegree = 0;
int cMinDegree = 0;
int booleanCount = 0;
long watchdog;

int bMaxDegree = 180;
int wMaxDegree = 180;
int sMaxDegree = 180;
int eMaxDegree = 180;
int hMaxDegree = 180;
int cMaxDegree = 180;

int connectionTimeOut = 10;
int base              = 90;
int shoulder          = 90;
int elbow             = 90;
int wrist             = 90;
int gripper           = 90;
int gripperAngle      = 90;
int speed             = 90;
char end              = '\n';

String inByte;

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
  establishContact();
  parkPosition();
} 
 
 
void loop(){ 
  
  if (Serial.available() > 0){
    inByte = Serial.readStringUntil(end);
    inByte.trim();
    
    if(inByte.equals("B") == true){
    serialReady = true;
    Serial.print("#");
    Serial.println();
    Serial.print(1,DEC);
    Serial.print(",");
    Serial.print(base, DEC);
    Serial.print(",");
    Serial.print(shoulder, DEC);
    Serial.println();
    }

    if(inByte.equals("W") == true){

      connectionTimeOut ++;

    }

    if(inByte.indexOf('R') == 0 && inByte.indexOf('r') == 1){

    splitString(inByte);
    sendConfirmationData(1, base, shoulder, elbow, wrist, gripperAngle, gripper, speed);
    requestNextPos = true;
    Serial.println("New Position");
       
    }

  }
  
  if (!watchdogActive){

    watchdog = millis();
    watchdogActive = true;

  }else if ((millis() - watchdog) >= 2000){
        watchdogCall();
    }

  if (connectionTimeOut <= 0){

    Serial.println("TimeOut");
  }


   //******* Setting Target Position *******
 if (robotIsReadyToMove){
  chPosition[0]->setPosition(base);
  chPosition[1]->setPosition(shoulder);
  chPosition[2]->setPosition(elbow);
  chPosition[3]->setPosition(wrist);
  chPosition[4]->setPosition(gripperAngle);
  chPosition[5]->setPosition(gripper);
  }

 //******* MOVE THE SERVOS *******

  if(!chPosition[0]->reachedTarget){
    servoList[0]->writeMicroseconds(chPosition[0]->nextEasedStep());
  }else{jointReachedTarget[0] = true;}

  if(!chPosition[1]->reachedTarget){
    servoList[1]->writeMicroseconds(chPosition[1]->nextEasedStep());
  }else{jointReachedTarget[1] = true;}
  
  if(!chPosition[2]->reachedTarget){
    servoList[2]->writeMicroseconds(chPosition[2]->nextEasedStep());
  }else{jointReachedTarget[2] = true;}
  
  if(!chPosition[3]->reachedTarget){
    servoList[3]->writeMicroseconds(chPosition[3]->nextEasedStep());
  }else{jointReachedTarget[3] = true;}
  
  if(!chPosition[4]->reachedTarget){
    servoList[4]->writeMicroseconds(chPosition[4]->nextEasedStep());
  }else{jointReachedTarget[4] = true;}
  
  if(!chPosition[5]->reachedTarget){
    servoList[5]->writeMicroseconds(chPosition[5]->nextEasedStep());
  }else{jointReachedTarget[5] = true;} 
  // delay(1);


  for (int i = 0; i < 6; ++i){
    if(jointReachedTarget[i] == true){
      booleanCount++;
    }
  }

  if (booleanCount == 6 ){
    robotIsReadyToMove = true;
    booleanCount = 0;
    for (int i = 0; i < 6; ++i)
    {
      jointReachedTarget[i] = false;
    }
  }else{
    robotIsReadyToMove = false;
    booleanCount = 0;
  }
  
  if(requestNextPos){
  requestNextPosition();
  }

}
void blink(){
  digitalWrite(ledPin, HIGH);   // set the LED on
  delay(50);                  // wait for a second
  digitalWrite(ledPin, LOW);    // set the LED off
  delay(50); 
}

void parkPosition(){

  chPosition[0]->setPosition(90);
  chPosition[1]->setPosition(90);
  chPosition[2]->setPosition(90);
  chPosition[3]->setPosition(90);
  chPosition[4]->setPosition(90);
  chPosition[5]->setPosition(90);
}

int splitString(String inByte){

for (int i = 0; i <= 6; i++){
  if(i == 0){
    splitArray[i] = inByte.indexOf(',');
    parameterArray[i] = inByte.substring(2,splitArray[i]).toInt();
  }else if(i > 0){
    splitArray[i] = inByte.indexOf(',', splitArray[i-1] + 1);
    parameterArray[i] = inByte.substring(splitArray[i-1] +1,splitArray[i]).toInt();
  }
}
  
  base          = parameterArray[0];
  shoulder      = parameterArray[1];
  elbow         = parameterArray[2];
  wrist         = parameterArray[3];
  gripperAngle  = parameterArray[4];
  gripper       = parameterArray[5];
  speed         = parameterArray[6];

}


void sendConfirmationData(int ID, int value1, int value2, int value3, int value4, int value5, int value6, int value7){

  Serial.print("#");
  Serial.println();
  Serial.print(ID,DEC);
  Serial.print(",");
  Serial.print(value1, DEC);
  Serial.print(",");
  Serial.print(value2, DEC);
  Serial.print(",");
  Serial.print(value3, DEC);
  Serial.print(",");
  Serial.print(value4, DEC);
  Serial.print(",");
  Serial.print(value5, DEC);
  Serial.print(",");
  Serial.print(value6, DEC);
  Serial.print(",");
  Serial.print(value7, DEC);
  Serial.println();

}

void requestNextPosition(){

  Serial.print("N");
  Serial.println();
  requestNextPos = false;
}


void watchdogCall() {
    Serial.print("W");   // send a capital A
    Serial.println();
    connectionTimeOut --;
    delay(30);
    watchdogActive = false;
}  


void establishContact() {
  while (Serial.available() <= 0 && !serialReady) {
    Serial.print("A");   // send a capital A
    Serial.println();
    robotIsReadyToMove = true;
    delay(300);
  }
}  