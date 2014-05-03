#include "helpers.h"
#include "MAPPINGS.h"
#include <CubicEase.h>
#include <Arduino.h>
#include "rServo.h"
#include "Servo.h"
#include <Adafruit_NeoPixel.h>
//******* For Debugging *******\\
#define DEBUG
#include "debug.h"

//******* Declaration of Variables *******\\
// ------------------------------------------------------------------------------------

const int servoPins[] = {2, 3, 4, 5, 6, 7};
const int ledPin = 13;

int parameterArray[12];
int splitArray[12]; 
int light = 0;
int easingRes = 200;
int counter = 1;
int brightness = 0;
int red = 0;
int green = 0;
int blue = 0;
int led = 2;


bool robotIsReadyToMove   = true;
bool jointReachedTarget []   = {false,false,false,false,false,false};


bool serialReady    = false;
bool watchdogActive = false;
bool robotData      = false;
bool initRobot = false;


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
int base              = 1475;
int shoulder          = 1500;
int elbow             = 2300;
int wrist             = 800;
int gripper           = 1500;
int gripperAngle      = 1500;
char end              = '\n';

float angle = 0;
float aVelocity = 0.02;

Adafruit_NeoPixel strip = Adafruit_NeoPixel(2, PIN, NEO_GRB + NEO_KHZ800);

String inByte;

//******* Declaration of Instances ******* \\ 
// ------------------------------------------------------------------------------------

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
// ------------------------------------------------------------------------------------

void setup() 
{ 
  Serial.begin(115200);

  strip.begin();
  strip.show(); // Initialize all pixels to 'off'

   for (int i = 0; i < 6; ++i)
  {
    servoList[i]->attach(servoPins[i]);
  }

  for (int i = 0; i < 6; ++i)
  {
    chPosition[i]->easing_resolution = easingRes;
  }


  establishContact();
  parkPosition();
} 


// ------------------------------------------------------------------------------------
 
 
void loop(){ 
  
  if (Serial.available() > 0){
    inByte = Serial.readStringUntil(end);
    inByte.trim();
    
    if(inByte.equals("B") == true){
    serialReady = true;
    // Serial.print("#");
    // Serial.println();
    // Serial.print(1,DEC);
    // Serial.print(",");
    // Serial.print(base, DEC);
    // Serial.print(",");
    // Serial.print(shoulder, DEC);
    // Serial.println();
    }

    if(inByte.equals("W") == true){

      connectionTimeOut ++;

    }

    if(inByte.indexOf('R') == 0 && inByte.indexOf('r') == 1){

    splitString(inByte);
    // sendConfirmationData(1, base, shoulder, elbow, wrist, gripperAngle, gripper, light);
    // Serial.println("New Position");
       
    }

    if(inByte.equals("I")){

      if(!initRobot){
  
      }

    }

  }
  
  if (!watchdogActive){

    watchdog = millis();
    watchdogActive = true;

  }else if ((millis() - watchdog) >= 2000){
        watchdogCall();
    }

  if (connectionTimeOut <= 0){

    // Serial.println("TimeOut");
  }


 //  ******* Setting Target Position *******


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
    if(chPosition[i]->reachedTarget == false){
      robotIsReadyToMove = false;
      break;
    }
    else if(i==5 && counter == 1){
      robotIsReadyToMove = true;
      requestNextPosition();
      counter = 0;
    }
  }

}

//END OF MAIN LOOP

// ------------------------------------------------------------------------------------

void parkPosition(){


  // send_serial_command(1500, 1500, 1500, 1500, 1500, 1500, 300);

  chPosition[0]->setPosition(base);
  chPosition[1]->setPosition(shoulder);
  chPosition[2]->setPosition(elbow);
  chPosition[3]->setPosition(wrist);
  chPosition[4]->setPosition(gripperAngle);
  chPosition[5]->setPosition(gripper);


  // servoList[0]->writeMicroseconds(base);
  // servoList[1]->writeMicroseconds(shoulder);
  // servoList[2]->writeMicroseconds(elbow);
  // servoList[3]->writeMicroseconds(wrist);
  // servoList[4]->writeMicroseconds(gripperAngle);

  strip.setBrightness(0);
  

  strip.show();




}

// ------------------------------------------------------------------------------------

int splitString(String inByte){

for (int i = 0; i <= 12; i++){
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
  easingRes     = parameterArray[6];
  brightness    = parameterArray[7];
  red           = parameterArray[8];
  green         = parameterArray[9];
  blue          = parameterArray[10];
  led           = parameterArray[11];


  for (int i = 0; i < 6; ++i)
  {
    chPosition[i]->easing_resolution = easingRes;
  }

  // servoList[0]->writeMicroseconds(base);
  // servoList[1]->writeMicroseconds(shoulder);
  // servoList[2]->writeMicroseconds(elbow);
  // servoList[3]->writeMicroseconds(wrist);
  // servoList[4]->writeMicroseconds(gripperAngle);
  // servoList[5]->writeMicroseconds(gripper);

  // Serial.print("base: ");
  // Serial.println(base);
  // Serial.print("shoulder: ");
  // Serial.println(shoulder);
  // Serial.print("elbow: ");
  // Serial.println(elbow);
  // Serial.print("wrist: ");
  // Serial.println(wrist);
  // Serial.print("gripperAngle: ");
  // Serial.println(gripperAngle);
  // Serial.print("gripper: ");
  // Serial.println(gripper);
  // Serial.print("light: ");
  // Serial.println(light);
  // Serial.print("easingRes: ");
  // Serial.println(easingRes);
  

  strip.setBrightness(brightness);

  if(led == 0){
    strip.setPixelColor(0, strip.Color(red, green, blue));
  }else if(led == 1){
    strip.setPixelColor(1, strip.Color(red, green, blue));
  }else if(led == 2){
    strip.setPixelColor(0, strip.Color(red, green, blue));
    strip.setPixelColor(1, strip.Color(red, green, blue));
  }
  

  strip.show();

  chPosition[0]->setPosition(base);
  chPosition[1]->setPosition(shoulder);
  chPosition[2]->setPosition(elbow);
  chPosition[3]->setPosition(wrist);
  chPosition[4]->setPosition(gripperAngle);
  chPosition[5]->setPosition(gripper);

  counter = 1;



}

// ------------------------------------------------------------------------------------


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

// ------------------------------------------------------------------------------------

void requestNextPosition(){

  Serial.print("N");
  Serial.println();
}

// ------------------------------------------------------------------------------------

void watchdogCall() {
    Serial.print("W");   // send a capital A
    Serial.println();
    connectionTimeOut --;
    watchdogActive = false;
}  

// ------------------------------------------------------------------------------------

void establishContact() {
  strip.setPixelColor(0, strip.Color(255, 0, 0));
  strip.setPixelColor(1, strip.Color(255, 0, 0));
  strip.show();
   // Serial.println("Hello World...");
  delay(1000);  // do not print too fast!
  while (Serial.available() <= 0 && !serialReady) {
    Serial.print("A");   // send a capital A
    Serial.println();
    robotIsReadyToMove = true;
    delay(300);
  }
}
