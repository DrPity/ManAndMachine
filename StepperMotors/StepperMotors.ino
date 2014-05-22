#include "helpers.h"
#include "MAPPINGS.h"
#include "rServo.h"
#include "Servo.h"
#include <CubicEase.h>
//******* For Debugging *******\\
#define DEBUG
#include "debug.h"
#include <Average.h>

//******* Declaration of Variables *******\\
// ------------------------------------------------------------------------------------
const int led = 27;


unsigned long currentPositionA = 0;
unsigned long currentPositionB = 0;
unsigned long currentPositionC = 0;

long currentStepsAB;
long currentStepsC;

unsigned long MAX_STEPS_AB = 34037;
unsigned long MAX_STEPS_C = 20500;

unsigned long MIN_STEPS_AB = 0;
unsigned long MIN_STEPS_C = 0;

int parameterArray[3];
int splitArray[3]; 
int light = 0;
int easingRes = 0;
int counter = 1;

int numberOfStepsA = 0;
int numberOfStepsB = 0;
int numberOfStepsC = 0;
int cBuffer[3];
int cCounter = 0;


bool traversReadyToMove   = true;
bool AB = true;
bool C = true;


bool serialReady    = false;
bool watchdogActive = false;
bool robotData      = false;

bool aVerified      = false;
bool bVerified      = false;
bool cVerified      = false;

long watchdog;

int connectionTimeOut = 10;
unsigned long a               = 1500;
unsigned long b               = 1500;
unsigned long c               = 1500;
char end            = '\n';

String inByte;

//******* Declaration of Instances ******* \\ 
// ------------------------------------------------------------------------------------


ChangePosition_Class *stepperMotors[] = {

  new ChangePosition_Class(MIN_MILLIS_CC_1, MAX_MILLIS_CW_1),
  new ChangePosition_Class(MIN_MILLIS_CC_2, MAX_MILLIS_CW_2),
  new ChangePosition_Class(MIN_MILLIS_CC_3, MAX_MILLIS_CW_3),

};
 


//******* Programm Start ******* \\
// ------------------------------------------------------------------------------------

void setup() 
{ 
  Serial.begin(115200);

  pinMode(led, OUTPUT);
  pinMode(A_STEP_PIN, OUTPUT);
  pinMode(A_DIR_PIN, OUTPUT);
  pinMode(A_MIN_PIN, INPUT);
  pinMode(A_ENABLE_PIN, OUTPUT);
  
  pinMode(B_STEP_PIN, OUTPUT);
  pinMode(B_DIR_PIN, OUTPUT);
  pinMode(B_MIN_PIN, INPUT);
  pinMode(B_ENABLE_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  
  pinMode(C_STEP_PIN, OUTPUT);
  pinMode(C_DIR_PIN, OUTPUT);
  pinMode(C_MIN_PIN, INPUT);
  pinMode(C_ENABLE_PIN, OUTPUT);
  
  digitalWrite(A_ENABLE_PIN, LOW);
  digitalWrite(B_ENABLE_PIN, LOW);
  digitalWrite(C_ENABLE_PIN, LOW);

  digitalWrite(FAN_PIN, HIGH);

  establishContact();
  // parkPosition();
} 


// ------------------------------------------------------------------------------------
 
 
void loop(){ 
  
  if (Serial.available() > 0){
    inByte = Serial.readStringUntil(end);
    inByte.trim();
    
    if(inByte.equals("B") == true){
    serialReady = true;
    // testMovement();
    // testButton();
    }

    if(inByte.equals("W") == true){

     if(connectionTimeOut < 10) 
        connectionTimeOut = 10;

    }

    if(inByte.indexOf('R') == 0 && inByte.indexOf('r') == 1){

    splitString(inByte);
    // sendConfirmationData(1, x, y, z, wrist, gripperAngle, gripper, light);
    // Serial.println("New Position");
       
    }


    if(inByte.indexOf('C') == 0 && inByte.indexOf('c') == 1){
    initializeMovement();
    // sendConfirmationData(1, x, y, z, wrist, gripperAngle, gripper, light);
    // Serial.println("New Position");
       
    }

  }
  
  if (!watchdogActive){

    watchdog = millis();
    watchdogActive = true;

  }else if ((millis() - watchdog) >= 2000){
        watchdogCall();
    }


 //  ******* Setting Target Position *******


   if(!stepperMotors[0]->reachedTarget){
    moveA(stepperMotors[0]->direction, stepperMotors[0]->nextEasedStep());
  }

  if(!stepperMotors[1]->reachedTarget){
    moveB(stepperMotors[1]->direction, stepperMotors[1]->nextEasedStep());
  }
  
  if(!stepperMotors[2]->reachedTarget){
    moveC(stepperMotors[2]->direction, stepperMotors[2]->nextEasedStep());
  }
  
  if(aVerified || cVerified)
    sendMovement(numberOfStepsA,numberOfStepsB,numberOfStepsC);


   for (int i = 0; i < 3; ++i){
    if(stepperMotors[i]->reachedTarget == false){
      traversReadyToMove = false;
      break;
    }
    else if(i==2 && counter == 1){
      traversReadyToMove = true;
      requestNextPosition();
      counter = 0;
    }
  }


  if(digitalRead(C_MIN_PIN) == LOW){
    // Serial.println("currentPositionC");
    // Serial.println(stepperMotors[2]->_currentPosition);
    // digitalWrite(C_ENABLE_PIN, HIGH);
    if(stepperMotors[2]->direction == 1){
      digitalWrite(C_DIR_PIN, 0);
      stepperMotors[2]->_currentPosition = MAX_STEPS_C;
      currentPositionC = MAX_STEPS_C;
    }else{
      digitalWrite(C_DIR_PIN, 1);
      stepperMotors[2]->_currentPosition = MIN_STEPS_C;
      currentPositionC = MIN_STEPS_C;
    }
    C = true;
    for(int i = 0; i < 400; i ++){
      sendStep();
    }
    // Serial.println("currentPositionC");
    // Serial.println(stepperMotors[2]->_currentPosition);

    stepperMotors[2]->reachedTarget = true;
    C = false;
    cVerified = true;
    numberOfStepsC = 0;
  }

  if(digitalRead(A_MIN_PIN) == LOW){
    // Serial.println("currentPositionAB");
    // Serial.println(stepperMotors[0]->_currentPosition);
    // Serial.println(stepperMotors[1]->_currentPosition);
    // digitalWrite(C_ENABLE_PIN, HIGH);
    if(stepperMotors[0]->direction == 1){
      digitalWrite(A_DIR_PIN, 0);
      digitalWrite(B_DIR_PIN, 0);
      stepperMotors[0]->_currentPosition = MAX_STEPS_AB;
      stepperMotors[1]->_currentPosition = MAX_STEPS_AB;
      currentPositionA = MAX_STEPS_AB;
      currentPositionB = MAX_STEPS_AB;
    }else{
      digitalWrite(A_DIR_PIN, 1);
      digitalWrite(B_DIR_PIN, 1);
      stepperMotors[0]->_currentPosition = MIN_STEPS_AB;
      stepperMotors[1]->_currentPosition = MIN_STEPS_AB;
      currentPositionA = MIN_STEPS_AB;
      currentPositionB = MIN_STEPS_AB;
    }

    // Serial.println("currentPositionAB");
    // Serial.println(stepperMotors[0]->_currentPosition);
    // Serial.println(stepperMotors[1]->_currentPosition);
    AB = true;
    
    for(int i = 0; i < 400; i ++){
      sendStep();
    }
    Serial.println("Touch button AB");
    stepperMotors[0]->reachedTarget = true;
    stepperMotors[1]->reachedTarget = true;
    // Serial.println("number of steps A: ");
    // Serial.println(numberOfStepsA);
    // Serial.println(stepperMotors[0]->reachedTarget);
    // Serial.println(stepperMotors[1]->reachedTarget);
    AB = false;
    aVerified = true;
    numberOfStepsA = 0;
    numberOfStepsB = 0;
  }


   

  // if(digitalRead(A_MIN_PIN) == LOW){
  //   digitalWrite(A_ENABLE_PIN, HIGH);
  //   digitalWrite(B_ENABLE_PIN, HIGH);
  // }else{
  //   digitalWrite(A_ENABLE_PIN, LOW);
  //   digitalWrite(B_ENABLE_PIN, LOW);
  // }


}

//END OF MAIN LOOP
// ------------------------------------------------------------------------------------

void blink(){
  digitalWrite(led, HIGH);   // set the LED on
  delay(50);                  // wait for a second
  digitalWrite(led, HIGH);    // set the LED off
  delay(50); 
}

// ------------------------------------------------------------------------------------

void parkPosition(){


  // send_serial_command(1500, 1500, 1500, 1500, 1500, 1500, 300);

  // // stepperMotors[0]->setPosition(1500);
  // // stepperMotors[1]->setPosition(1500);
  // // stepperMotors[2]->setPosition(1500);
  // // stepperMotors[3]->setPosition(1500);
  // // stepperMotors[4]->setPosition(1500);
  // // stepperMotors[5]->setPosition(1500);

  stepperMotors[0]->setPosition(1500);
  stepperMotors[1]->setPosition(1500);
  stepperMotors[2]->setPosition(1500);



}

// ------------------------------------------------------------------------------------

int splitString(String inByte){

for (int i = 0; i <= 3; i++){
  if(i == 0){
    splitArray[i] = inByte.indexOf(',');
    parameterArray[i] = inByte.substring(2,splitArray[i]).toInt();
  }else if(i > 0){
    splitArray[i] = inByte.indexOf(',', splitArray[i-1] + 1);
    parameterArray[i] = inByte.substring(splitArray[i-1] +1,splitArray[i]).toInt();
  }
}
  
  a             = parameterArray[0];
  b             = parameterArray[1];
  c             = parameterArray[2];
  easingRes     = parameterArray[3];
  // Serial.println("Before Mapping: ");
  // Serial.println(a);
  // Serial.println(b);
  // Serial.println(c);

  a = map(a,0,2000,MIN_STEPS_AB ,MAX_STEPS_AB); // Wokaround -> make fx with button instead
  b = map(b,0,2000,MIN_STEPS_AB ,MAX_STEPS_AB);
  c = map(c,0,2000,MIN_STEPS_C ,MAX_STEPS_C);


  if(currentPositionA == a && currentPositionB == b && currentPositionC == c){
    easingRes = 100;
    // Serial.println("In check for easing");
  }


    for (int i = 0; i < 3; ++i)
  {
    stepperMotors[i]->easing_resolution = easingRes;
  }


  // Serial.println(stepperMotors[0]->_currentPosition);
  // Serial.println(stepperMotors[1]->_currentPosition);
  // Serial.println(stepperMotors[2]->_currentPosition);
  // Serial.println(currentPositionA);
  // Serial.println(currentPositionB);
  // Serial.println(currentPositionC);
  // Serial.println(a);
  // Serial.println(b);
  // Serial.println(c);
  // Serial.println("After Mapping: ");
  // Serial.println(a);
  // Serial.println(b);
  // Serial.println(c);
  // Serial.println(easingRes);;
  stepperMotors[0]->setPosition(a);
  stepperMotors[1]->setPosition(b);
  stepperMotors[2]->setPosition(c);

  counter = 1;

  // Serial.println("number of steps A in splitString: ");
  // Serial.println(numberOfStepsA);

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
    // delay(30);
    watchdogActive = false;
    if (connectionTimeOut <= 0){
      requestNextPosition();
    }
}  

// ------------------------------------------------------------------------------------

void establishContact() {
   // Serial.println("Hello World...");
  delay(1000);  // do not print too fast!
  while (Serial.available() <= 0 && !serialReady) {
    Serial.print("A");   // send a capital A
    Serial.println();
    traversReadyToMove = true;
    delay(300);
  }

}

// ------------------------------------------------------------------------------------

void moveA(int direction, long nextPositionA){
  if (direction == 1){
    digitalWrite(A_DIR_PIN, 1);    
  }else{
    digitalWrite(A_DIR_PIN, 0);
  }
  if(nextPositionA != currentPositionA){
    numberOfStepsA = nextPositionA - currentPositionA;
    numberOfStepsA = abs(numberOfStepsA);
    aVerified = true;
  }
  currentPositionA = nextPositionA;
}
// ------------------------------------------------------------------------------------

void moveB(int direction, long nextPositionB){
 if (direction == 1){
  digitalWrite(B_DIR_PIN, 1);    
  }else{
  digitalWrite(B_DIR_PIN, 0);
  }
 if(nextPositionB != currentPositionB){ 
    numberOfStepsB = nextPositionB - currentPositionB;
    numberOfStepsB = abs(numberOfStepsB);
    bVerified = true; 
  } 
  currentPositionB = nextPositionB;
}

// ------------------------------------------------------------------------------------

void moveC(int direction, long nextPositionC){
  if (direction == 1){
    digitalWrite(C_DIR_PIN, 1);    
  }else{
    digitalWrite(C_DIR_PIN, 0);
  }
  if(nextPositionC != currentPositionC){ 
    //Optional smoothing with Minimun array possible
    numberOfStepsC = nextPositionC - currentPositionC;
    numberOfStepsC = abs(numberOfStepsC);
    cVerified = true;
  } 
  currentPositionC = nextPositionC;
}

// ------------------------------------------------------------------------------------

void initializeMovement()
{
  Serial.println("Start initializing");
  currentStepsAB  = 0;
  currentStepsC   = 0;
  // move towards 0 until touch button
  digitalWrite(A_DIR_PIN, 1);
  digitalWrite(B_DIR_PIN, 1);
  digitalWrite(C_DIR_PIN, 1);
  bool done = false;

  while(!done)
  {
    if(digitalRead(A_MIN_PIN) == HIGH && AB)
    {
      AB = true;
    }else if(AB){
      AB = false;
      digitalWrite(A_ENABLE_PIN, HIGH);
      digitalWrite(B_ENABLE_PIN, HIGH);
      Serial.println("Button Pressed X");
    }

    if(digitalRead(C_MIN_PIN) == HIGH && C)
    {
      C = true;
    }else if(C){
      C = false;
      digitalWrite(C_ENABLE_PIN, HIGH);
      Serial.println("Button Pressed Y");
    }
    
    if(!AB && !C){
        delay(500);
        done = true;
        Serial.println("both buttons reached");
        watchdogCall();
    }
    sendStep();   
  }

  done = false;
  AB = true;
  C = true;

  digitalWrite(A_DIR_PIN, 0);
  digitalWrite(B_DIR_PIN, 0);
  digitalWrite(C_DIR_PIN, 0);

  digitalWrite(A_ENABLE_PIN, LOW);
  digitalWrite(B_ENABLE_PIN, LOW);
  digitalWrite(C_ENABLE_PIN, LOW);

  for(int i = 0; i<800; i++){
    sendStep();
  }

  // while(digitalRead(A_MIN_PIN) == LOW)
  // {
  //   Serial.println("moving away from button X");
  //   sendStep();
  // }

  // while(digitalRead(C_MIN_PIN) == LOW)
  // {
  //   Serial.println("moving away from button Y");
  //   sendStep();
  // }
  
  // move forwards until touch button, then we know how many steps is the ma


  while(!done)
  {
    if(digitalRead(A_MIN_PIN) == HIGH && AB)
    {
      AB = true;
      currentStepsAB += 1;
    }else if(AB){
      AB = false;
      Serial.println("Buttun Pressed X Second time");
      digitalWrite(A_ENABLE_PIN, HIGH);
      digitalWrite(B_ENABLE_PIN, HIGH);
    }


    if(digitalRead(C_MIN_PIN) == HIGH && C)
    {
      C = true;
      currentStepsC += 1;
    }else if(C){
      C = false;
      Serial.println("Buttun Pressed Y Second time");
      digitalWrite(C_ENABLE_PIN, HIGH);
    } 
    
    if(!AB && !C){
      watchdogCall();
      delay(500);
      done = true;
    }
    sendStep();  
  }

  digitalWrite(A_ENABLE_PIN, LOW);
  digitalWrite(B_ENABLE_PIN, LOW);
  digitalWrite(C_ENABLE_PIN, LOW);

  MAX_STEPS_AB = currentStepsAB;
  MAX_STEPS_C = currentStepsC;
  currentPositionA = MIN_STEPS_AB;
  currentPositionB = MIN_STEPS_AB;
  currentPositionC = MIN_STEPS_C;
  stepperMotors[0]->reachedTarget = true;
  stepperMotors[1]->reachedTarget = true;
  stepperMotors[2]->reachedTarget = true;
  stepperMotors[0]->_currentPosition = MIN_STEPS_AB;
  stepperMotors[1]->_currentPosition = MIN_STEPS_AB;
  stepperMotors[2]->_currentPosition = MIN_STEPS_C;
  aVerified = true;
  cVerified = true;
  Serial.println("Done with initializing");
  Serial.print("max x:");
  Serial.println(MAX_STEPS_AB);
  Serial.print("max y:");
  Serial.println(MAX_STEPS_C);
}

// ------------------------------------------------------------------------------------

void testButton(){

  while(true){
    Serial.println("xz:");
    Serial.println(digitalRead(A_MIN_PIN));
    Serial.println("y");
    Serial.println(digitalRead(C_MIN_PIN));
    delay(300);
  } 

}

// ------------------------------------------------------------------------------------

void sendStep(){

  if (AB){
    digitalWrite(A_STEP_PIN, HIGH);
    digitalWrite(A_STEP_PIN, LOW);
    digitalWrite(B_STEP_PIN, HIGH);
    digitalWrite(B_STEP_PIN, LOW);
  }
  if (C){
    digitalWrite(C_STEP_PIN, HIGH);
    digitalWrite(C_STEP_PIN, LOW);
  }
  delayMicroseconds(350);
}

void sendMovement(int numberOfStepsA, int numberOfStepsB, int numberOfStepsC){
bool done = false;
// Serial.println("number of steps A in sendMovement: ");
// Serial.println(numberOfStepsA);
  while(!done){
    // Serial.println("In while loop");
    if(numberOfStepsA >= 1 && aVerified){
      digitalWrite(A_STEP_PIN, HIGH);
      digitalWrite(A_STEP_PIN, LOW);
      digitalWrite(B_STEP_PIN, HIGH);
      digitalWrite(B_STEP_PIN, LOW);
      
    }
    if(numberOfStepsC >= 1 && cVerified){
      digitalWrite(C_STEP_PIN, HIGH);
      digitalWrite(C_STEP_PIN, LOW);
      
    }
  
    if (numberOfStepsA <= 0 && numberOfStepsB <=0 && numberOfStepsC <=0)
      done = true;
  
  numberOfStepsA --;
  numberOfStepsB --;
  numberOfStepsC --;

  delayMicroseconds(100);  
  }

  aVerified = false;
  bVerified = false;
  cVerified = false;
}
