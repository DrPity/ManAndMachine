class TraversAnimation extends Thread{

private boolean running;           // Is the thread running?  Yes or no?
private boolean isOutOfLoop;
private boolean startPositionIsStoredT;
private boolean isAnimationT;
private boolean isInAnimationT;
private int wait;
private float   angleT;
private float   aVelocityT;
private int xStartValueT;
private int yStartValueT;
private int zStartValueT;
public int movementIDt;
private long frameTimeT;


// ------------------------------------------------------------------------------------

	TraversAnimation(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	void start () {
    running = true;
    println("Starting thread RobotAnimation (will execute every " + wait + " milliseconds.)");
    isOutOfLoop = true;
    startPositionIsStoredT = false;
    xStartValueT = 0;
    yStartValueT = 0;
    zStartValueT = 0;
    angleT         = 0;
    aVelocityT     = 0.2;
    frameTimeT = 0;
    movementIDt = 0;
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    sleepTime(300);
    while (running) {
      if(isAnimationT){
        // println("[ In check for Animation ]");
        checkAnimations();
      }
    	sleepTime(wait);
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------

private void checkAnimations(){
  isOutOfLoop = false;
  startPositionIsStoredT = false;
  isInAnimationT = true;

  // --- Number 1  WakeUP---
  if(movementIDt == 1){
    robot.sendTraversData(1000,1000,1500,5000);
    waitForTravers();
  }

  // --- Number 2  Diagnostic---
  if(movementIDt == 2){
    if(globalID == 57){
      robot.sendTraversData(2000,2000,2000,20000);
      waitForTravers();
      robot.sendTraversData(1100,1100,1500,10000);
      waitForTravers();
    }

  }

  // --- Number 3  changing music---
  if(movementIDt == 3){
    robot.sendTraversData(2000,2000,1500,5000);
    waitForTravers();
  }

  // --- Number 4  Neutral forward---
  if(movementIDt == 4){
    robot.sendTraversData(1000,1000,1500,5000);
    waitForTravers();
  }

  // --- Number 5 right to left---  
  if(movementIDt == 5){
    robot.sendTraversData(200,200,1800,5000);
    waitForTravers();

  }

  // --- Number 6 looking backwards---  
  if(movementIDt == 6){
    robot.sendTraversData(200,200,1800,5000);
    waitForTravers();
    // println(" In animation Nr 6 ");
  }

  // --- Number 7 sighing--- 
  if(movementIDt == 7){
    robot.sendTraversData(1000,1000,1500,5000);
    waitForTravers();
    // println(" In animation Nr 7 ");
  }

  // --- Number 8 neutral right---  
  if(movementIDt == 8){
    if(globalID == 40){
      robot.sendTraversData(1600,1600,1500,5000);
      waitForTravers();
    }else if(globalID == 71){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();
    }else if(globalID == 72){
      robot.sendTraversData(1900,1900,1600,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(1000,1000,1500,5000);
      waitForTravers();
    }

  }

  // --- Number 9 dancing---  
  if(movementIDt == 9){
    robot.sendTraversData(1000,1000,1400,5000);
    waitForTravers();
    while(isInAnimationT){
      standAnimationT(10,100, false,true,0);
    }
  }  

  // --- Number 10 look and listen right---  

  if(movementIDt == 10){
    if (globalID == 49){
    robot.sendTraversData(1300,1300,500,15000);
    waitForTravers();
    }else if(globalID == 75){
    robot.sendTraversData(1800,1800,1000,5000);
    }else{
    robot.sendTraversData(1300,1300,1500,5000);
    waitForTravers();
    }
  }


  // --- Number 11 agressive---  

  if(movementIDt == 11){
    if(globalID == 65){
      robot.sendTraversData(500,500,1900,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(1200,1200,1200,5000);
      waitForTravers();
    }
  }

  // --- Number 12 shaking head---  

  if(movementIDt == 12){

  }


    // --- Number 13 swichting off---  

  if(movementIDt == 13){
   
  }

  // --- Number 14 threatend---  
  if(movementIDt == 14){

  }

  // --- Number 15 looking from top to bottom---  
  if(movementIDt == 15){

  }

  // --- swaying --- 
  if(movementIDt == 16){

   }

  // --- Number 17 powerMove---  
  if(movementIDt == 17){

  }

  // --- Number 18 exhausted---
  if(movementIDt == 18){

  }

  // --- Number 19 looking left to right---
  if(movementIDt == 19){

  }

  // --- Number 20 threatening---
  if(movementIDt == 20){
    robot.sendTraversData(1500,1500,1800,5000);
    waitForTravers();
  }

  // --- Number 21 kinect---
  if(movementIDt == 21){
    while(isInAnimationT){
      if(kinect.zPositionUpdatedT && kinect.xPositionUpdatedT && kinect.context != null){
        robot.sendTraversData((int)kinect.zValueKinectT,(int)kinect.zValueKinectT,(int)kinect.xValueKinectT,(int)(kinect.zValueKinectT*4));
        kinect.zPositionUpdatedT = false;
        kinect.xPositionUpdatedT = false;
      }else if(kinect.xPositionUpdatedT){
        robot.sendTraversData(lastXt,lastYt,(int)kinect.xValueKinectT,(int)(kinect.xValueKinectT*3));
        kinect.xPositionUpdatedT = false;
      }else if(kinect.zPositionUpdatedT){
        robot.sendTraversData((int)kinect.zValueKinectT,(int)kinect.zValueKinectT,lastZt,(int)(kinect.zValueKinectT*4));
        kinect.zPositionUpdatedT = false;
      }
      waitForTravers();
    }
  }

  // --- Number 22 MindWave ---
  if(movementIDt == 22){
    if(channelsMindwave[1] != null && channelsMindwave[2] != null){
      while(isInAnimationT){
        int attention = channelsMindwave[1].getLatestPoint().value;
        int meditation = channelsMindwave[2].getLatestPoint().value;
        if (attention > 0 || meditation > 0){
          robot.sendTraversData((int)map(meditation, 0, 100, 0, 2000),(int)map(meditation, 0, 100, 0, 2000),(int)map(meditation, 0, 100, 500, 1500), ((-100 + meditation)*30) + 6000);
          waitForTravers();
        }else{
          robot.sendTraversData(0,0,0,8000);
        }
      }
    }  
  }


  // --- Number 23 MindWave ---
  if(movementIDt == 23){
    while(isInAnimationT){
      if(kinect.zPositionUpdatedT && kinect.xPositionUpdatedT && kinect.context != null){
        robot.sendTraversData((int)kinect.zValueKinectT,(int)kinect.zValueKinectT,(int)kinect.xValueKinectT,(int)(kinect.zValueKinectT*4));
        kinect.zPositionUpdatedT = false;
        kinect.xPositionUpdatedT = false;
      }else if(kinect.xPositionUpdatedT){
        robot.sendTraversData(lastXt,lastYt,(int)kinect.xValueKinectT,(int)(kinect.xValueKinectT*3));
        kinect.xPositionUpdatedT = false;
      }else if(kinect.zPositionUpdatedT){
        robot.sendTraversData((int)kinect.zValueKinectT,(int)kinect.zValueKinectT,lastZt,(int)(kinect.zValueKinectT*4));
        kinect.zPositionUpdatedT = false;
      }
      waitForTravers();
    } 
  }

  // --- Number 24 kinect with pulseMeter---
  if(movementIDt == 24){
    robot.sendTraversData(1000,1000,1800,5000);
    waitForTravers();
   
  }

  if(movementIDt == 25){
 
  }

  if(movementIDt == 26){
    
 
  }

  // --- Number 27 last position---
  if(movementIDt == 27){
    robot.sendTraversData(lastXt,lastYt,lastZt,5000);
    waitForTravers();
  }
  

  // --- Number 27 last position---
  if(movementIDt == 28){
    robot.sendTraversData(800,1000,0,10000);
    waitForTravers();
    sleepTime(1500);
    waitForRobot();
    robot.sendTraversData(1900,1900,1000,2000);
    waitForTravers();
    waitForRobot();
    robot.sendTraversData(200,200,2000,4000);
    waitForTravers();
    sleepTime(500);
    waitForRobot();
  }  

  // --- Number 27 last position---
  if(movementIDt == 29){
    robot.sendTraversData(2000,2000,2000,5000);
    waitForTravers();
  }



  // --- Number 22 MindWave ---
  if(movementIDt == 30){
    if(channelsMindwave[1] != null && channelsMindwave[2] != null){
      while(isInAnimationT){
        int attention = channelsMindwave[1].getLatestPoint().value;
        int meditation = channelsMindwave[2].getLatestPoint().value;
        robot.sendTraversData((int)map(attention, 0, 100, 2000, 100),(int)map(attention, 0, 100, 2000, 0),(int)map(attention, 0, 100, 500, 1500),((-100 + attention)*30) + 6000);
        waitForTravers();
      }
    }  
  }


  //talking left aroused
  if(movementIDt == 31){
    if (globalID == 73){
      robot.sendTraversData(1000,1000,500,15000);
      waitForTravers();
    }else if(globalID == 74){
      robot.sendTraversData(1000,1000,500,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(1700,1700,1600,5000);
      waitForTravers();
    }
  }

  isOutOfLoop = true;
  startPositionIsStoredT = false;
  isInAnimationT = false;
  isAnimationT = false;
  // println(" Done with animation "+movementIDt);
}


private void standAnimationT(int runningDelay, float amp, boolean xT, boolean zT, long runningTime){
  frameTimeT = millis();
  int colorValues = 0;
  while(millis() - frameTimeT <= runningTime){
    // println("In standAnimation");

    float amplitude = amp;
    float k = amplitude * cos(angleT);
    float kx = 0;
    float kz = 0;
    angleT += aVelocityT;

    if(!startPositionIsStoredT){
      println("In startposition stored Travers");
      xStartValueT = lastXt;
      yStartValueT = lastYt;
      zStartValueT = lastZt;
      startPositionIsStoredT = true;
      println("lastXt: " + lastXt + " lastYt: " + lastYt + " lastZt: " + lastZt + " startValueX: " + xStartValueT + "startValueY: " + yStartValueT + "startValueZ: " + zStartValueT);
    }

    if(xT)
      kx = k;
    if(zT)
      kz = k;

    robot.sendTraversData((int)(xStartValueT + kx), (int)(xStartValueT + kx), (int)(zStartValueT + kz), (int)abs(xStartValueT + k)/5 ); 
    waitForTravers();
    println(abs(xStartValueT + k)*10);
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
      sleepTime(2);
    }
  }

  private void waitForTravers(){
    while(!isTraversReadyToMove){
      sleepTime(2);
    }
  }


}