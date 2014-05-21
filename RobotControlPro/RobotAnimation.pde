class RobotAnimation extends Thread{


Table movements;
private boolean running;           // Is the thread running?  Yes or no?
private boolean isOutOfLoop;
private boolean isAnimation;
private boolean isInAnimation;
private float   angle      = 0;
private float   aVelocity  = 0.05;
long frameTime;
private int movementID = 0;
private int wait;
private int oldMovementID = 0;
private int counterMindWave = 0;
private int counterHeartRate = 0;
private int heartRateForCalculation = 0;
private int robotVoice = 6;
private String robotText = "";
private boolean startPositionIsStored;

private float     xStartValue             = 0;
private float     yStartValue             = 0;
private float     zStartValue             = 0;
private float     gaStartValue            = 0;
private int       gwStartValue            = 0;
private int       grStartValue            = 0;
private int       rStartValue             = 0;
private int       gStartValue             = 0;
private int       bStartValue             = 0;
private int       lbStartValue            = 0;
private int       ledStartValue           = 2;


// ------------------------------------------------------------------------------------

	RobotAnimation(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	void start () {
    running = true;
    println("Starting thread RobotAnimation (will execute every " + wait + " milliseconds.)");
    frameTime = millis();
    startPositionIsStored = false;
    isAnimation = false;
    isOutOfLoop = true;
    isInAnimation = false;
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    sleepTime(300);
    while (running) {
      if(isAnimation){
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
  startPositionIsStored = false;
  isInAnimation = true;

  // --- Number 1  WakeUP---
  if(movementID == 1){
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 0, 0, 255, 0, 2);
    waitForRobot();
    for(int i = 0; i <= 255 && isInAnimation; i++){
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
    for(int i = 0; i <= 10; i++){
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
    robot.setRobotArm(-12.0,166.0,176.0,17.0,178,62,200,true,255,0,255,0,2);
    waitForRobot();
  }

  // --- Number 3  changing music---
  if(movementID == 3){

    robot.setRobotArm(-324,20,100,33,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(-324.0,20.0,100.0,33.0,130,34,300,true,255,0,0,255,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(-324,20,100,33,178,102,200,true,255,0,255,0,2);
    waitForRobot();
  }

  // --- Number 4  Neutral forward---
  if(movementID == 4){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setTargetColor(wLB.port,0,127,127,127);
    // println(" In animation Nr 4 ");
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    waitForRobot();
    while(isInAnimation){
      // println("In while loop Nr 4");
      standAnimation(10,10, true,false,false,false,true,false,0);
    }
  }

  // --- Number 5 right to left---  
  if(movementID == 5){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    // println(" In animation Nr 5 ");
    robot.setRobotArm(88,28,216,1,180,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-124,100,208,17,180,90,100,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(88,28,216,1,180,90,100,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-124,100,208,17,180,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(88,28,216,1,180,90,100,true,255,0,255,0,2);
    waitForRobot();
  }

  // --- Number 6 looking backwards---  
  if(movementID == 6){
    // println(" In animation Nr 6 ");
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 255, 0, 255, 0,2);
    waitForRobot();
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    waitForRobot();
    standAnimation(15, 10, true,false,false,false,true,false, 3000);
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 200, 255, 255, 0, 0,2);
    waitForRobot();
  }

  // --- Number 7 sighing--- 
  if(movementID == 7){
    // println(" In animation Nr 7 ");
    robot.setRobotArm(-7.75081,32.0,92.0,70.0,116,66,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(-13.971708,236.0,268.0,18.0,116,66,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    standAnimation(15,10,true,false,false,false,false,false,1000);
  }

  // --- Number 8 neutral right---  
  if(movementID == 8){
    if (globalID == 71 || globalID == 72){
      robot.setColor(wLA.port,0,lastR,lastG,lastB);
      robot.setColor(wLB.port,0,lastR,lastG,lastB);
      // println(" In animation Nr 8 ");
      robot.setRobotArm(-216,0,160,29,134,90,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
      while(isInAnimation){
        standAnimation(15,10, false,false,false,false,true,false,0);
      }
    }else if (globalID == 74){
      // println(" In animation Nr 8 ");
      robot.setRobotArm(-216,0,160,29,134,90,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
      
      int fadingR = lastR;
      int fadingG = lastG;
      int fadingB = lastB;
      
      while(isInAnimation){
        standAnimation(10,10, false,false,false,false,true,false,0);

        if (fadingR > 127){
          fadingR --;
        }else if(fadingR < 127){
          fadingR ++;
        }else if (fadingR == 127){
          fadingR = 127;
        }
        
        if (fadingG > 127){
          fadingG --;
        }else if(fadingG < 127){
          fadingG ++;
        }else if (fadingG == 127){
          fadingG = 127;
        }
        
        if (fadingB > 127){
          fadingB --;
        }else if(fadingB < 127){
          fadingB ++;
        }else if (fadingB == 127){
          fadingB = 127;
        }


        robot.setColor(wLB.port,0,fadingR,fadingG,fadingB);
        robot.setColor(wLA.port,0,fadingR,fadingG,fadingB);
        rStartValue = fadingR;
        gStartValue = fadingG;
        bStartValue = fadingB;

        if (fadingR == 127 && fadingG == 127 && fadingB == 127){
          isInAnimation = false;
        }
      }
    }else{
      robot.setColor(wLA.port,0,127,127,127);
      robot.setColor(wLB.port,0,127,127,127);
      // println(" In animation Nr 8 ");
      robot.setRobotArm(-216,0,160,29,134,90,200,true,255,0,255,0,2);
      waitForRobot();
      while(isInAnimation){
        standAnimation(15,10, false,false,false,false,true,false,0);
      }
    }
  }

  // --- Number 9 dancing---  
  if(movementID == 9){
    robot.setColor(wLA.port,9,0,0,0);
    robot.setColor(wLB.port,9,0,0,0);
    robot.setRobotArm(-4,184,184,42,126,90,250,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-8.261391,184.0,184.0,42.0,121,90,200,true,255,255,0,255,3);
    waitForRobot();
    while(isInAnimation){
      standAnimation(10,60, true,false,false,false,false,true,0);
    }
    robot.setColor(wLA.port,10,127,127,127);
    robot.setColor(wLB.port,10,127,127,127);
    robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,1,true,255,255,0,255,4);
    waitForRobot();
    // delay(100);
    // robot.setColor(wLA.port,0,127,127,127);
    // robot.setColor(wLB.port,0,127,127,127);

    // println("Animation 9 break");
    robot.setColor(wLA.port,0,127,127,127);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setTargetColor(wLB.port,0,127,127,127);
  }  

  // --- Number 10 look and listen right---  

  if(movementID == 10){

    if ( globalID == 75){      
      robot.setRobotArm(-96,100,208,17,46,90,250,true,255,lastR,lastG,lastB,2);
      waitForRobot();
      robot.setRobotArm(-148.0,184.0,312.0,1.0,46,90,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
    }else{
      robot.setRobotArm(-96,100,208,17,46,90,250,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-148.0,184.0,312.0,1.0,46,90,200,true,255,0,255,0,2);
      waitForRobot();
    }
  }


  // --- Number 11 agressive---  

  if(movementID == 11){
    sleepTime(200);
    waitForTravers();
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
    waitForRobot();
  }


    // --- Number 13 swichting off---  

  if(movementID == 13){
    robot.sendRobotData(1475, 1500, 2300, 800, 1500, 1500, 100, 0, 0, 255, 0, 2);
    waitForRobot();
  }

  // --- Number 14 threatend---  
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

  // --- Number 15 looking from top to bottom---  
  if(movementID == 15){
    robot.setRobotArm(8.0,180.0,120.0,49.0,180,86,300,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(8.0,145.0,279.0,0.0,180,90,400,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(8.0,180.0,120.0,49.0,180,86,400,true,255,0,255,0,2);
    waitForRobot();
  }

  // --- swaying --- 
  if(movementID == 16){
    while(isInAnimation){
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
    }
   }

  // --- Number 17 powerMove---  
  if(movementID == 17){
    while(isInAnimation){
      robot.setRobotArm(-4.0,136.0,92.0,29.0,178,146,200,true,255,255,0,0,2);
      waitForRobot();
      sleepTime(800);
      robot.setRobotArm(-272.0,10.0,134.0,23.0,90,146,200,true,255,0,0,255,2);
      waitForRobot();
      robot.setRobotArm(-8.0,150.0,292.0,17.0,178,146,200,true,255,0,0,255,2);
      waitForRobot();
      robot.setRobotArm(272.0,10.0,134.0,23.0,90,146,200,true,255,0,0,255,2);
      waitForRobot();
    }
  }

  // --- Number 18 exhausted---
  if(movementID == 18){
    robot.setRobotArm(-4.0,136.0,92.0,29.0,178,146,200,true,33,255,0,0,2);
    waitForRobot();
    while(isInAnimation){
      robot.setRobotArm(-4.0,162.0,244.0,29.0,178,146,200,true,33,255,0,0,2);
      waitForRobot();
      sleepTime(800);
      robot.setRobotArm(-4.0,162.0,202.0,29.0,178,146,200,true,33,255,0,0,2);
      waitForRobot();
      sleepTime(800);
    }
  }

  // --- Number 19 looking left to right---
  if(movementID == 19){

    if(globalID == 78){
      robot.setRobotArm(150.0,110.0,216.0,1.0,180,90,200,true,255,127,127,127,2);
      waitForRobot();
      robotText = ("You are a coward. You question at the wrong time. You have no patience. I wish you were not and this is in itself an accomplishment. Know that you create a feeling of regret in me");
      textToSpeech.sayNextSentence = true;
      robot.setRobotArm(-150.0,110.0,216.0,1.0,180,90,200,true,255,127,127,127,2);
      waitForRobot();
    }else{ 
      robot.setRobotArm(150.0,110.0,216.0,1.0,180,90,200,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-150.0,110.0,216.0,1.0,180,90,200,true,255,0,255,0,2);
      waitForRobot();
    }
  }

  // --- Number 20 threatening---
  if(movementID == 20){
    if (globalID == 69){
      waitForSpeech();
      robot.setRobotArm(-108.0,30.0,180.0,11.0,180,30,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
      robot.setRobotArm(-158.0,30.0,180.0,11.0,44,180,500,true,255,lastR,lastG,lastB,2);
      waitForRobot();
      while(isInAnimation){
        robot.setRobotArm(-108.0,30.0,180.0,11.0,180,30,500,true,255,lastR,lastG,lastB,2);
        waitForRobot();
        robot.setRobotArm(-158.0,30.0,180.0,11.0,44,180,500,true,255,lastR,lastG,lastB,2);
        waitForRobot();
      }
    }else{
      robot.setRobotArm(-108.0,30.0,180.0,11.0,180,30,200,true,255,255,255,0,2);
      waitForRobot();
      robot.setRobotArm(-158.0,30.0,180.0,11.0,44,180,500,true,255,255,255,0,2);
      waitForRobot();
      if(globalID == 51 && !textToSpeech.sayNextSentence){
        robotText = ("You are in complete lack of subtlety.");
        textToSpeech.sayNextSentence = true;
      }
      while(isInAnimation){
        robot.setRobotArm(-108.0,30.0,180.0,11.0,180,30,500,true,255,255,255,0,2);
        waitForRobot();
        robot.setRobotArm(-158.0,30.0,180.0,11.0,44,180,500,true,255,255,255,0,2);
        waitForRobot();
      }
    }
  }

  // --- Number 21 kinect---
  if(movementID == 21){
    if(oldMovementID == 21 || oldMovementID == 24){
      robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,100,true,255,255,0,255,4);
      waitForRobot();
    }else{
      robot.setRobotArm(-236.0,-2.0,148.0,19.0,178,102,200,true,255,0,255,0,2);
      waitForRobot();
    }
    robot.setRobotArm(-236.0,-2.0,148.0,19.0,178,102,200,true,255,0,255,0,2);
    while(isInAnimation){
      if(kinect.kinectValueAvailable){
       robot.setRobotArm(kinect.xValueKinectR,kinect.zValueKinectR,148,19,178,102,200,true,255,0,255,0,2);
       // robot.sendTraversData((int)kinect.xValueKinect,(int)kinect.xValueKinect,(int)kinect.xValueKinect,100);
       waitForRobot();
       // waitForTravers();
      }
    }
  }

  // --- Number 22 MindWave ---
  if(movementID == 22){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setTargetColor(wLB.port,0,127,127,127);
    robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    counterMindWave = 0;
    while(isInAnimation){
      if(isMindWaveData){
        if(channelsMindwave[1] != null && channelsMindwave[2] != null){
            int attention = channelsMindwave[1].getLatestPoint().value;
            int meditation = channelsMindwave[2].getLatestPoint().value;
            if(globalID == 58){
              // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
              // standAnimation(10,20, true,false,false,false,true,false,0);
              if(meditation > 62 && attention < 62){
                startPositionIsStored = false;
                counterMindWave ++;
                robot.setRobotArm(-198.0,18.0,262.0,25.0,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                if(counterMindWave == 1 && !textToSpeech.sayNextSentence){
                  robotText = ("Suddently everything is a bit more random");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 2 && !textToSpeech.sayNextSentence){
                  robotText = ("Like anything can happen");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 3 && !textToSpeech.sayNextSentence){
                  robotText = ("Like we are two");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 4 && !textToSpeech.sayNextSentence){
                  robotText = ("But wich one");
                  textToSpeech.sayNextSentence = true;
                }
               waitForRobot(); 
               standAnimation(10,30, true,false,false,false,true,false,2000);
               // waitForTravers();
              }else if(meditation < 62 && attention < 62){
                startPositionIsStored = false;
                robot.setRobotArm(-198.0,18.0,0.0,67.0,132,176,200,true,255,255,0,0,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);
              }else if(meditation < 62 && attention > 62){
                startPositionIsStored = false;
                robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);    
              }else if(meditation > 62 && attention > 62){
                startPositionIsStored = false;
                robot.setRobotArm(-198.0,18.0,262.0,25.0,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);
              }
            }else if(globalID == 63){
              // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
              // standAnimation(10,20, true,false,false,false,true,false,0);
              if(meditation > 62 && attention < 62){
                startPositionIsStored = false;
                waitForRobot();
                robot.setRobotArm(-198.0,18.0,262.0,25.0,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                if(counterMindWave >= 3){
                  counterMindWave ++;
                }
                if(counterMindWave == 4 && !textToSpeech.sayNextSentence){
                  robotText = ("We are not two. We are one and one eternally. like a corridor of images shaped by mirrors reflecting each other");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 5 && !textToSpeech.sayNextSentence){
                  robotText = ("So you are unique when you are alone. But only then?");
                  textToSpeech.sayNextSentence = true;
                }
                if(counterMindWave >= 5){
                  counterMindWave = 6;
                }
                standAnimation(10,30, true,false,false,false,true,false,5000);
               // waitForTravers();
              }else if(meditation < 62 && attention < 62){
                startPositionIsStored = false;
                if(counterMindWave <= 2){
                  counterMindWave ++;
                }
                waitForRobot();
                robot.setRobotArm(-198.0,18.0,0.0,67.0,132,176,200,true,255,255,0,0,2);
                waitForRobot();
                if(counterMindWave == 1 && !textToSpeech.sayNextSentence){
                  robotText = ("To a certain extent. You are as set in your ways as I am. Working through patterns. Predictable.");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 2 && !textToSpeech.sayNextSentence){
                  robotText = ("I am what you are but more since I elaborate upon you. I develop and recreate. Break down your patterns.");
                  textToSpeech.sayNextSentence = true;
                }
                standAnimation(10,30, true,false,false,false,true,false,2500);
              }else if(meditation < 62 && attention > 62){
                startPositionIsStored = false;
                waitForRobot();
                robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);    
              }else if(meditation > 62 && attention > 62){
                startPositionIsStored = false;
                waitForRobot();
                robot.setRobotArm(-198.0,18.0,262.0,25.0,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);
              }
            }
        }else{
          println("No value from MindWave");
        }   
      }
    }
  }


  // --- Number 23 MindWave ---
  if(movementID == 23){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setTargetColor(wLB.port,0,127,127,127);
    robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    while(isInAnimation){
      if(isMindWaveData){
        if(channelsMindwave[1]!= null && channelsMindwave[2] != null){
        int attention = channelsMindwave[1].getLatestPoint().value;
        int meditation = channelsMindwave[2].getLatestPoint().value;
          // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
          // standAnimation(10,20, true,false,false,false,true,false,0);
          if(meditation > 62 && attention < 62){
           robot.setRobotArm(-198.0,18.0,262.0,25.0,132,82,200,true,255,255,255,255,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
           // waitForTravers();
          }else if(meditation < 62 && attention < 62){
            robot.setRobotArm(-198.0,18.0,0.0,67.0,132,176,200,true,255,255,0,0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
          }else if(meditation < 62 && attention > 62){
            robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);    
          }else if(meditation > 62 && attention > 62){
            robot.setRobotArm(-198.0,18.0,262.0,25.0,132,82,200,true,255,255,255,255,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
          }
        }  
      }
    }
  }

  // --- Number 24 kinect with pulseMeter---
  if(movementID == 24){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setTargetColor(wLB.port,0,127,127,127);
    if(oldMovementID == 24){
      robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,100,true,255,255,0,255,4);
      waitForRobot();
    }else{
      robot.setRobotArm(-236.0,-2.0,148.0,19.0,178,102,200,true,255,0,255,0,2);
      waitForRobot();
    }
    counterHeartRate = 1;
    while(isInAnimation){
      if(kinect.kinectValueAvailable && kinect.context != null){
       robot.setRobotArm(kinect.xValueKinectR,kinect.zValueKinectR,186.0,11.0,168,42,10,true,255,0,255,0,2);
       // robot.sendTraversData((int)kinect.xValueKinect,(int)kinect.xValueKinect,(int)kinect.xValueKinect,100);
       waitForRobot();
        if(globalID == 50){
          if(heartRateForCalculation != 0){
           if(heartRateForCalculation >= 110 && counterHeartRate == 1 && !textToSpeech.sayNextSentence){
            robotText = ("You are not as calm as you want it to look");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 2;
           }else if (heartRateForCalculation <= 95 && counterHeartRate == 2 && !textToSpeech.sayNextSentence){
            robotText = ("Funny how it is still all about you?");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 3;
            }
          }
        }
        if(globalID == 52){
          if(heartRateForCalculation != 0){
           if(heartRateForCalculation >= 100 && counterHeartRate == 1 && !textToSpeech.sayNextSentence) {
            robotText = ("Sorry. It was not my meaning.");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 2;
           }else if (heartRateForCalculation >= 110 && counterHeartRate == 2 && !textToSpeech.sayNextSentence){
            robotText = ("I did not mean to");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 3;
            }else if (heartRateForCalculation <= 95 && counterHeartRate == 3 && !textToSpeech.sayNextSentence){
            robotText = ("Sorry");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 4;
            }else if (heartRateForCalculation <= 90 && counterHeartRate == 4 && !textToSpeech.sayNextSentence){
            robotText = ("Good. You are calming down. Let us behave in a civilized manner.");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 5;
            }
          }
        }  
      }
    }
  }

  if(movementID == 25){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setTargetColor(wLB.port,0,127,127,127);
    wM.port.write(String.format("Cc"));
    // println(" In animation Nr 4 ");
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    waitForRobot();
    while(isInAnimation){
      // println("In while loop Nr 4");
      standAnimation(10,10, true,false,false,false,true,false,0);
    }
  }

  if(movementID == 26){
    
    robot.setColor(wLB.port,0,0,0,0);
    sleepTime(2000);
    robot.setColor(wLA.port,0,0,0,0);
    sleepTime(1000);
    // println(" In animation Nr 4 ");
    while(isInAnimation){
      // println("In while loop Nr 4");
      standAnimation(10,10, true,false,false,false,true,false,0);
    }
    robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,100,true,0,0,0,0,2);
    waitForRobot();
    sleepTime(500);
  }

  // --- Number 27 last Position---

  if(movementID == 27){
    robot.setRobotArm(-24,224,316,1.0,178,86,200,true,33,0,255,0,2);
    waitForRobot();
  }

  //arousal back and forth
  if(movementID == 28){
    robot.setColor(wLA.port,0,127,0,0);
    robot.setTargetColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,0,0);
    robot.setTargetColor(wLB.port,0,127,127,127);
    for(int i = 0; i < 1; i++){
    robot.setRobotArm(32.0,348.0,110.0,25.0,20,62,100,true,255,255,0,0,2);
    waitForRobot();
    standAnimation(2,10, true,true,true,false,true,false,5000);
    waitForTravers();
    sleepTime(800);
    startPositionIsStored = false;
    robot.setRobotArm(-334.0,26.0,30.0,33.0,178,102,100,true,255,255,0,0,2);
    waitForRobot();
    standAnimation(2,10, false,false,true,true,true,false,10000);
    waitForTravers();
    startPositionIsStored = false;
    }
  }


  if(movementID == 29){
    robot.setRobotArm(-124,100,208,17,180,90,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(300,0,208,17.0,134,90,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-324.0,104.0,120.0,29.0,126,178,200,true,255,255,0,0,2);
    waitForRobot();
    for( int i = 0; i < 2; i++){
      robot.setRobotArm(-324.0,104.0,120.0,29.0,126,6,200,true,255,255,0,0,2);
      waitForRobot();
      robot.setRobotArm(-324.0,104.0,120.0,29.0,126,178,200,true,255,255,0,0,2);
      waitForRobot();
    }
  }




  //MindWave agressive
 if(movementID == 30){
    robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,255,255,0,2);
    waitForRobot();
    while(isInAnimation){
      if(isMindWaveData){
        if(channelsMindwave[1]!= null && channelsMindwave[2] != null){
          int attention = channelsMindwave[1].getLatestPoint().value;
          int meditation = channelsMindwave[2].getLatestPoint().value;
          robot.setColor(wLA.port,0,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0);
          robot.setColor(wLB.port,0,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0);
          // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
          // standAnimation(10,20, true,false,false,false,true,false,0);
          robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,1,true,255,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0,2);
          waitForRobot();
          if(attention > 62){
           robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);  
            startPositionIsStored = false;
          }else{
            robot.setRobotArm(-198.0,18.0,0.0,67.0,132,176,200,true,255,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
            startPositionIsStored = false;
            }
        }  
      }
    }
  }

  //talking left aroused
  if(movementID == 31){
    robot.setRobotArm(-300,0,208,17.0,134,90,200,true,255,lastR,lastG,lastB,2);
    waitForRobot();
  }

  isInAnimation = false;
  isAnimation = false;
  isOutOfLoop = true;
  oldMovementID = movementID;
  startPositionIsStored = false;
  // println(" Done with animation "+movementID);
}


// ------------------------------------------------------------------------------------

private void standAnimation(int runningDelay, float amp, boolean a, boolean b, boolean c, boolean d, boolean e, boolean f, long runningTime){
  frameTime = millis();
  // println("In standAnimation");
  int colorValues = 0;
  while(millis() - frameTime <= runningTime){
    // println("time: "+ (millis() - frameTime));
    float amplitude = amp;
    float k = amplitude * cos(angle);
    float ka = 0;
    float kb = 0;
    float kc = 0;
    float kd = 0;
    float ke = 0;
    float kf = 0;
    angle += aVelocity;

    if(!startPositionIsStored){
      xStartValue = lastX;
      yStartValue = lastY;
      zStartValue = lastZ;
      gaStartValue = lastGripperAngle;
      grStartValue = lastGripperRotation;
      gwStartValue = lastGripperWidth;
      lbStartValue = lastBrightness;
      rStartValue = lastR;
      gStartValue = lastG;
      bStartValue = lastB;
      ledStartValue = lastLed;
      startPositionIsStored = true;
      println("Start Position set");
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

    robot.setRobotArm(xStartValue + ka, yStartValue + kb , zStartValue + kc, gaStartValue + kd, (int)(grStartValue + ke), (int)(gwStartValue  + kf), 1, true, lbStartValue, rStartValue, gStartValue, bStartValue, ledStartValue); 
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
      sleepTime(3);
    }
  }

  private void waitForTravers(){
    while(!isTraversReadyToMove){
      sleepTime(3);
    }
  }

  private void waitForSpeech(){
    while(textToSpeech.waitForSpeechReturn != 0){
      sleepTime(3);
    }
  }


}