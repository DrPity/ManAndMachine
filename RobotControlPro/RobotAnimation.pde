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
    isNextStep = true;
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    sleepTime(300);
    // loadMovementData();
    while (running) {
      if(isAnimation){
        checkAnimations();
      }
      if(!textToSpeech.nextTextToSpeech && isRobotReadyToMove && !isNextStep){
        // standAnimation();
      }
    	sleepTime(wait);
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------

void checkAnimations(){

  isNextStep = true;
// int base              = 1475;
// int shoulder          = 1500;
// int elbow             = 2300;
// int wrist             = 800;
// int gripper           = 1500;
// int gripperAngle      = 1500;

// --- Number 1  WakeUP---
  if(movementID == 1){
  robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 0, 0, 255, 0, 2);
  waitForRobot();
    for(int i = 0; i <= 255; i++){
      robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 1, i, 0, 255, 0, 2);
      waitForRobot();
    }
    robot.sendRobotData(1475, 1500, 2300, 1200, 1500, 1500, 200, 255, 0, 255, 0,2);
    waitForRobot();
  }

// --- Number 2  Diagnostic---
   if(movementID == 2){

    robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(332.0,0.0,136.0,29.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-332.0,0.0,136.0,29.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    for(int i = 0; i <= 100; i++){
      robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,1,true,255,(int)random(0,255),(int)random(0, 255),(int)random(0, 255),0);
      waitForRobot();
      robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,1,true,255,(int)random(0,255),(int)random(0, 255),(int)random(0, 255),1);
      waitForRobot();
    }
    robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,1,true,255,255,0,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0,184.0,144.0,49.0,178,2,100,true,255,255,0,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0,184.0,144.0,49.0,178,178,100,true,255,255,0,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0,208.0,288.0,13.0,130,106,100,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0,148.0,120.0,13.0,130,106,250,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0,172.0,180.0,17.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
  }


  if(movementID == 3){

    robot.setRobotArm(-324,20,100,33,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(-324.0,20.0,100.0,33.0,130,34,300,true,255,0,0,255,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(-324,20,100,33,178,102,200,true,255,0,255,0,2);

 
  }

  // --- Number 4  Neutral forward---
    if(movementID == 4){
    println("In global 3");
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    sleepTime(100);
    while(isAnimation){
      standAnimation(15,10, true,false,false,false,true,false,0);
      if(!isNextStep){
        isAnimation = false;
        println("In break");
        break;
      }
    }
  }

// --- Number 5 right to left---  

  if(movementID == 5){
    robot.setRobotArm(88,28,216,1,186,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-124,100,208,17,186,90,100,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(88,28,216,1,186,90,100,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-124,100,208,17,186,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(88,28,216,1,186,90,100,true,255,0,255,0,2);

    sleepTime(50);

  }

  if(movementID == 6){

    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 255, 0, 255, 0,2);
    waitForRobot();
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    long frameTime = millis();
    standAnimation(15, 10, true,false,false,false,true,false, 3000);
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 255, 255, 0, 0,2);
  }

  if(movementID == 7){
    robot.setRobotArm(-7.75081,32.0,92.0,70.0,116,66,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(-13.971708,236.0,268.0,18.0,116,66,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    standAnimation(5,10,true,false,false,false,false,false,1000);
  }

  if(movementID == 8){
    robot.setRobotArm(-216,0,160,29,134,90,200,true,255,0,255,0,2);
    waitForRobot();
     while(isAnimation){
      standAnimation(15,10, false,false,false,false,true,false,0);
      if(!isNextStep){
        isAnimation = false;
        break;
      }
    }
  }

  // --- Number 9 dancing---  
  if(movementID == 9){

    robot.setRobotArm(-4,184,184,42,126,90,250,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-8.261391,184.0,184.0,42.0,121,90,200,true,255,255,0,255,3);
    waitForRobot();
    // standAnimation(10,10, false,true,true,false,true,false,10000);
    // standAnimation(10,15, true,false,true,true,false,true,10000);
    // robot.setRobotArm(-8.261391,184.0,184.0,42.0,121,90,300,true,255,255,0,255,2);
    // waitForRobot();
    // standAnimation(15,30, true,false,false,false,false,true,0);

      while(isAnimation){
        standAnimation(15,60, true,false,false,false,false,true,0);
        if(!isNextStep){
          isAnimation = false;
          break;
          //################# turn of LED'S!!!!! #############
        }
      }
    }

  // --- Number 10 look and listen right---  

  if(movementID == 10){

    robot.setRobotArm(-96,100,208,17,46,90,250,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-148.0,184.0,312.0,1.0,46,90,200,true,255,0,255,0,2);
    waitForRobot();
  
  }


  // --- Number 11 agressive---  

  if(movementID == 11){

  robot.setRobotArm(-12.0,128.0,-24.0,105.0,46,178,80,true,255,255,0,0,2);
  waitForRobot();
  for( int i = 0; i < 2; i++){
    robot.setRobotArm(-12.0,128.0,-24.0,105.0,46,6,30,true,255,255,0,0,2);
    waitForRobot();
    robot.setRobotArm(-12.0,128.0,-24.0,105.0,46,178,30,true,255,255,0,0,2);
    waitForRobot();
    }
  }

  // --- Number 12 shaking head---  

   if(movementID == 12){


    robot.setRobotArm(16.0,264.0,176.0,25.0,86,142,250,true,255,0,255,0,2);
    waitForRobot();
    for( int i = 0; i < 5; i++){
      robot.setRobotArm(132.0,224.0,176.0,25.0,86,142,100,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-132.0,224.0,176.0,25.0,86,142,100,true,255,0,255,0,2);
      waitForRobot();
    }
    robot.setRobotArm(16.0,264.0,176.0,25.0,86,142,150,true,255,0,255,0,2);
   }


    // --- Number 13 swichting off---  

   if(movementID == 13){
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 100, 0, 0, 255, 0, 2);
    waitForRobot();
   }

    // --- Number 13 threatend---  

   if(movementID == 14){

    robot.setRobotArm(-324.0,104.0,120.0,29.0,126,178,200,true,255,255,0,0,2 );
    waitForRobot();
    for( int i = 0; i < 2; i++){
      robot.setRobotArm(-324.0,104.0,120.0,29.0,126,6,200,true,255,255,0,0,2);
      waitForRobot();
      robot.setRobotArm(-324.0,104.0,120.0,29.0,126,178,200,true,255,255,0,0,2);
      waitForRobot();
    }

   }


   if(movementID == 15){

    robot.setRobotArm(8.0,180.0,120.0,49.0,182,86,300,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(8.0,145.0,279.0,0.0,182,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(8.0,180.0,120.0,49.0,182,86,400,true,255,0,255,0,2);
    waitForRobot();

   }

  if(movementID == 16){

    while(isAnimation){
      robot.setRobotArm(8.0,140.0,272.0,17.0,86,30,200,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-152.0,140.0,244.0,17.0,134,30,200,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(152.0,140.0,244.0,17.0,50,30,300,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-152.0,140.0,244.0,17.0,134,30,300,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(152.0,140.0,244.0,17.0,50,30,300,true,255,0,255,0,2);
      waitForRobot();
      if(!isNextStep){
        isAnimation = false;
        break;
        //################# turn of LED'S!!!!! #############
      }
    }

   }

    // --- Number 17 powerMove---  

  if(movementID == 17){

    while(isAnimation){
      robot.setRobotArm(-4.0,136.0,92.0,29.0,178,146,200,true,255,255,0,0,2);
      waitForRobot();
      sleepTime(800);
      robot.setRobotArm(-272.0,10.0,134.0,23.0,90,146,200,true,255,0,0,255,2);
      waitForRobot();
      robot.setRobotArm(-8.0,150.0,292.0,17.0,178,146,200,true,255,0,0,255,2);
      waitForRobot();
      robot.setRobotArm(272.0,10.0,134.0,23.0,90,146,200,true,255,0,0,255,2);
      waitForRobot();
      if(!isNextStep){
        isAnimation = false;
        break;
        //################# turn of LED'S!!!!! #############
      }
    }

  }

  if(movementID == 18){
    robot.setRobotArm(-4.0,136.0,92.0,29.0,178,146,200,true,33,255,0,0,2);
    waitForRobot();
    while(isAnimation){
      robot.setRobotArm(-4.0,162.0,244.0,29.0,178,146,200,true,33,255,0,0,2);
      waitForRobot();
      sleepTime(800);
      robot.setRobotArm(-4.0,162.0,202.0,29.0,178,146,200,true,33,255,0,0,2);
      waitForRobot();
      sleepTime(800);

      if(!isNextStep){
      isAnimation = false;
      break;
      //################# turn of LED'S!!!!! #############
      }
    }
  }


  if(movementID == 19){

    robot.setRobotArm(150.0,110.0,216.0,1.0,186,90,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-150.0,110.0,216.0,1.0,186,90,200,true,255,0,255,0,2);
    waitForRobot();
  }


  if(movementID == 20){
    robot.setRobotArm(-108.0,30.0,180.0,11.0,186,30,300,true,255,255,255,0,2);
    while(isAnimation){
      robot.setRobotArm(-108.0,30.0,180.0,11.0,186,30,600,true,255,255,255,0,2);
      waitForRobot();
      robot.setRobotArm(-158.0,30.0,180.0,11.0,44,180,600,true,255,255,255,0,2);
      waitForRobot();
      if(!isNextStep){
      isAnimation = false;
      break;
      //################# turn of LED'S!!!!! #############
      }
    }
  }
  

  





isNextStep = false;
isAnimation = false;
}

// ------------------------------------------------------------------------------------

void standAnimation(int runningDelay, float amp, boolean a, boolean b, boolean c, boolean d, boolean e, boolean f, int runningTime){
  frameTime = millis();
  int colorValues = 0;
  while(millis() - frameTime <= runningTime){

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
    
    if(!standValue)
      standValue = true;
    
    waitForRobot();
    sleepTime(runningDelay);

  }  
}

// ------------------------------------------------------------------------------------

	private void sleepTime(int sleepTime){
	  try {
	      sleep((long)(sleepTime));
	  } catch (Exception e) {
	    }

  }

// ------------------------------------------------------------------------------------
 
  // Our method that quits the thread
  private void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }

  private void waitForRobot(){
    while(!isRobotReadyToMove){
      sleepTime(10);
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