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
      robot.sendTraversData(1000,1000,1500,5000);
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
    }else{
    robot.sendTraversData(1300,1300,1500,5000);
    waitForTravers();
    }
  }


  // --- Number 11 agressive---  

  if(movementIDt == 11){
    robot.sendTraversData(1200,1200,1200,5000);
    waitForTravers();

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
   
  }

  // --- Number 22 MindWave ---
  if(movementIDt == 22){
  
  }


  // --- Number 23 MindWave ---
  if(movementIDt == 23){
   
  }

  // --- Number 24 kinect with pulseMeter---
  if(movementIDt == 24){
    robot.sendTraversData(1000,1000,1500,5000);
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