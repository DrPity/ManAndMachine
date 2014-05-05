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
private int     voice               = 0;
private int     isReadyColor        = 255;
private byte    caReturn            = 13;
private String  heartRateString     = "Na";
private String  inCharA;
private String  inCharM;
private String  scaleMode;
private String  arduinoPort               = "/dev/tty.usbmodem1d1141";
private String  melziPort                 = "/dev/tty.usbserial-AH01SIVE";
private String  pulseMeterPort            = "/dev/tty.BerryMed-SerialPort";
private float   angle                     = 0;
private float   aVelocity                 = 0.05;
private boolean isRobotReadyToMove        = false;
private boolean isTraversReadyToMove      = false;
private boolean isFirstContact            = false;
private boolean isRobotStarted            = false;
private boolean isRecording               = false;
private boolean isStoring                 = false;
private boolean isEsenseEvent             = false;
private boolean isReadyToRecord           = false;
private boolean isReadyToStore            = true;
private boolean gridYisDrawn              = false;
private boolean gridXisDrawn              = false;
private boolean isArduinoPort             = false;
private boolean isMelziPort               = false;
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
WatchDog wPm, wA, wM;
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
Robot robot;
Channel[] channelsMindwave = new Channel[11];
Channel[] channelPleth = new Channel[1];
Graph mindWave, emg, ecg, pleth;
Textlabel lableID, textID, fRate, headlineText_1, headlineText_2, textMindwave, attentionLevel, attentionValue, meditationLevel, meditationValue, blinkStrength, blinkValue, textPulseMeter, pulseLevel, pulseValue;
ConnectionLight connectionLight, bluetoothConnection, robotConnection, traversConnection;

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
  wPm = new WatchDog(1,"PulseMeter", pulseMeterPort, false, isPulseMeterPort, 115200, false, this);
  wPm.start();
  wA = new WatchDog(1,"Arduino", arduinoPort, true, isArduinoPort, 115200, true, this);
  wA.start();
  wM = new WatchDog(1,"Melzi", melziPort, true, isMelziPort, 115200, true, this);
  wM.start();
  //activate textToSpeech thread
  textToSpeech = new TextToSpeech(1);
  textToSpeech.start();
  //activate robotAnimation thread
  robotAnimation = new RobotAnimation(1);
  robotAnimation.start();

// ----------------------------------------

	// Set up the knobs and dials
	controlP5 = new ControlP5(this);
	controlP5.setColorLabel(color(0));
	controlP5.setColorBackground(color(127));
  drawings = new Drawings();
  mindWaveCLE = new ManageCLE();
  drawings.CP5Init();
  // mindWaveCLE.thingearInit();

	font = new ControlFont(createFont("DIN-MediumAlternate", 12), 12);
  mindWaveCLE.connectToMindWave(this);

  // ----------------------------------------
       
	// Creat the channel objects
	// yellow to purple and then the space in between, grays for the alphas
	channelsMindwave[0]  = new Channel("Signal Quality", color(0), "");
	channelsMindwave[1]  = new Channel("Attention", color(100), "");
	channelsMindwave[2]  = new Channel("Meditation", color(50), "");
	channelsMindwave[3]  = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep");
	channelsMindwave[4]  = new Channel("Theta", color(245, 80, 71), "Drowsy");
	channelsMindwave[5]  = new Channel("Low Alpha", color(237, 0, 119), "Relaxed");
	channelsMindwave[6]  = new Channel("High Alpha", color(212, 0, 149), "Relaxed");
	channelsMindwave[7]  = new Channel("Low Beta", color(158, 18, 188), "Alert");
	channelsMindwave[8]  = new Channel("High Beta", color(116, 23, 190), "Alert");
	channelsMindwave[9]  = new Channel("Low Gamma", color(39, 25, 159), "???");
	channelsMindwave[10] = new Channel("High Gamma", color(23, 26, 153), "???");
	
	// Manual override for a couple of limits.
	channelsMindwave[0].minValue = 0;
	channelsMindwave[0].maxValue = 200;
	channelsMindwave[1].minValue = 0;
	channelsMindwave[1].maxValue = 100;
	channelsMindwave[2].minValue = 0;
	channelsMindwave[2].maxValue = 100;

  channelPleth[0] = new Channel("Pleth", color(255, 127, 0), "???");
  channelPleth[0].minValue = 0;
  channelPleth[0].maxValue = 100;
	
// ----------------------------------------

	// Set up the graph
	mindWave = new Graph(0, 0, width, round(height * 0.10), channelsMindwave, 1000, "Lines");
  pleth = new Graph(0, round(height * 0.10), width, round(height * 0.10), channelPleth, 200, "Lines");
  ecg = new Graph(0, round(height * 0.30), width, round(height * 0.10), channelPleth, 200, "Lines");
  emg = new Graph(0, round(height * 0.20), width, round(height * 0.10), channelPleth, 200, "Lines");
	
	connectionLight     = new ConnectionLight(width - 98, 10, 10);
  bluetoothConnection = new ConnectionLight(width - 98, 30, 10);
  robotConnection     = new ConnectionLight(width - 98, 50, 10);
  traversConnection   = new ConnectionLight(width - 98, 70, 10);
  

	globalMax = 0;
  isReadyToRecord = true;
  inCharA = null;
  inCharM = null;
  isReadyForButtonCommands = true;
  // kinect = addControlFrame("extra", 320,240);
    
}

// ------------------------------------------------------------------------------------

void draw() {


  background(180);
  pulseValue.setValue(heartRateString);
  attentionValue.setValue(String.valueOf(channelsMindwave[1].getLatestPoint().value));
  meditationValue.setValue(String.valueOf(channelsMindwave[2].getLatestPoint().value));
  lableID.setValue(String.valueOf(globalID));
  drawings.drawRectangle(0,0,width,round(height*0.40),0,0,255,255,255,150);
  

  mindWave.draw();
  mindWave.drawGrid();
  // emg.draw();
  // ecg.draw();
  pleth.draw();
  drawings.drawLine(0,round(mindWave.y + (height * 0.10)), width, round(mindWave.y + (height * 0.10)),2);
  drawings.drawLine(0,round(emg.y + (height * 0.10)), width, round(emg.y + (height * 0.10)),2);
  drawings.drawLine(0,round(ecg.y + (height * 0.10)), width, round(ecg.y + (height * 0.10)),2);
  drawings.drawLine(0,round(pleth.y + (height * 0.10)), width, round(pleth.y + (height * 0.10)),2);
  drawings.drawLine(20,round(height * 0.44), 210, round(height * 0.44),1);
  noStroke();
  // drawings.drawRectangle(10,10,195,300,0,0,255,150);
  drawings.drawRectangle(round(width*0.008), round(height * 0.408) ,400,300,0,0,255,255,255,150);  
  drawings.drawRectangle(0, 0, 88, 78, width - 98, 10, 255,255,255, 150);
  drawings.drawRectangle(round(width*0.13), round(height * 0.49),40,20, 60,0, 255-isReadyColor ,isReadyColor - 50,0, 220);
	connectionLight.update(channelsMindwave[0].getLatestPoint().value);
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


  if (isRobotStarted){

    if((frameCount%5)==0){

      float amplitude = 120;
      float x = amplitude * cos(angle);
      angle += aVelocity;
      calculateBioInput();

      gAngle = (int) map(x, 0, 100, 90, 00);
      z = (int) map (x,0, 100, 120, 250);
      z = (int) map (x,0, 100, 120, 250);
      gGripperWidth = (int) map(x, 0, 100, 0, 180);
      led = (int) map(x, 0, 100, 0, 255);
    
      robot.setRobotArm(x, 130, z, gAngle, gAngle, gGripperWidth, 1, true, 255, led, 255, led, 2);
      println("Robot Movement");
    }
  }

  gridYisDrawn = false;
  gridXisDrawn = false;


  if(!textToSpeech.nextTextToSpeech && !robotAnimation.isInAnimation && isRobotReadyToMove)
    isReadyColor = 255;
  else if(!textToSpeech.nextTextToSpeech && robotAnimation.isInAnimation)
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
    println("In melzi event");
    
    while (wM.port.available() > 0){
      println("In melzi event > 0");
      inCharM = wM.port.readStringUntil(end);
    }
    if (inCharM != null) {
      println("In melzi event start manageSE");
      manageSE.melzi(inCharM);
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

      String[] list = split(theEvent.getStringValue(), ',');
      if (list.length == 1){
        println(list.length + "Arrrrrrrg");
        globalID = Integer.parseInt(list[0]);
        checkIfReadyForNextStep = true;
      }else if (list.length == 6){
        robot.setRobotArm( Integer.parseInt(list[0]), Integer.parseInt(list[1]), Integer.parseInt(list[2]), Integer.parseInt(list[3]), Integer.parseInt(list[4]), Integer.parseInt(list[5]), 200, true, 255, 255, 255, 255, 2); 
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
    if(!stepBack && !textToSpeech.nextTextToSpeech && !checkIfReadyForNextStep){
        globalID--;
        textToSpeech.checkTableConstrains();
        checkIfReadyForNextStep = true;
        stepBack = true;
    }
  }

  if(theEvent.getName().equals("Forward")){
    if(!stepForward && !textToSpeech.nextTextToSpeech && !checkIfReadyForNextStep){
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
        int yy = robot.stretching(20);
        println("#streched Position in keyPressed Left: "  + yy);
        robot.setRobotArm(0, yy, 80, 45, 90, 90, 200, true, 255,255,0,255,2);
        println("+ IsStRun: +" + isStrRun); 
      }
      if (keyCode == RIGHT){
        int yy = robot.stretching(50);
        println("( streched Position in keyPressed Right: )"  + yy);
        robot.setRobotArm(0, yy, 80, 45, 90, 90, 200, true, 255,255,0,255,2);
        println("+ IsStRun: +" + isStrRun); 
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

    println("Debug Variable : " + debugVariable);
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