import controlP5.*;
import org.json.*; 
import processing.net.*;
import processing.serial.*;
import java.awt.Frame;

// ------------------------------------------------------------------------------------

private int     end                 = 10;
private int     pose                = 1;
private int     gAngle              = 90;
private int     debugVariable       = 2;
private int     z                   = 220;
private int     y                   = 100;
private int     gGripperWidth       = 0;
private int     bioValue            = 0;
private int     globalID            = 0;
private int     led                 = 0;
private int     recordColor         = color(127, 127, 127);
private int     id                  = 0;
private int     storingID           = 0;
private int     packetCount         = 0;
private int     globalMax;
private int     tableIndex          = 0;
private int     tableIndexStoring   = 0;
private int     receivedHeartRate   = 0;
// private int     voice               = 0;
private int     isReadyColor        = 255;
private byte    caReturn            = 13;
private String  heartRateString     = "Na";
private String  inCharA;
private String  inCharM;
private String  inCharLA;
private String  inCharLB;
private String  scaleMode;
private String  arduinoPort               = "/dev/tty.usbmodem1d11241";
private String  melziPort                 = "/dev/tty.usbserial-AH01SIVE";
private String  pulseMeterPort            = "/dev/tty.BerryMed-SerialPort";
private String  ledPortA                  = "/dev/tty.usbmodem1d1111";
private String  ledPortB                  = "/dev/tty.usbmodem1d1141";
private boolean isRobotReadyToMove        = false;
private boolean isTraversReadyToMove      = false;
private boolean laLedIsready              = false;
private boolean isFirstContact            = false;
private boolean isRobotStarted            = false;
private boolean isRecording               = false;
private boolean isMindWaveData            = false;
private boolean isStoring                 = false;
private boolean isEsenseEvent             = false;
private boolean isReadyToRecord           = false;
private boolean isReadyToStore            = true;
private boolean gridYisDrawn              = false;
private boolean gridXisDrawn              = false;
private boolean isArduinoPort             = false;
private boolean isMelziPort               = false;
private boolean isLedPortA                = false;
private boolean isLedPortB                = false;
private boolean isPulseMeterPort          = false;
private boolean isTableSpeechLoaded       = false;
private boolean isReadyForButtonCommands  = false;
private boolean checkIfReadyForNextStep   = false;
private boolean readyToExecuteNextStep    = false;
private boolean stepForward               = false;
private boolean stepBack                  = false;

//------------------------------------------------------------------------------------

PImage bg;
Table table, tableRm, tablePositions;
WatchDog wPm, wA, wM, wLA, wLB;
ControlFont font;
Client myClient;
Drawings drawings;
ControlP5 controlP5;
Kinect kinect;
HelperClass helpers;
ManageCLE mindWaveCLE;
ManageSE manageSE;
TextToSpeech textToSpeech;
RobotAnimation robotAnimation;
TraversAnimation traversAnimation;
Robot robot;
Channel[] channelsMindwave = new Channel[3]; // switch to 11 and comment in channels to get full data
Channel[] channelPleth = new Channel[1];
Graph mindWave, emg, ecg, pleth;
Textlabel lableID, textID, fRate, headlineText_1, headlineText_2, textMindwave, attentionLevel, attentionValue, meditationLevel, meditationValue, blinkStrength, blinkValue, textPulseMeter, pulseLevel, pulseValue;
ConnectionLight connectionLight, bluetoothConnection, robotConnection, traversConnection, ledAConnection, ledBConnection;

// ------------------------------------------------------------------------------------

void setup() {
  frameRate(120);
	size(displayWidth, displayHeight,P2D);
  // size(1280,720,P2D);
  noSmooth();
  hint(ENABLE_RETINA_PIXELS);
  smooth(4);

  helpers = new HelperClass();
  manageSE  = new ManageSE();
  robot = new Robot();
  robot.loadRobotData();
  helpers.checkSerialPorts();

// ----------------------------------------

  // WachtDog: SleepTime Thread, NameDevice, Port, Buffering, initOK?, BautRate, isTypArduino, PApplet 
  wPm = new WatchDog(1,"PulseMeter", pulseMeterPort, false, isPulseMeterPort, 115200, false, false, this);
  wPm.start();
  wA = new WatchDog(1,"Arduino", arduinoPort, true, isArduinoPort, 115200, true, false, this);
  wA.start();
  wM = new WatchDog(1,"Melzi", melziPort, true, isMelziPort, 115200, true, false, this);
  wM.start();
  wLA = new WatchDog(1,"LED A", ledPortA, true, isLedPortA, 115200, true, false, this);
  wLA.start();
  wLB = new WatchDog(1,"LED B", ledPortB, true, isLedPortB, 115200, true, false,this);
  wLB.start();
  //activate textToSpeech thread
  textToSpeech = new TextToSpeech(1);
  textToSpeech.start();
  //activate robotAnimation thread
  robotAnimation = new RobotAnimation(1);
  robotAnimation.start();
  traversAnimation = new TraversAnimation(1);
  traversAnimation.start();

  // Set up the knobs and dials
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(color(0));
  controlP5.setColorBackground(color(127));
  drawings = new Drawings();
  delay(100);

// ----------------------------------------
  mindWaveCLE = new ManageCLE();
  println("before drwawing");
  drawings.CP5Init();
  // mindWaveCLE.thingearInit();

println("before setting fonts");
	font = new ControlFont(createFont("DIN-MediumAlternate", 12), 12);
println("before trying");
  try {
   mindWaveCLE.connectToMindWave(this); 
  } catch (Exception e) {
    println("Mindwave: " + e);    
  }

println("before channel init");  

  // ----------------------------------------
       
	// Creat the channel objects
	// yellow to purple and then the space in between, grays for the alphas
	channelsMindwave[0]  = new Channel("Signal Quality", color(0), "");
	channelsMindwave[1]  = new Channel("Attention", color(39, 160, 25), "");
	channelsMindwave[2]  = new Channel("Meditation", color(23, 26, 153), "");
	// channelsMindwave[3]  = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep");
	// channelsMindwave[4]  = new Channel("Theta", color(245, 80, 71), "Drowsy");
	// channelsMindwave[5]  = new Channel("Low Alpha", color(237, 0, 119), "Relaxed");
	// channelsMindwave[6]  = new Channel("High Alpha", color(212, 0, 149), "Relaxed");
	// channelsMindwave[7]  = new Channel("Low Beta", color(158, 18, 188), "Alert");
	// channelsMindwave[8]  = new Channel("High Beta", color(116, 23, 190), "Alert");
	// channelsMindwave[9]  = new Channel("Low Gamma", color(39, 25, 159), "???");
	// channelsMindwave[10] = new Channel("High Gamma", color(23, 26, 153), "???");
	
  delay(200);

  println("before mindwave channel init");  
	// Manual override for a couple of limits.
	channelsMindwave[0].minValue = 0;
	channelsMindwave[0].maxValue = 200;
	channelsMindwave[1].minValue = 0;
	channelsMindwave[1].maxValue = 100;
	channelsMindwave[2].minValue = 0;
	channelsMindwave[2].maxValue = 100;
  channelsMindwave[0].addDataPoint(0);
  channelsMindwave[1].addDataPoint(0);
  channelsMindwave[2].addDataPoint(0);

  println("before pleth channel init");  
  channelPleth[0] = new Channel("Pleth", color(255, 127, 0), "???");
  channelPleth[0].minValue = 0;
  channelPleth[0].maxValue = 100;
	channelPleth[0].addDataPoint(0);
// ----------------------------------------
  println("before graph init");  
	// Set up the graph
	mindWave = new Graph(0, 0, width, round(height / 2), channelsMindwave, 1000, "Shaded");
  pleth = new Graph(0, round(height / 2), width, round(height / 2), channelPleth, 500, "Lines");
  // ecg = new Graph(0, round(height * 0.30), width, round(height * 0.10), channelPleth, 200, "Lines");
  // emg = new Graph(0, round(height * 0.20), width, round(height * 0.10), channelPleth, 200, "Lines");
	
  println("before connection light init");  
	connectionLight     = new ConnectionLight(width - 98, 10, 10);
  bluetoothConnection = new ConnectionLight(width - 98, 30, 10);
  robotConnection     = new ConnectionLight(width - 98, 50, 10);
  traversConnection   = new ConnectionLight(width - 98, 70, 10);
  ledAConnection      = new ConnectionLight(width - 98, 90, 10);
  ledBConnection      = new ConnectionLight(width - 98, 110, 10);
  
  println("setting global max");  
	globalMax = 0;
  isReadyToRecord = true;
  inCharA = null;
  inCharM = null;
  inCharLA = null;
  inCharLB = null;
  isReadyForButtonCommands = true;
  println("Setup finished");  
  // kinect = addControlFrame("extra", 320,240);

    
}

// ------------------------------------------------------------------------------------

void draw() {


  background(180);
  pulseValue.setValue(heartRateString);

  if(channelsMindwave[1]!= null){
    if(channelsMindwave[1].points.size() > 0)
      attentionValue.setValue(String.valueOf(channelsMindwave[1].getLatestPoint().value));
  }
  
  if(channelsMindwave[2]!= null){
    if(channelsMindwave[2].points.size() > 0)
      meditationValue.setValue(String.valueOf(channelsMindwave[2].getLatestPoint().value));
  }

  lableID.setValue(String.valueOf(globalID));
  drawings.drawRectangle(0,0,width,height,0,0,255,255,255,150);
  

  mindWave.draw();
  mindWave.drawGrid();
  // emg.draw();
  // ecg.draw();
  pleth.draw();
  drawings.drawLine(0,height / 2, width, height/2,2);
  // drawings.drawLine(0,round(emg.y + (height * 0.10)), width, round(emg + (height * 0.10)),2);
  // drawings.drawLine(0,round(ecg.y + (height * 0.10)), width, round(ecg.y + (height * 0.10)),2);
  drawings.drawLine(0, height, width, height,2);
  drawings.drawLine(20,round(height * 0.535), 210, round(height * 0.535),1);
  noStroke();
  // drawings.drawRectangle(10,10,195,300,0,0,255,150);
  drawings.drawRectangle(round(width*0.008), round(height * 0.508) ,395,150,0,0,255,255,255,150);  
  drawings.drawRectangle(0, 0, 88, 118, width - 98, 10, 255,255,255, 150);
  drawings.drawRectangle(round(width*0.13), round(height * 0.49),40,20, 85,65, 255-isReadyColor ,isReadyColor - 50,0, 220);
	
  if(channelsMindwave[0]!= null){
    if(channelsMindwave[0].points.size() > 0)
    connectionLight.update(channelsMindwave[0].getLatestPoint().value);
  }
	
  connectionLight.draw();
  connectionLight.mindWave.draw();
  bluetoothConnection.update(wPm.conValue);
  bluetoothConnection.draw();
  bluetoothConnection.pulseMeter.draw();
  robotConnection.update(wA.conValue);
  robotConnection.draw();
  robotConnection.robot.draw();
  traversConnection.update(wM.conValue);
  traversConnection.draw();
  traversConnection.travers.draw();
  ledAConnection.update(wLA.conValue);
  ledAConnection.draw();
  ledAConnection.led_A.draw();
  ledBConnection.update(wLB.conValue);
  ledBConnection.draw();
  ledBConnection.led_B.draw();

  // if (isRobotStarted){

  //   if((frameCount%5)==0){

  //     float amplitude = 120;
  //     float x = amplitude * cos(angle);
  //     angle += aVelocity;
  //     calculateBioInput();

  //     gAngle = (int) map(x, 0, 100, 90, 00);
  //     z = (int) map (x,0, 100, 120, 250);
  //     z = (int) map (x,0, 100, 120, 250);
  //     gGripperWidth = (int) map(x, 0, 100, 0, 180);
  //     led = (int) map(x, 0, 100, 0, 255);
    
  //     robot.setRobotArm(x, 130, z, gAngle, gAngle, gGripperWidth, 1, true, 255, led, 255, led, 2);
  //     println("Robot Movement");
  //   }
  // }

  gridYisDrawn = false;
  gridXisDrawn = false;


  if(!textToSpeech.speaking && !robotAnimation.isInAnimation && isRobotReadyToMove)
    isReadyColor = 255;
  else if(!textToSpeech.speaking && robotAnimation.isInAnimation)
    isReadyColor = 180;
  else
    isReadyColor = 0;

  if(checkIfReadyForNextStep)
    helpers.checkStep();

  if(readyToExecuteNextStep){
    readyToExecuteNextStep = false;
    robot.readNextRobotPosition();
  }  

}

// ------------------------------------------------------------------------------------

void clientEvent(Client  myClient) {

	if (myClient.available() > 0) {
  
    byte[] inBuffer = myClient.readBytesUntil(caReturn);
  
    if (inBuffer != null){
    	String data = new String(inBuffer);
      mindWaveCLE.mindWave(data);

	  }
	}

}

// ------------------------------------------------------------------------------------

void serialEvent(Serial thisPort){


  if (thisPort == wPm.port && wPm.deviceInstanciated){
     manageSE.newPulse();
  }

  if (thisPort == wA.port && wA.deviceInstanciated){
    
    while (wA.port.available() > 0){
      inCharA = wA.port.readStringUntil(end);
    }
    if (inCharA != null) {
      manageSE.arduino(inCharA);
    }
  }

  if (thisPort == wM.port && wM.deviceInstanciated && isMelziPort){
    // println("In melzi event");
    
    while (wM.port.available() > 0){
      // println("In melzi event > 0");
      inCharM = wM.port.readStringUntil(end);
    }
    if (inCharM != null) {
      // println("In melzi event start manageSE");
      manageSE.melzi(inCharM);
    }
  }

  if (thisPort == wLA.port && wLA.deviceInstanciated && isLedPortA){
    // println("In melzi event");
    
    while (wLA.port.available() > 0){
      // println("In melzi event > 0");
      inCharLA = wLA.port.readStringUntil(end);
    }
    if (inCharLA != null) {
      // println("inCharLA: "+inCharLA);
      manageSE.lA(inCharLA);
    }
  }

  if (thisPort == wLB.port && wLB.deviceInstanciated && isLedPortB){
    // println("inCharLB: "+inCharLB);
    
    while (wLB.port.available() > 0){
      // println("In melzi event > 0");
      inCharLB = wLB.port.readStringUntil(end);
    }
    if (inCharLB != null) {
      // println("In melzi event start manageSE");
      manageSE.lB(inCharLB);
    }
  }
}

// ------------------------------------------------------------------------------------


void controlEvent(ControlEvent theEvent) {
  if(isReadyForButtonCommands){  
    if(theEvent.isAssignableFrom(Textfield.class)) {
      println("controlEvent: accessing a string from controller '"
              +theEvent.getName()+"': "
              +theEvent.getStringValue()
              );
      
      //globalID = Integer.parseInt(theEvent.getStringValue());
      //helpers.setStep();
      try {
        String[] list = split(theEvent.getStringValue(), ',');
        if (list.length == 1 && !textToSpeech.speaking && !checkIfReadyForNextStep){
          println("isTraversReadyToMove: "+isTraversReadyToMove);
          println("isRobotReadyToMove: "+isRobotReadyToMove);
          println("checkIfReadyForNextStep: "+checkIfReadyForNextStep);
          println("stepForward: "+stepForward);
          println("textToSpeech.speaking: "+textToSpeech.speaking);
          globalID = Integer.parseInt(list[0]);
          checkIfReadyForNextStep = true;
        }else if (list.length == 6){
          robot.setRobotArm( Integer.parseInt(list[0]), Integer.parseInt(list[1]), Integer.parseInt(list[2]), Integer.parseInt(list[3]), Integer.parseInt(list[4]), Integer.parseInt(list[5]), 200, true, 255, 255, 255, 255, 2); 
        }else if (list.length == 4){
          robot.sendTraversData(Integer.parseInt(list[0]), Integer.parseInt(list[1]), Integer.parseInt(list[2]), Integer.parseInt(list[3]));
        }
    
      } catch (Exception e) {
        println(e);
  
    }

   

  }

  if(theEvent.getName().equals("Reset_Robot")){
    println("reset robot event ");
    robot.setRobotArm( 0, 150, 50, 70, 90, 90, 200, true, 255, 255, 255, 255, 2); 
  }

  if(theEvent.getName().equals("X+")){
    robot.setRobotArm((lastX + debugVariable), lastY, lastZ, lastGripperAngle, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
      println("X+");
  }
  if(theEvent.getName().equals("X-")){
    robot.setRobotArm(lastX - debugVariable, lastY, lastZ, lastGripperAngle, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("X-");
  }
  if(theEvent.getName().equals("Y+")){
    robot.setRobotArm(lastX, lastY + debugVariable, lastZ, lastGripperAngle, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("Y+");
  }
  if(theEvent.getName().equals("Y-")){
    robot.setRobotArm(lastX, lastY - debugVariable, lastZ, lastGripperAngle, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("Y-");
  }
  if(theEvent.getName().equals("Z+")){
    robot.setRobotArm(lastX, lastY, lastZ + debugVariable, lastGripperAngle, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("Z+");
  }
  if(theEvent.getName().equals("Z-")){
    robot.setRobotArm(lastX, lastY, lastZ - debugVariable, lastGripperAngle, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("Z-");
  }
  if(theEvent.getName().equals("GA+")){
    robot.setRobotArm(lastX, lastY, lastZ, lastGripperAngle + debugVariable, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("GA+");
  }
  if(theEvent.getName().equals("GA-")){
    robot.setRobotArm(lastX, lastY, lastZ, lastGripperAngle - debugVariable, lastGripperRotation, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("GA-");
  }
  if(theEvent.getName().equals("GR+")){
    robot.setRobotArm(lastX, lastY, lastZ, lastGripperAngle, lastGripperRotation + debugVariable, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("GR+");
  }
  if(theEvent.getName().equals("GR-")){
    robot.setRobotArm(lastX, lastY, lastZ, lastGripperAngle, lastGripperRotation - debugVariable, lastGripperWidth, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("GR-");
  }
   if(theEvent.getName().equals("GC+")){
  robot.setRobotArm(lastX, lastY, lastZ, lastGripperAngle, lastGripperRotation, lastGripperWidth + debugVariable, 1, true, 255, lastR, lastG, lastB, lastLed);
  println("GC+");
  }
  if(theEvent.getName().equals("GC-")){
    robot.setRobotArm(lastX, lastY, lastZ, lastGripperAngle, lastGripperRotation, lastGripperWidth - debugVariable, 1, true, 255, lastR, lastG, lastB, lastLed);
    println("GC-");
  }

  if(theEvent.getName().equals("Start_Robot")){
  isRobotStarted = !isRobotStarted;
    if(isRobotStarted)
      println("robot started");
    else
      println("robot stoped");
    //isTimerStarted = !isTimerStarted;
  }

  if(theEvent.getName().equals("Back")){
    if(!stepBack && !textToSpeech.speaking && !checkIfReadyForNextStep){
        globalID--;
        textToSpeech.checkTableConstrains();
        checkIfReadyForNextStep = true;
        stepBack = true;
    }
  }

  if(theEvent.getName().equals("Forward")){
    if(!stepForward && !textToSpeech.speaking && !checkIfReadyForNextStep){
        globalID++;
        textToSpeech.checkTableConstrains();
        stepForward = true;
        checkIfReadyForNextStep = true;
    }  
  }
 }
} 


// public void Start_Recording() {
//   if(isReadyToRecord){
//     helpers.BeginRecording();
//   }
// }

// public void Stop_Recording() {
//   if(isReadyToRecord){
//     helpers.EndRecording();
//   }
// }

// ------------------------------------------------------------------------------------

void keyPressed(){

   if (key == CODED){
      if (keyCode == LEFT){
        // println("isTraversReadyToMove: "+isTraversReadyToMove);
        // println("isRobotReadyToMove: "+isRobotReadyToMove);
        // println("checkIfReadyForNextStep: "+checkIfReadyForNextStep);
        // println("stepForward: "+stepForward);
        // println("textToSpeech.speaking: "+textToSpeech.speaking);
        if(!stepBack && !textToSpeech.speaking && !checkIfReadyForNextStep){
          globalID--;
          textToSpeech.checkTableConstrains();
          checkIfReadyForNextStep = true;
          stepBack = true;
        }
      }
      if (keyCode == RIGHT){
        // println("isTraversReadyToMove: "+isTraversReadyToMove);
        // println("isRobotReadyToMove: "+isRobotReadyToMove);
        // println("checkIfReadyForNextStep: "+checkIfReadyForNextStep);
        // println("stepForward: "+stepForward);
        // println("textToSpeech.speaking: "+textToSpeech.speaking);
        if(!stepForward && !textToSpeech.speaking && !checkIfReadyForNextStep){
          globalID++;
          textToSpeech.checkTableConstrains();
          stepForward = true;
          checkIfReadyForNextStep = true;
        }  
      }
      if (keyCode == UP){
         robot.setRobotArm(0,debugVariable,200,45,90,90,200,true,255,0,255,0,2);
        // debugVariable += 2;

      }
      if (keyCode == DOWN){
         robot.setRobotArm(0,debugVariable,200,45,90,90,200,true,255,0,255,0,2);
        // debugVariable -= 2;
      }
    }
}

// ------------------------------------------------------------------------------------

Kinect addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  Kinect p = new Kinect(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(320, 240);
  f.setLocation(10, 240);
  f.setResizable(false);
  f.setVisible(true);
  f.setAlwaysOnTop(true);
  return p;
}

// ------------------------------------------------------------------------------------

void calculateBioInput(){

//dont forget to replace heartRate with 100
  bioValue = ((100 - channelsMindwave[2].getLatestPoint().value) + (100 - 60))/2;
  // println("Bio Value:" + bioValue + " " + channels[2].getLatestPoint().value + " " + heartRate );
}

// ------------------------------------------------------------------------------------

boolean sketchFullScreen() {
return true;
}