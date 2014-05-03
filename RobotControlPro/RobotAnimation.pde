class RobotAnimation extends Thread{

boolean running;           // Is the thread running?  Yes or no?
boolean isNextAnimation;
int wait;
long frameTime;
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
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    // sleep(2000);
    sleep(300);
    while (running) {
      if(isNextAnimation){
        checkAnimations();
      }
      if(!textToSpeech.nextTextToSpeech && isRobotReadyToMove && !isNextAnimation){
        standAnimation();
      }
    	sleep(wait);
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------

void checkAnimations(){

  println("In checkAnimations");

  if(globalID == 1){
    //currentBase, currentShoulder, currentElbow, currentWrist, currentGripperAngle, currentGripperWidth, currentLight, currentEasing, currentBrightness

    //  BASE_MAX            = 2150;//2300;
    //  BASE_MIN            = 800;//720;
    //  SHOULDER_MAX        = 2350; 
    //  SHOULDER_MIN        = 720; 
    //  ELBOW_MAX           = 2370; 
    //  ELBOW_MIN           = 720;
    //  WRIST_MAX           = 2370; 
    //  WRIST_MIN           = 720;
    //  GRIPPER_ANGLE_MAX   = 2400;
    //  GRIPPER_ANGLE_MIN   = 600;
    //  GRIPPER_MAX         = 2100;
    //  GRIPPER_MIN         = 1450;  

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

isNextAnimation = false;


}

// ------------------------------------------------------------------------------------

void standAnimation(){

if (false){

    if((millis() - frameTime) >= 10){

      float amplitude = 10;
      float y = amplitude * cos(angle);
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
        standValue = true;
      }  
    
      robot.setRobotArm((xStand + y), yStand, (zStand +(y/2)), gaStand, grStand, gwStand, 1, true, lbStand, rStand, gStand, bStand, ledStand);
      frameTime = millis();
    }
  }

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


}