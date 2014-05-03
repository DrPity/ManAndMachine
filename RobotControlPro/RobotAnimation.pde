class RobotAnimation extends Thread{


Table movements;
boolean running;           // Is the thread running?  Yes or no?
boolean isNextStep;
boolean isAnimation;
long frameTime;
int movementID = 0;
int wait;
boolean standValue;

float     xStand             = 0;
float     yStand             = 0;
float     zStand             = 0;
float     gaStand            = 0;
int       gwStand            = 0;
int       grStand            = 0;
int       rStand             = 0;
int       gStand             = 0;
int       bStand             = 0;
int       lbStand            = 0;
int       ledStand           = 2;


// ------------------------------------------------------------------------------------

	RobotAnimation(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	void start () {
    running = true;
    println("Starting thread RobotAnimation (will execute every " + wait + " milliseconds.)");
    frameTime = millis();
    standValue = false;
    isAnimation = false;
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    sleep(300);
    // loadMovementData();
    while (running) {
      if(isAnimation){
        checkAnimations();
      }
      if(!textToSpeech.nextTextToSpeech && isRobotReadyToMove && !isNextStep){
        // standAnimation();
      }
    	sleep(wait);
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------

void checkAnimations(){

  isNextStep = false;


// --- Number 1  Diagnostic---
  if(movementID == 1){

    robot.sendRobotData(1475, 1500, 1500, 720, 675, 2100, 200, 0, 0, 0, 0, 2);
    sleep(2000);
    // Led
    for(int i = 0; i <= 127; i++){
      robot.sendRobotData(1475, 1500, 1500, 720, 675, 2100, 1, i, 255, 0, 0, 2);
      sleep(20);
    }
    sleep(1000);
    robot.sendRobotData(2150, 1500, 1500, 720, 650, 2100, 200, 127, 255, 255, 0,0);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 720, 650, 2100, 200, 127, 100, 255, 0,1);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 1800, 650, 2100, 200, 127, 100, 255, 0,1);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 720, 650, 2100, 200, 127, 100, 255, 0,1);
    sleep(2000);
    robot.sendRobotData(800, 1500, 1500, 720, 650, 2100, 200, 127, 255, 0, 0,0);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 900, 650, 1450, 200, 127, 0, 255, 0,1);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 900, 650, 2100, 200, 127, 255, 0, 255,0);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 900, 650, 2100, 200, 127, 255, 255, 255,1);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 900, 650, 2100, 200, 127, 255, 0, 255,0);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 900, 650, 2100, 200, 127, 0, 0, 255,1);
    sleep(2000);
    robot.sendRobotData(1475, 1500, 1500, 900, 650, 2100, 200, 127, 0, 255, 0,2);
    sleep(2000);

    for(int i = 127; i <= 255; i++){
      robot.sendRobotData(1475, 1500, 1500, 900, 675, 2100, 1, i, 0, 255, 0, 2);
      sleep(20);
    }

    sleep(1000);
    robot.setRobotArm(0,219,200,45,90,90,200,true,255,0,255,0,2);
    sleep(1000);
  }

// --- Number 2 neutral forward---  
  if(movementID == 2){
    println("In global 3");
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    sleep(100);
    while(isAnimation){
      standAnimation(10, true,false,false,false,true,false);
      sleep(15);
      if(isNextStep){
        println("In break");
        isAnimation = false;
        break;
      }
    }
  }

// --- Number 3 right to left---  

  if(movementID == 3){
    robot.setRobotArm(88,28,216,1,186,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-124,100,208,17,186,90,100,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(88,28,216,1,186,90,100,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-124,100,208,17,186,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(88,28,216,1,186,90,100,true,255,0,255,0,2);

    sleep(50);

  }

  if(movementID == 4){

    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 255, 0, 255, 0,2);
    waitForRobot();
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    long frameTime = millis();
     while((millis() - frameTime) <= 3000){
      standAnimation(10, true,false,false,false,true,false);
      sleep(15);
      }
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 255, 255, 0, 0,2);
  }

isAnimation = false;
}

// ------------------------------------------------------------------------------------

void standAnimation(float amp, boolean a, boolean b, boolean c, boolean d, boolean e, boolean f){

  float amplitude = amp;
  float k = amplitude * cos(angle);
  float ka = 0;
  float kb = 0;
  float kc = 0;
  float kd = 0;
  float ke = 0;
  float kf = 0;
  angle += aVelocity;

  if(!standValue){
    xStand = lastX;
    yStand = lastY;
    zStand = lastZ;
    gaStand = lastGripperAngle;
    grStand = lastGripperRotation;
    gwStand = lastGripperWidth;
    lbStand = lastBrightness;
    rStand = lastR;
    gStand = lastG;
    bStand = lastB;
    ledStand = lastLed;
  }

  if(a)
    ka = k;
  if(b)
    kb = k;
  if(c)
    kc = k;
  if(d)
    kd = k;
  if(e)
    ke = k;
  if(f)
    kf = k;

  robot.setRobotArm(xStand + ka, yStand + kb , zStand + kc, gaStand + kd, (int)(grStand + ke), (int)(gwStand  + kf), 1, true, lbStand, rStand, gStand, bStand, ledStand);  
  standValue = true;
}

// ------------------------------------------------------------------------------------

	 void sleep(int sleepTime){
	  try {
	      sleep((long)(sleepTime));
	  } catch (Exception e) {
	    }

  }

// ------------------------------------------------------------------------------------
 
  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }

  void waitForRobot(){
    while(!isRobotReadyToMove){
      sleep(20);
    }
  }


//   void loadMovementData(){

//     tableMovements = loadTable("data/Movements.csv", "header");
//   }

// // ------------------------------------------------------------------------------------

//   void readNextRobotPosition(){
//   if(newPosition && globalID <= (tablePositions.getRowCount() -1) && globalID >= 0){

//         int x = tablePositions.getInt(globalID, "X");
//         int y = tablePositions.getInt(globalID, "Y");
//         int z = tablePositions.getInt(globalID, "Z");
//         int gripperAngle = tablePositions.getInt(globalID, "GripperAngle");
//         int gripperRotation = tablePositions.getInt(globalID, "GripperRotation");
//         int gripperWidth = tablePositions.getInt(globalID, "GripperWidth");
//         int easing = tablePositions.getInt(globalID, "Easing");
//         int brightn = tablePositions.getInt(globalID, "Brightness");
//         int r = tablePositions.getInt(globalID, "r");
//         int g = tablePositions.getInt(globalID, "g");
//         int b = tablePositions.getInt(globalID, "b");
//         int x1 = tablePositions.getInt(globalID, "X1");
//         int y1 = tablePositions.getInt(globalID, "Y1");
//         //call streching somewhere here
//         // setRobotArm() here
//         if(globalID > 1){
//         //float x, float y, float z, float gripperAngleD, int gripperRotation, int gripperWidth, int easingResolution, boolean sendData, int brightnessStrip, int r, int g,  int b, int led
//           setRobotArm(x,y,z,gripperAngle,gripperRotation,gripperWidth,easing,true,brightn,r,g,b,2);
//           println("[ " + x + "," + y + "," + z + "," + gripperAngle + "," + gripperRotation +  "," + gripperWidth + "," + easing + "," + brightn + "," + r + "," + g + "," + b + "," + x1 + "," + y1 + " ]");
//         }

//         newPosition = false;
//       }
//   }


}