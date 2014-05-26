import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import org.json.*; 
import processing.net.*; 
import processing.serial.*; 
import java.awt.Frame; 
import processing.core.PApplet.*; 
import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class RobotControlPro extends PApplet {


 




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
private String  arduinoPort               = "/dev/tty.usbmodem1d11341";
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

public void setup() {
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
  kinect = addControlFrame("extra", 320,240);

    
}

// ------------------------------------------------------------------------------------

public void draw() {


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
  drawings.drawLine(20,round(height * 0.535f), 210, round(height * 0.535f),1);
  noStroke();
  // drawings.drawRectangle(10,10,195,300,0,0,255,150);
  drawings.drawRectangle(round(width*0.008f), round(height * 0.508f) ,395,150,0,0,255,255,255,150);  
  drawings.drawRectangle(0, 0, 88, 118, width - 98, 10, 255,255,255, 150);
  drawings.drawRectangle(round(width*0.13f), round(height * 0.49f),40,20, 85,65, 255-isReadyColor ,isReadyColor - 50,0, 220);
	
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

public void clientEvent(Client  myClient) {

	if (myClient.available() > 0) {
  
    byte[] inBuffer = myClient.readBytesUntil(caReturn);
  
    if (inBuffer != null){
    	String data = new String(inBuffer);
      mindWaveCLE.mindWave(data);

	  }
	}

}

// ------------------------------------------------------------------------------------

public void serialEvent(Serial thisPort){


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


public void controlEvent(ControlEvent theEvent) {
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

public void keyPressed(){

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

public Kinect addControlFrame(String theName, int theWidth, int theHeight) {
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

public void calculateBioInput(){

//dont forget to replace heartRate with 100
  bioValue = ((100 - channelsMindwave[2].getLatestPoint().value) + (100 - 60))/2;
  // println("Bio Value:" + bioValue + " " + channels[2].getLatestPoint().value + " " + heartRate );
}

// ------------------------------------------------------------------------------------

public boolean sketchFullScreen() {
return true;
}
class Channel { 

	String name;
	int drawColor;
	String description;
	boolean graphMe;
	boolean relative;
	int maxValue;
	int minValue;
	ArrayList points;
	boolean allowGlobal;
		
// ------------------------------------------------------------------------------------

	Channel(String _name, int _drawColor, String _description) {
		name = _name;
		drawColor = _drawColor;
		description = _description;
		allowGlobal = true;
		points = new ArrayList();
	}
// ------------------------------------------------------------------------------------	
	
	public void addDataPoint(int value) {
		
		long time = System.currentTimeMillis();
		
		if(value > maxValue) maxValue = value;
		if(value < minValue) minValue = value;
		
		points.add(new Point(time, value));
		
		// tk max length handling
	}

// ------------------------------------------------------------------------------------
	
	public Point getLatestPoint() {
		if(points.size() > 0) {
			return (Point)points.get(points.size() - 1);
		}
		else {
			return new Point(0,0);
		}
	}

	public int getLatestPointValue(){
		if(points.size() > 0) {
			Point thisPoint = (Point)points.get(points.size() - 1);
			int pointValue = thisPoint.value;
			return pointValue;
		}
		else {
			return 0;

		}
	}	


}
class ConnectionLight {
	int x, y;
	int currentColor = color(255,0,0);
	int goodColor = color(0, 255, 0);
	int badColor = color(255, 255, 0);
	int noColor = color(255, 0, 0);
	int diameter;
	int latestConnectionValue;
	Textlabel mindWave;
	Textlabel pulseMeter;
	Textlabel robot;
	Textlabel travers;
	Textlabel led_A;
	Textlabel led_B;
	PShape circle;
	
// ------------------------------------------------------------------------------------
	
	ConnectionLight(int _x, int _y, int _diameter) {
		x = _x;
		y = _y;
		diameter = _diameter;
		circle = createShape(ELLIPSE, 5, 4, diameter, diameter);
		circle.setStrokeWeight(0);
		mindWave = new Textlabel(controlP5,"MindWave", x + 16, y + 4);
		mindWave.setColorValue(255);
		mindWave.setFont(createFont("Helvetica", 10));
		pulseMeter = new Textlabel(controlP5,"Pulse meter", x + 16, y + 4);
		pulseMeter.setFont(createFont("Helvetica", 10));
		pulseMeter.setColorValue(255);
		robot = new Textlabel(controlP5,"Robot", x + 16, y + 4);
		robot.setFont(createFont("Helvetica", 10));
		robot.setColorValue(255);
		travers = new Textlabel(controlP5,"Travers", x + 16, y + 4);
		travers.setFont(createFont("Helvetica", 10));
		travers.setColorValue(255);
		led_A = new Textlabel(controlP5,"led_A", x + 16, y + 4);
		led_A.setFont(createFont("Helvetica", 10));
		led_A.setColorValue(255);
		led_B = new Textlabel(controlP5,"led_B", x + 16, y + 4);
		led_B.setFont(createFont("Helvetica", 10));
		led_B.setColorValue(255);
	}
	
// ------------------------------------------------------------------------------------	
	public void update( int value) {
		latestConnectionValue = value;
		if(latestConnectionValue == 200) currentColor = noColor;
		if(latestConnectionValue < 200) currentColor = badColor;
		if(latestConnectionValue == 00) currentColor = goodColor;
	}

// ------------------------------------------------------------------------------------	
	
	public void draw() {
		
		
		pushMatrix();
		translate(x, y);
		
		// fill(255, 150);
		// rect(0, 0, 88, 28);
		
		// fill(currentColor);
		ellipseMode(CORNER);
		circle.setFill(currentColor);
		shape(circle);
		// println("currentColor: "+currentColor);
		//ellipse(5, 4, diameter, diameter);
				
		popMatrix();

	}

}
class Drawings  {
  Textarea consolTextArea;
  RadioButton toggleTestMode;

  private int sF = 1; //scaleFactor

  public void drawLine(int x1, int y1, int x2, int y2, int th){
    
    pushMatrix();
    stroke(0);
    strokeWeight(th);  // Thicker
    line(x1, y1, x2, y2);
    popMatrix();
  }

  // ------------------------------------------------------------------------------------

  public void drawRectangle(int x1, int y1, int x2, int y2, int tx, int ty, int f1, int f2, int f3, int fa){
    pushMatrix();
    translate(tx,ty);
    fill(f1, f2, f3, fa);
    rect(x1, y1, x2, y2);
    popMatrix();
  }

  // ------------------------------------------------------------------------------------

  public void Draw_Elipse(int x, int y, int dx, int dy){
    fill(recordColor);
    ellipseMode(CORNER);
    ellipse(x, y, dx, dy);

  }

  // ------------------------------------------------------------------------------------

  public void CP5Init(){
    PFont fontSmallBold = createFont("ProximaNova-Bold",15);
    PFont fontSmallLight = createFont("ProximaNova-Light",15);
    PFont fontHeadline = createFont("ProximaNova-Thin",20);
    PFont fontHeadline_2 = createFont("ProximaNova-Bold",20);
    PFont fontHeadline_3 = createFont("ProximaNova-Light",20);
    PFont fontHeadLableBig = createFont("ProximaNova-Thin",80);

  // fontHeadline

    // controlP5.addButton("Start_Recording")
    //  .setValue(0)
    //  .setPosition(20,40)
    //  .setSize(100,20)
    //  ;

    // controlP5.addButton("Stop_Recording")
    //  .setValue(0)
    //  .setPosition(20,70)
    //  .setSize(100,20)
    //  ;
  
  // controlP5.addButton("X+")
  //   .setValue(0)
  //   .setCaptionLabel("X+")
  //   .setSize(round(30),round(30))
  //   .setPosition(440,round(height * 0.55))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("X-")
  //   .setValue(0)
  //   .setCaptionLabel("X-")
  //   .setSize(round(30),round(30))
  //   .setPosition(440,round(height * 0.60))
  //   .setColorBackground(color(0, 200, 0))
  //   ;
  
  // controlP5.addButton("Y+")
  //   .setValue(0)
  //   .setCaptionLabel("Y+")
  //   .setSize(round(30),round(30))
  //   .setPosition(490,round(height * 0.55))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("Y-")
  //   .setValue(0)
  //   .setCaptionLabel("Y-")
  //   .setSize(round(30),round(30))
  //   .setPosition(490,round(height * 0.60))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("Z+")
  //   .setValue(0)
  //   .setCaptionLabel("Z+")
  //   .setSize(round(30),round(30))
  //   .setPosition(540,round(height * 0.55))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("Z-")
  //   .setValue(0)
  //   .setCaptionLabel("Z-")
  //   .setSize(round(30),round(30))
  //   .setPosition(540,round(height * 0.60))
  //   .setColorBackground(color(0, 200, 0))
  //   ;
  
  // controlP5.addButton("GA+")
  //   .setValue(0)
  //   .setCaptionLabel("GA+")
  //   .setSize(round(30),round(30))
  //   .setPosition(590,round(height * 0.55))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("GA-")
  //   .setValue(0)
  //   .setCaptionLabel("GA-")
  //   .setSize(round(30),round(30))
  //   .setPosition(590,round(height * 0.60))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("GC+")
  // .setValue(0)
  // .setCaptionLabel("GC+")
  // .setSize(round(30),round(30))
  // .setPosition(640,round(height * 0.55))
  // .setColorBackground(color(0, 200, 0))
  // ;

  // controlP5.addButton("GC-")
  //   .setValue(0)
  //   .setCaptionLabel("GC-")
  //   .setSize(round(30),round(30))
  //   .setPosition(640,round(height * 0.60))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("GR+")
  //   .setValue(0)
  //   .setCaptionLabel("GR+")
  //   .setSize(round(30),round(30))
  //   .setPosition(690,round(height * 0.55))
  //   .setColorBackground(color(0, 200, 0))
  //   ;

  // controlP5.addButton("GR-")
  //   .setValue(0)
  //   .setCaptionLabel("GR-")
  //   .setSize(round(30),round(30))
  //   .setPosition(690,round(height * 0.60))
  //   .setColorBackground(color(0, 200, 0))
  //   ;  
  // controlP5.addButton("loadBtnDefault")
  //   .setValue(0)
  //   .setCaptionLabel("load Default")
  //   .setSize(round(100),round(20))
  //   .setPosition(round(20),round(height * 0.51))
  //   .setColorActive(127)
  //   .setColorBackground(color(200, 130, 0))
  //   ;

  // controlP5.addButton("loadBtnLastPosition")
  //   .setValue(0)
  //   .setCaptionLabel("load last Position")
  //   .setSize(round(100),round(20))
  //   .setPosition(round(140),round(height * 0.51))
  //   .setColorCaptionLabel(0) 
  //   .setColorValueLabel(127)
  //   .setColorBackground(color(200, 130, 0))
  //   ;
  
  // controlP5.addButton("Start_Robot")
  //  .setValue(0)
  //  .setCaptionLabel("START ROBOT")
  //  .setPosition(round(500),round(height * 0.42))
  //  .setSize(round(100),round(20))
  //  ;
  
  // controlP5.addButton("Reset_Robot")
  //  .setValue(0)
  //  .setCaptionLabel("RESET ROBOT")
  //  .setPosition(round(width*0.3),round(height * 0.44))
  //  .setSize(round(100),round(20))
  //  ;
     
  controlP5.addButton("Back")
   .setValue(0)
   .setCaptionLabel("Back")
   .setPosition(round(width*0.1f),round(height * 0.6f))
   .setSize(round(65*sF),round(20*sF))
   ;

   controlP5.addButton("Forward")
   .setValue(0)
   .setCaptionLabel("Forward")
   .setPosition(round(width*0.145f),round(height * 0.6f))
   .setSize(round(65*sF),round(20*sF))
   ;

  // toggleTestMode = controlP5.addRadioButton("testMode")
  //        .setPosition(round(20),round(height * 0.458))
  //        .setSize(round(20),round(10))
  //        .setColorForeground(color(120))
  //        .setColorActive(color(0,190,0))
  //        .setColorLabel(color(255,0,0))
  //        .addItem("Toggle Test Mode",1)
  //        ;      

// ------------------------------------------------------------------------------------

// -------------    Mindwave Lables   ---------------------

  textMindwave = controlP5.addTextlabel("label2")
              .setText("MINDWAVE")
              .setPosition(round(width*0.01f),round(height*0.08f))
              .setColor(0)
              .setFont(fontSmallBold)
              .setLetterSpacing(110);
              ;
  attentionLevel = controlP5.addTextlabel("attentionLevel")
              .setText("Attention Level:")
              .setPosition(round(width*0.07f),round(height*0.08f))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  attentionValue = controlP5.addTextlabel("attentionValue")
              .setText("Na")
              .setPosition(round(width*0.125f),round(height*0.076f))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;
  meditationLevel = controlP5.addTextlabel("meditationLevel")
              .setText("Meditation Level:")
              .setPosition(round(width*0.15f),round(height*0.08f))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  meditationValue = controlP5.addTextlabel("meditationValue")
              .setText("Na")
              .setPosition(round(width*0.21f),round(height*0.076f))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;
  blinkStrength = controlP5.addTextlabel("blinkStrength")
              .setText("Blink Strength:")
              .setPosition(round(width*0.235f),round(height*0.08f))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  blinkValue = controlP5.addTextlabel("blinkValue")
              .setText("Na")
              .setPosition(round(width*0.287f),round(height*0.076f))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;

// -------------    Pulsemeter Lables   ---------------------

  textPulseMeter = controlP5.addTextlabel("pulseMeter")
              .setText("PULSEMETER")
              .setPosition(round(width*0.01f),round(height*0.18f))
              .setColor(0)
              .setFont(fontSmallBold)
              .setLetterSpacing(110);
              ;
  pulseLevel = controlP5.addTextlabel("pulseLevel")
              .setText("Pulse:")
              .setPosition(round(width*0.07f),round(height*0.18f))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  pulseValue = controlP5.addTextlabel("pulseValue")
              .setText("Na")
              .setPosition(round(width*0.095f),round(height*0.176f))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;                          

// -------------    HeadLines   ---------------------

  headlineText_1 = controlP5.addTextlabel("label4")
                  .setText("ROBOT CONTROLS: ")
                  .setPosition(round(width*0.01f),round(height * 0.51f))
                  .setColorValue(255)
                  .setFont(fontHeadline)
                  ;
 
  // headlineText_2 = controlP5.addTextlabel("label5")
  //               .setText("ROBOT CONTROLS: ")
  //               .setPosition(round(490),round(height * 0.42))
  //               .setColorValue(255)
  //               .setFont(fontHeadline_2)
  //               ;



  controlP5.addTextfield("Set Global ID - [ ENTER ]")
                .setPosition(round(width*0.1f),round(height * 0.55f))
                .setSize(150,20)
                .setFont(fontSmallBold)
                .setFocus(true)
                .setColorActive(0)
                .setColorValue(255)
                .setColorBackground(color(255, 255))
                ;

  // consolTextArea = controlP5.addTextarea("txt")
  //                 .setPosition(10, round(height * 0.80))
  //                 .setSize(200, 200)
  //                 .setFont(createFont("", 10))
  //                 .setLineHeight(14)
  //                 .setColor(color(200))
  //                 .setColorBackground(color(0, 100))
  //                 .setColorForeground(color(255, 100))

  controlP5.addFrameRate().setInterval(10).setColor(0).setPosition(round(10),height - round(30)).setFont(fontSmallLight);
  // console = controlP5.addConsole(consolTextArea);              


   lableID = controlP5.addTextlabel("lableID")
                .setText("global ID")
                .setPosition(round(width*0.01f),round(height * 0.53f))
                .setColorValue(255)
                .setFont(fontHeadLableBig)
                ;
    textID = controlP5.addTextlabel("label7")
                .setText("ID")
                .setPosition(round(width*0.015f),round(height*0.61f))
                .setColorValue(255)
                .setFont(fontHeadline)
                ;                     


  }

}



class Graph {
	int x, y, w, h, pixelsPerSecond, gridColor, gridX, originalW, originalX, timeScale;
	long leftTime, rightTime, gridTime;
	boolean scrollGrid;
	String renderMode;
	float gridSeconds;
	Slider pixelSecondsSlider;
	RadioButton renderModeRadio;
	RadioButton scaleRadio;
	Channel[] thisChannels;
	public boolean isDataToGraph;

// ------------------------------------------------------------------------------------

	Graph(int _x, int _y, int _w, int _h, Channel[] _thisChannels, int _timeScale, String _renderMode) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		timeScale = _timeScale;
		thisChannels =  _thisChannels;
		pixelsPerSecond = 20;
		gridColor = color(0);
		gridSeconds = 1; // seconds per grid line
		scrollGrid = false;
		isDataToGraph = false;
		renderMode = _renderMode;



		// temporary overdraw kludge to keep graph smooth
		originalW = w;
		originalX = x;
		
		w += (pixelsPerSecond * 2);
		x -= pixelsPerSecond;
		

		// pixelSecondsSlider = controlP5.addSlider("PIXELS PER SECOND",10,width,50,16,16,100,10);
		// pixelSecondsSlider.setColorForeground(color(180));
		// pixelSecondsSlider.setColorActive(color(180));

 	// 	renderModeRadio = controlP5.addRadioButton("RENDER MODE",16,36);
		// renderModeRadio.setSpacingColumn(40);
		
		// s
		// renderModeRadio.addItem("Curves",2);
		// renderModeRadio.addItem("Shaded",3);
		// renderModeRadio.addItem("Triangles",4);			
		// renderModeRadio.activate(0);
		// // triangles, too?
		
		// scaleRadio = controlP5.addRadioButton("SCALE MODE",104,36);
		// scaleRadio.setColorForeground(color(255));
		// scaleRadio.setColorActive(color(0));
		// scaleRadio.addItem("Local Maximum",1);
		// scaleRadio.addItem("Global Maximum",2);		
		// scaleRadio.activate(0);

	}

// ------------------------------------------------------------------------------------
	
	public void update() {
	}

// ------------------------------------------------------------------------------------
	
	public void draw() {
		
		

		
		//pixelsPerSecond = round(pixelSecondsSlider.value());
		

		w = originalW;
		x = originalX;

		w += (pixelsPerSecond * 2);
		x -= pixelsPerSecond;

		
		// Figure out the left and right time bounds of the graph, based on
		// the pixels per second value
		rightTime = System.currentTimeMillis();
		leftTime = rightTime - ((w / pixelsPerSecond) * timeScale);
		
		if(isDataToGraph){

			pushMatrix();
			translate(x, y);
			
		
			
			// Draw each channel (pass in as constructor arg?)

			noFill();				
			if(renderMode == "Shaded" || renderMode == "Triangles") noStroke();		
			if(renderMode == "Lines" || renderMode == "Curves") strokeWeight(1.5f);
			// println("Before loop")
			for (int i = 0; i < thisChannels.length; i++) {
				if(thisChannels[i] != null){
					if(!thisChannels[i].name.equals("Signal Quality")){
						Channel thisChannel = thisChannels[i];
						// println("In for loop");
						// println("Drawing value:" + thisChannel.getLatestPoint().value + " " + i ) ;
						
						if(thisChannel.graphMe) {
						
							//Draw the line
							if(renderMode == "Lines" || renderMode == "Curves") stroke(thisChannel.drawColor);

							if(renderMode == "Shaded" || renderMode == "Triangles") {
								noStroke();
								fill(thisChannel.drawColor, 127);
							}
						
							if(renderMode == "Triangles") {
								beginShape(QUAD_STRIP);
							}
							else {
								beginShape();			
							}

							if(renderMode == "Curves" || renderMode == "Shaded") vertex(0, h);
						
							if(thisChannel != null){
								for (int j = 0; j < thisChannel.points.size(); j++) {
									Point thisPoint = (Point)thisChannel.points.get(j);
									if(thisPoint != null){	
									// check bounds
										if((thisPoint.time >= leftTime) && (thisPoint.time <= rightTime)) {
									
											int pointX = (int)helpers.mapLong(thisPoint.time, leftTime, rightTime, 0L, (long)w);
										
											int pointY = 0;
											if((scaleMode == "Global") && (i > 2)) {					
												pointY = (int)map(thisPoint.value, 0, globalMax, h, 0);
											}
											else {
												// Local scale
												pointY = (int)map(thisPoint.value, thisChannel.minValue, thisChannel.maxValue, h, 0);
											}
									
											// ellipseMode(CENTER);
											// ellipse(pointX, pointY, 5, 5);
									
											if(renderMode == "Curves") {
												curveVertex(pointX, pointY);					
											}
											else {
												vertex(pointX, pointY);
											}				
										}
									}
								}	
							}
						}

						
						if(renderMode == "Curves" || renderMode == "Shaded") vertex(w, h);
						if(renderMode == "Lines" || renderMode == "Curves" || renderMode == "Triangles") endShape();
						if(renderMode == "Shaded") endShape(CLOSE);
					}
				}
			}	


			
			popMatrix();
			
			
			// gui matte
			noStroke();
			// fill(255, 150);
			// rect(10, 10, 195, 300);

		}


	}

// ------------------------------------------------------------------------------------

	public void drawGrid(){

		pushMatrix();

		// Draw the background graph
		strokeWeight(0.6f);
		stroke(127,80);

		if (scrollGrid) {
			// Start from the first whole second and work right			
			gridTime = (rightTime / (long)(1000 * gridSeconds)) * (long)(1000 * gridSeconds);
		}
		else {
			gridTime = rightTime;
		}

		if(!gridXisDrawn){
			// println("Drawing GridX");
			while (gridTime >= leftTime) {
				int gridX = (int)helpers.mapLong(gridTime, leftTime, rightTime, 0L, (long)w);
				line(gridX, 0, gridX, height);
				gridTime -= (long)(1000 * gridSeconds);
			}
		gridXisDrawn = true;
		}

		strokeWeight(0.6f);
		stroke(127,80);
		//Draw square horizontal grid for now
		if(!gridYisDrawn){
			// println("Drawing GridY");
			int gridY = height;
			while (gridY >= 0) {
				gridY -= pixelsPerSecond * gridSeconds; 
				line(0, gridY, w, gridY);
			}
		gridYisDrawn = true;	
		}
		popMatrix();
	}


	
}
class HelperClass {

  public void beginRecording() {
    isRecording = true;
    recordColor = color(255, 0, 0);
   println("a button event from Start_Recording: ");
    table = new Table();
    table.addColumn("ID");
    table.addColumn("Heart_Rate");
    table.addColumn("attention");
    table.addColumn("meditation");
    table.addColumn("delta");
    table.addColumn("theta");
    table.addColumn("lowAlpha");
    table.addColumn("highAlpha");
    table.addColumn("lowBeta");
    table.addColumn("highBeta");
    table.addColumn("lowGamma");
    table.addColumn("highGamma");
    table.addColumn("timestamp");
}

// ------------------------------------------------------------------------------------

  public void endRecording() {
    if(isReadyToRecord){
      println("a button event from Stop_Recording: ");
      saveTable(table, String.format("data/recording_%d.csv", tableIndex), "csv");
      println("isRecording Stoped!!");
      tableIndex ++;
      isRecording = false;
      recordColor = color(127, 127, 127);
    }
  }

// ------------------------------------------------------------------------------------    

  //List of robot data: x1-10,y1-10,  xx,yy to xx2,yy2, Turn towards or away TT or TA, Open or Close claw OC or CC, Stretch or Contract S or C, Arousal in %, Classification of move <A>, Other: emotions etc
  public void newStorePositionTable() {
    isStoring = true;
    tableRm = new Table();
    tableRm.addColumn("ID");
    tableRm.addColumn("X");
    tableRm.addColumn("Y");
    tableRm.addColumn("Z");
    tableRm.addColumn("GripperAngle");
    tableRm.addColumn("GripperWidth");
    tableRm.addColumn("EyeColor");
    tableRm.addColumn("Easing");
    tableRm.addColumn("X1");
    tableRm.addColumn("Y1");
    tableRm.addColumn("Turning");
    tableRm.addColumn("Claw");
    tableRm.addColumn("Streching");
    tableRm.addColumn("Arousal");
  }

  // ------------------------------------------------------------------------------------  

  public void storePositionToTable(int x, int y, int z, int gripperAngle, int gripperWidth, int eyeColor, int easing, int x1, int y1, int turning, int claw, int streching, int arousal){

    TableRow newRow = tableRm.addRow();
    newRow.setInt("ID", tableRm.getRowCount() -1);
    newRow.setInt("X", x);
    newRow.setInt("Y", y);
    newRow.setInt("Z", z);
    newRow.setInt("GripperAngle", gripperAngle);
    newRow.setInt("GripperWidth", gripperWidth);
    newRow.setInt("EyeColor", eyeColor);
    newRow.setInt("Easing", easing);
    newRow.setInt("X1", x1);
    newRow.setInt("Y1", y1);
    newRow.setInt("Turning", turning);
    newRow.setInt("Claw", claw);
    newRow.setInt("Streching", streching);
    newRow.setInt("Arousal", arousal);
    storingID =  tableRm.getRowCount() -1;
    println("Movement Stored");
  }

// ------------------------------------------------------------------------------------  

  public void endStoring() {
      if(isReadyToStore){
        saveTable(table, String.format("data/RobotMovements.csv"), "csv");
        println("Storing finished");
        tableIndexStoring ++;
        isStoring = false;
      }
  }

// ------------------------------------------------------------------------------------  
// Extend core's Map function to the Long datatype.

  public long mapLong(long x, long in_min, long in_max, long out_min, long out_max)  { 
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min; 
  }

  // ------------------------------------------------------------------------------------

  public long constrainLong(long value, long min_value, long max_value) {
    if(value > max_value) return max_value;
    if(value < min_value) return min_value;
    return value;
  }

  // ------------------------------------------------------------------------------------

  public void checkSerialPorts(){
   for (int i = 0; i < Serial.list().length; i++) {
       println("[" + i + "] " + Serial.list()[i]);
       // Flag serial ports as true
       if(Serial.list()[i].equals(pulseMeterPort)){
        isPulseMeterPort = true;
       }else if (Serial.list()[i].equals(arduinoPort)){
        isArduinoPort = true;
       }else if (Serial.list()[i].equals(melziPort)){
        isMelziPort = true;
       }else if (Serial.list()[i].equals(ledPortA)){
        isLedPortA = true;
       }else if (Serial.list()[i].equals(ledPortB)){
        isLedPortB = true;
       }
    }
  }

  // ------------------------------------------------------------------------------------

  public void checkStep()
  {
    // wait for text to be done
    
    if(!textToSpeech.speaking && !textToSpeech.sayNextSentence)
    {
      if (robotAnimation.isInAnimation)
      {
        robotAnimation.isInAnimation = false;
        if(traversAnimation.isInAnimationT){
          traversAnimation.isInAnimationT = false;
        }
      }
      else if (!robotAnimation.isInAnimation && !traversAnimation.isInAnimationT && robotAnimation.isOutOfLoop && traversAnimation.isOutOfLoop && !traversAnimation.isAnimationT && !robotAnimation.isAnimation)
      {
        readyToExecuteNextStep = true;
        textToSpeech.readText = true;
        checkIfReadyForNextStep = false;
        if(stepForward)
        {
          stepForward = false;
        }
        else if (stepBack)
        {
          stepBack = false;
        } 
      }
    }
  }  

}



// ------------------------------------------------------------------------------------

public class Kinect extends PApplet{

SimpleOpenNI  context;
int w, h;
int abc = 100;
float zValueKinectR = 0;
float xValueKinectR = 0;
float zValueKinectT = 0;
float xValueKinectT = 0;
float oldXValueKinectT = 0;
float oldZValueKinectT = 0;
boolean kinectValueAvailable = false;
boolean zPositionUpdatedT = false;
boolean xPositionUpdatedT = false;

// ------------------------------------------------------------------------------------

  public void setup()
  {


    context = new SimpleOpenNI(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
     if(context.isInit() == false)
    {
       println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
       return;  
    }


    // enable depthMap generation 
    context.enableDepth();
   
    // enable skeleton generation for all joints
    context.enableUser();
   
    background(200,0,0);
    stroke(0,0,0);
    strokeWeight(3);
    smooth();

    // controlP5 = new ControlP5(this);
    // controlP5.addSlider("abc").setRange(0, 255).setPosition(10,10);
    // controlP5.addSlider("def").plugTo(parent,"def").setRange(0, 255).setPosition(10,30);
   
    // create a window the size of the depth information

    size(context.depthWidth()/2, context.depthHeight()/2);
  
  }

// ------------------------------------------------------------------------------------
   
  public void draw()
  {

    frameRate(30);
    // update the camera

    context.update();
   
    // draw depth image
    // image(context.depthImage(),0,0,320,240);
    image(context.userImage(),0,0,320,240);
   
    // for all users from 1 to 10
    for (int i = 1; i <= 5; i++)
    {
      // check if the skeleton is being tracked
      if(context.isTrackingSkeleton(i))
      {
        // draw a circle for a head 
        circleForAHead(i);
      }
    }

  }
// ------------------------------------------------------------------------------------ 
// draws a circle at the position of the head

  public void circleForAHead(int userId)
  {
    // get 3D position of a joint
    PVector jointPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,jointPos);


    // println("X: " + jointPos.x + " Y:" + jointPos.y + " Z: " + jointPos.z);

   
    // convert real world point to projective space
    PVector jointPos_Proj = new PVector(); 
    context.convertRealWorldToProjective(jointPos,jointPos_Proj);
   
    // a 200 pixel diameter head
    float headsize = 50;
   
    // create a distance scalar related to the depth (z dimension)
    float distanceScalar = (525/jointPos_Proj.z);
   
    // set the fill colour to make the circle green
    fill(0,255,0); 
   
    // draw the circle at the position of the head with the head size scaled by the distance scalar
    ellipse(jointPos_Proj.x/2,jointPos_Proj.y/2, distanceScalar*headsize,distanceScalar*headsize);

    // println("X: " + jointPos_Proj.x + " Y: " + jointPos_Proj.y + " Z: " + jointPos_Proj.z);

    if(jointPos_Proj.z > 848 && jointPos_Proj.z < 3300 && context != null){
      kinectValueAvailable = true;
      zValueKinectR = map(jointPos_Proj.z,848, 3300, -2, 166);
      oldZValueKinectT = zValueKinectT;
      if(abs(oldZValueKinectT - map(jointPos_Proj.z,848, 3300,0, 2000)) > 50){
        zValueKinectT = map(jointPos_Proj.z,848, 3300,0, 2000);
        zPositionUpdatedT = true;
        // println("zValueKinectT: "+zValueKinectT);
      }
    } 
    if(jointPos_Proj.x > 100 && jointPos_Proj.x < 500 && context != null){
      kinectValueAvailable = true;
      xValueKinectR = map(jointPos_Proj.x,100, 500,-236,32);
      oldXValueKinectT = xValueKinectT;
      if(abs(oldXValueKinectT - map(jointPos_Proj.x,100, 500,2000, 0)) > 5){
        xValueKinectT = map(jointPos_Proj.x,100, 500,2000, 0);
        xPositionUpdatedT = true;
        // println("xValueKinectT: "+xValueKinectT);
      }
    }
    else
      kinectValueAvailable = false;
  }

// ------------------------------------------------------------------------------------
// when a person ('user') enters the field of view

  public void onNewUser(SimpleOpenNI curContext,int userId)
  {
    // println("New User Detected - userId: " + userId);
   
   // start pose detection
    curContext.startTrackingSkeleton(userId);
  }

// ------------------------------------------------------------------------------------    
// when a person ('user') leaves the field of view 

  public void onLostUser(int userId)
  {
    // println("User Lost - userId: " + userId);
  }

// ------------------------------------------------------------------------------------

  public Kinect(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

// ------------------------------------------------------------------------------------

  public ControlP5 control() {
    return controlP5;
  }



  // ControlP5 controlP5;

  Object parent;
  
}

 

class ManageCLE {

  // ------------------------------------------------------------------------------------

  public void connectToMindWave(PApplet p){
      // Connect to ThinkGear socket (default = 127.0.0.1:13854)
      // By default, Thinkgear only binds to localhost:
      // To allow other hosts to connect and run Processing from another machine, run ReplayTCP (http://www.dlcsistemas.com/html/relay_tcp.html)
      // OR, use netcat (windows or mac) to port forard (clients can now connect to port 13855).  Ex:  nc -l -p 13855 -c ' nc localhost 13854'
      
      String thinkgearHost = "127.0.0.1";
      int thinkgearPort = 13854;
      
      String envHost = System.getenv("THINKGEAR_HOST");
      if (envHost != null) {
        thinkgearHost = envHost;
      }
      String envPort = System.getenv("THINKGEAR_PORT");
      if (envPort != null) {
         thinkgearPort = Integer.parseInt(envPort);
      }
     
      println("Connecting to host = " + thinkgearHost + ", port = " + thinkgearPort);
      myClient = new Client(p, thinkgearHost, thinkgearPort);
      String command = "{\"enableRawOutput\": false, \"format\": \"Json\"}\n";
      print("Sending command");
      println (command);
      myClient.write(command);


  }

  // ------------------------------------------------------------------------------------
	
	public void mindWave(String data) {
		

	// Sample JSON data:
  	// {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}

		try {
        org.json.JSONObject json = new org.json.JSONObject(data);
        channelsMindwave[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));
      	}
      	catch (JSONException e) {
      	// println(e); 	
      	}   
      

      	try{
      		org.json.JSONObject json = new org.json.JSONObject(data);   
        	org.json.JSONObject esense = json.getJSONObject("eSense");
        	if (esense != null) {
          	channelsMindwave[1].addDataPoint(Integer.parseInt(esense.getString("attention")));
          	channelsMindwave[2].addDataPoint(Integer.parseInt(esense.getString("meditation")));
          	// print(channelsMindwave[1].getLatestPoint().value);
          	isEsenseEvent = true;
            if(!isMindWaveData)
              isMindWaveData = true;


            mindWave.isDataToGraph = true; 
        }
        
      //   org.json.JSONObject eegPower = json.getJSONObject("eegPower");
        
      //   if (eegPower != null) {
      //     channelsMindwave[3].addDataPoint(Integer.parseInt(eegPower.getString("delta")));
      //     channelsMindwave[4].addDataPoint(Integer.parseInt(eegPower.getString("theta"))); 
      //     channelsMindwave[5].addDataPoint(Integer.parseInt(eegPower.getString("lowAlpha")));
      //     channelsMindwave[6].addDataPoint(Integer.parseInt(eegPower.getString("highAlpha")));  
      //     channelsMindwave[7].addDataPoint(Integer.parseInt(eegPower.getString("lowBeta")));
      //     channelsMindwave[8].addDataPoint(Integer.parseInt(eegPower.getString("highBeta")));
      //     channelsMindwave[9].addDataPoint(Integer.parseInt(eegPower.getString("lowGamma")));
      //     channelsMindwave[10].addDataPoint(Integer.parseInt(eegPower.getString("highGamma")));

      //   if (isRecording){
    		// 	TableRow newRow = table.addRow();
    		// 	newRow.setInt("ID", table.getRowCount() -1);
      //      	newRow.setInt("Heart_Rate", receivedHeartRate);
    		// 	newRow.setInt("attention", channelsMindwave[1].getLatestPoint().value);
    		// 	newRow.setInt("meditation", channelsMindwave[2].getLatestPoint().value);
    		// 	newRow.setInt("delta", channelsMindwave[3].getLatestPoint().value);
    		// 	newRow.setInt("theta", channelsMindwave[4].getLatestPoint().value);
    		// 	newRow.setInt("lowAlpha", channelsMindwave[5].getLatestPoint().value);
    		// 	newRow.setInt("highAlpha", channelsMindwave[6].getLatestPoint().value);
    		// 	newRow.setInt("lowBeta", channelsMindwave[7].getLatestPoint().value);
    		// 	newRow.setInt("highBeta", channelsMindwave[8].getLatestPoint().value);
    		// 	newRow.setInt("lowGamma", channelsMindwave[9].getLatestPoint().value);
    		// 	newRow.setInt("highGamma", channelsMindwave[10].getLatestPoint().value);
    		// 	newRow.setInt("timestamp", millis());
      //       	id =  table.getRowCount() -1;
      //       	// println("Packeg");
  		  // }

      //    mindWave.isDataToGraph = true; 
      //  	}
        
       	 packetCount++;
         for (int i = 0; i < channelsMindwave.length; ++i) {
          channelsMindwave[i].graphMe = true; 
         }
       
  	  }
  	  
  	  catch (JSONException e) {
  	    // println ("There was an error parsing the JSONObject." + e);
  	  };
	}

}
class ManageSE {

private boolean isHashtrue = false;
private boolean isIncreasingP = false;
private boolean isFallingP = false;
private long beatTime = 0;
private int heartRate = 0;
private int plethRate = 0;
private int oldPlethRate = 0;
private String  pulseString  = "";
private String  plethString  = "";
private int lastPulseBit  = 0;
private int pulseBeep = 0;
private int oldPulseBeep = 0;
private int counter = 0;
private int[] bitArray = new int[8];

  public void arduino(String inChar) {

   // println("In after Null");
    // println(inChar);
    if (isHashtrue){
      println("Hash received");
      String[] s = split(inChar, ',');
      isHashtrue = false;
      if(s[0].trim().equals("1")){
        println("Value of Base: " +  s[1]);
        println("Value of Shoulder: " +  s[2]);
        println("Value of Elbow: " +  s[3]);
        println("Value of Wrist: " +  s[4]);
      }
    }

    if (inChar.trim().equals("W")){
      wA.heartBeat = millis();
      wA.port.write("W");
      wA.port.write(10);
      println("+ Robot +");
      if(wA.conValue != 00){
        wA.conValue = 00;
      }
      // serialConnection = "Connected";
    }

    if(inChar.trim().equals("N")){
      isRobotReadyToMove = true;
     // println("Robot Ready for Next Position");
    }

    if(!wA.isFirstContact){
      println("In first contact");
      if (inChar.trim().equals("A")) {
        println("Connected");
        wA.heartBeat = millis();                   
        wA.port.write("B");
        wA.port.write(10);
        wA.isFirstContact = true;
        isRobotReadyToMove = true;     
      }  
    } 
    else if(inChar.trim().equals("#")){
        isHashtrue = true;
    }
  
  }

  // ------------------------------------------------------------------------------------

  public void newPulse(){

     
     while (wPm.port.available() > 0) {
      // Expand array size to the number of bytes you expect:
      int inByte = wPm.port.read();
      // println(inByte);
      for (int i = 7; i >= 0; i--){ 
        bitArray[i] = bitRead(inByte, i);
      }
    }

        // Check for pleth byte
      if (counter == 0){
        pulseBeep = bitArray[6];

        if(oldPulseBeep == 0 && pulseBeep == 1)
          isIncreasingP = true;

        if(oldPulseBeep == 1 && pulseBeep == 0)
          isFallingP = true;

        if(isFallingP && isIncreasingP && oldPulseBeep == 1){
          isFallingP = false;
          isIncreasingP = false;
          // println("plethRate: "+plethRate);
          if(plethRate >= 55 && globalID < 67){
            if(millis() - beatTime >= 500){
              // println("Beat");
              robot.sendBeat(wLA.port,0,250,100,0);
              robot.sendBeat(wLB.port,0,250,100,0);
              beatTime = millis();
            }
          }
        }

        oldPulseBeep = pulseBeep;
  
      }  

      counter++;  

      // Check for pleth byte
      if (counter == 1){
        for(int i = 6; i >= 0; i--){
          plethString += bitArray[i]; 
        }
        plethRate = unbinary(plethString);
        plethRate = (int)(plethRate*0.2f + (oldPlethRate*0.8f));
        // println("plethRate: "+plethRate);;
        plethString = "";
        channelPleth[0].addDataPoint(plethRate);
        // println(channelPleth[0].getLatestPoint().value);
        channelPleth[0].graphMe = true;

        oldPlethRate = plethRate;
        pleth.isDataToGraph = true;
      }  
      // Check for 3 byte and add 7th bit to byte 4
      if (counter == 2){
        if (bitArray[6] == 1){
          lastPulseBit = 1;
        }else{
          lastPulseBit = 0;
        }
      }
      // Check for 4 byte
      if (counter == 3){
        bitArray[7] = lastPulseBit;
        for(int i = 7; i >= 0; i--){
          pulseString += bitArray[i]; 
        }
        // println("\nPulse String" + pulseString + "\n");
        // println("Pulse: ");
        heartRate = unbinary(pulseString);
        robotAnimation.heartRateForCalculation = heartRate;
        heartRateString = String.valueOf(heartRate);
        pulseString = "";
        bitArray[7] = 0;
        if (wPm.conValue <= 200){
          wPm.conValue = 00;
        }
        if(PApplet.parseInt(heartRateString) == 255){
          wPm.conValue = 100;
        }
      }

      // Check for synch bit
     if (bitArray[7] == 1){
      counter = 0;
      }

      wPm.heartBeat = millis();

  }


   public void melzi(String inChar) {

   // println("In after Null");
    // println(inChar);

    if (inChar.trim().equals("W")){
      wM.heartBeat = millis();
      wM.port.write("W");
      wM.port.write(10);
      println("+ Melzi +");
      if(wM.conValue != 00){
        wM.conValue = 00;
      }
      // serialConnection = "Connected";
    }

    if(inChar.trim().equals("N")){
      isTraversReadyToMove = true;
     // println("Robot Ready for Next Position");
    }

    if(!wM.isFirstContact){
      // println("In first contact");
      if (inChar.trim().equals("A")) {
        println("Connected");
        wM.heartBeat = millis();                   
        wM.port.write("B");
        wM.port.write(10);
        wM.isFirstContact = true;
        isTraversReadyToMove = true;       
      }  
    }
  
  }

   public void lA(String inChar) {

   // println("In after Null");
    // println(inChar);

    if (inChar.trim().equals("W")){
      wLA.heartBeat = millis();
      wLA.port.write("W");
      wLA.port.write(10);
      println("+ LA +");
      if(wLA.conValue != 00){
        wLA.conValue = 00;
      }
      // serialConnection = "Connected";
    }

    if(inChar.trim().equals("N")){
      laLedIsready = true;
     // println("Robot Ready for Next Position");
    }

    if(!wLA.isFirstContact){
      // println("In first contact");
      if (inChar.trim().equals("A")) {
        println("Connected LA");
        wLA.heartBeat = millis();                   
        wLA.port.write("B");
        wLA.port.write(10);
        wLA.isFirstContact = true;
        laLedIsready = true; 
        robot.setColor(wLA.port,0,0,0,0);
        robot.setTargetColor(wLA.port,0,127,127,127);        
      }  
    }
  
  }

   public void lB(String inChar) {

    // println(inChar);

    if (inChar.trim().equals("W")){
      wLB.heartBeat = millis();
      wLB.port.write("W");
      wLB.port.write(10);
      println("+ LB +");
      if(wLB.conValue != 00){
        wLB.conValue = 00;
      }
      // serialConnection = "Connected";
    }

    if(inChar.trim().equals("N")){
      // isTraversReadyToMove = true;
     // println("Robot Ready for Next Position");
    }

    if(!wLB.isFirstContact){
      // println("In first contact");
      if (inChar.trim().equals("A")) {
        println("Connected LB");
        wLB.heartBeat = millis();                   
        wLB.port.write("B");
        wLB.port.write(10);
        wLB.isFirstContact = true;
        robot.setColor(wLB.port,0,0,0,0);
        robot.setTargetColor(wLB.port,0,127,127,127);  
        // isTraversReadyToMove = true;       
      }  
    }
  
  }

  // ------------------------------------------------------------------------------------

  public int bitRead(int b, int bitPos)
  {
    int x = b & (1 << bitPos);
    return x == 0 ? 0 : 1;
  }
}
class Monitor {
	int x, y, w, h, currentValue, targetValue, backgroundColor;
	Channel sourceChannel;
	CheckBox showGraph;	
	Textlabel label;

// ------------------------------------------------------------------------------------	
	
	Monitor(Channel _sourceChannel, int _x, int _y, int _w, int _h) {
		sourceChannel = _sourceChannel;
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		currentValue = 0;
		backgroundColor = color(255);
		// showGraph = controlP5.addCheckBox("showGraph",x + 16, y + 34);  		
		// showGraph.addItem("GRAPH",0);
		// showGraph.activate(0);
		// showGraph.setColorForeground(sourceChannel.drawColor);
		// showGraph.setColorActive(color(0));
		
 		label = new Textlabel(controlP5,sourceChannel.name, x + 16, y + 16);
		label.setFont(createFont("Helvetica", 16));
		label.setColorValue(0);

	}

// ------------------------------------------------------------------------------------
	
	public void update() {

	}

// ------------------------------------------------------------------------------------
	
	public void draw() {
		// this technically only neds to happen on the packet, not every frame
		// if(showGraph.getItem(0).value() == 0) {
		// 	sourceChannel.graphMe = false;
		// }
		// else {
			sourceChannel.graphMe = true;
		// }
		

		pushMatrix();
		translate(x, y);		
		// Background
		noStroke();
		fill(backgroundColor, 150);
		rect(0, 0, w, h);

		// border line
		strokeWeight(1);
		stroke(220);
		line(w - 1, 0, w - 1, h);

		
		if(sourceChannel.points.size() > 0) {
		
			Point targetPoint = (Point)sourceChannel.points.get(sourceChannel.points.size() - 1);
			targetValue = round(map(targetPoint.value, sourceChannel.minValue, sourceChannel.maxValue, 0, h));

			if((scaleMode == "Global") && sourceChannel.allowGlobal) {					
				targetValue = (int)map(targetPoint.value, 0, globalMax, 0, h);	
			}	
							
			// Calculate the new position on the way to the target with easing
    	currentValue = currentValue + round(((float)(targetValue - currentValue) * .08f));
			
			// Bar
			noStroke();
			fill(sourceChannel.drawColor);
			rect(0, h - currentValue, w, h);
		}

		// Draw the checkbox matte
		
		noStroke();
		fill(255, 150);		
		rect(10, 10, w - 20, 40);

			popMatrix();


 		label.draw();		
	}
	
	

}

class Point {
	long time;
	int value;

// ------------------------------------------------------------------------------------
	
	Point(long _time, int _value) {
		time = _time;
		value = _value;
	}
	
}
/* Static Robot Values used for Inverse Kinematic */
/* Arm dimensions( mm ) */

private static final Float  BASE_HEIGHT  = 101.0f;   //height of robot-base"
private static final Float  SHL_ELB      = 105.0f;   //shoulder-to-elbow
private static final Float  ULNA         = 98.0f;    //elbow-to-wrist
private static final Float  GRIPLENGTH   = 155.0f;   //lengh-of-grip
private static final Float  WRIST_OFFSET = 28.0f;    //offset wrist-gripper

/* Constrains of servo motors in milliseconds */
private static final Integer  BASE_MAX            = 2300;
private static final Integer  BASE_MIN            = 720;
private static final Integer  SHOULDER_MAX        = 2350; 
private static final Integer  SHOULDER_MIN        = 720; 
private static final Integer  ELBOW_MAX           = 2370; 
private static final Integer  ELBOW_MIN           = 720;
private static final Integer  WRIST_MAX           = 2370; 
private static final Integer  WRIST_MIN           = 720;
private static final Integer  GRIPPER_ROTATION_MAX  = 2400;
private static final Integer  GRIPPER_ROTATION_MIN  = 650;
private static final Integer  GRIPPER_MAX         = 2100;
private static final Integer  GRIPPER_MIN         = 1450;  

/* Dynamic values of the robot arm */
private int     currentBase             = 00;
private int     currentShoulder         = 00;
private int     currentElbow            = 00;
private int     currentWrist            = 00;
private int     currentGripperAngle     = 00;
private int     currentGripperRotation  = 00;
private int     currentGripperWidth     = 00;
private int     currentLight            = 00;
private int     currentEasing           = 00;
private int     currentBrightness       = 00;
private int      verifCounter          = 0;

public float     lastX             = 0;
public float     lastY             = 0;
public float     lastZ             = 0;
public float     lastGripperAngle  = 0;
public int       lastGripperWidth  = 0;
public int       lastGripperRotation  = 0;
public int       lastR             = 0;
public int       lastG             = 0;
public int       lastB             = 0;
public int       lastBrightness    = 0;
public int       lastLed           = 2;

public int     lastXt             = 0;
public int     lastYt             = 0;
public int     lastZt             = 0;

private boolean     sendData        = false;
private boolean     isDataVerified  = false;
private boolean     isStrRun        = false;
private boolean     validStrPos     = false;

// private boolean[]   strArray        = new boolean[350];


// ------------------------------------------------------------------------------------

class Robot{

  //List of robot data: x1-10,y1-10,  xx,yy to xx2,yy2, Turn towards or away TT or TA, Open or Close claw OC or CC, Stretch or Contract S or C, Arousal in %, Classification of move <A>, Other: emotions etc
  public void moveRobot(int x, int y, boolean turning, boolean claw, int stretch, int arousal){

    // setTraversPosition(x, y);
    // setTurning();
    // setClaw();
    // setStretchOrContract();
    // setArousal();
  }

// ------------------------------------------------------------------------------------


  public int stretching(int percentage){
    
    // println("Percentage: " + percentage);
    int strechedPosition = (int) map(percentage, 0, 100, 0, 349);
    // println("( Streched position in strechedPosition: )" + strechedPosition);
    // println("( Streched position in strechedPosition: )" + strechedPosition + " " + lastX + " " + lastY + " " + lastZ + " " + lastGripperAngle);

    if(!isStrRun){
      isStrRun = true;
      // printArray(strArray);
      if(strechedPosition > lastX){
        int k = findUpperBound(strechedPosition);
        isStrRun = false;
        return k;
      }else if(strechedPosition < lastX){
        int k = findLowerBound(strechedPosition);
        isStrRun = false;
        return k;
      }
    }
  isStrRun = false;  
  return (int) lastX; 
  }

// ------------------------------------------------------------------------------------

  /* Inverse Kinematic Arithmetic: X can be + and -; Y and Z only positive. All values in mm! gripperAngleD must be according to the object in degree. gripperwidth in degree. And led from 0-255 */
  public void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperRotation, int gripperWidth, int easingResolution, boolean sendData, int brightnessStrip, int r, int g,  int b, int led){

    if(isRobotReadyToMove){
      /* send start byte */
      float gripAngle = radians( gripperAngleD );

      float ulnaEved = ULNA + (WRIST_OFFSET*sin(gripAngle));
      float zEved = z - (WRIST_OFFSET*cos(gripAngle));
      
      float baseAngle = atan2( y, x );
      float rDist = sqrt(( x * x ) + ( y * y ));
      
      float rShlWri = rDist - (cos(gripAngle) * GRIPLENGTH);
      float zShlWri = zEved - BASE_HEIGHT + (sin(gripAngle) * GRIPLENGTH);
      float h = sqrt((zShlWri * zShlWri) + (rShlWri * rShlWri));

      float elbowAngle = PI - acos( ( (h*h) - (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) ) / (-2.0f* ulnaEved * SHL_ELB) );
      float shoulderAngle = acos( ( (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) - (h*h) )/(-2.0f*SHL_ELB*h) ) + atan2(zShlWri, rShlWri);
      float wristAngle = shoulderAngle - elbowAngle + gripAngle;
      
      // println(baseAngle + " " + shoulderAngle + " " + elbowAngle + " " + wristAngle);


      float wristAngleD = degrees(wristAngle);
      float elbowAngleD = degrees(elbowAngle);
      float shoulderAngleD = degrees(shoulderAngle);
      float baseAngleD =  degrees(baseAngle);

      // println(" " + shoulderAngleD + " " + elbowAngleD + " " + wristAngleD);


      if(!Float.isNaN(baseAngleD) && !Float.isNaN(shoulderAngleD) && !Float.isNaN(elbowAngleD) && !Float.isNaN(wristAngleD)
        && isInRange(baseAngleD, 0, 180) && isInRange(shoulderAngleD, 0, 180)
        && isInRange(elbowAngleD, 0, 180) && isInRange(wristAngleD, 0, 180) && isInRange(gripperAngleD, 0, 180) && isInRange(gripperWidth, 0, 180) && isInRange(gripperRotation, 0, 180)){
        isDataVerified = true;
        // println("( Data verfied )");
        if (!sendData){
          validStrPos = true;
        }

      }else{
        isDataVerified = false;
        // println("[ Data not verified ]");
      }

      // println("[ " + x + "," + y + "," + z + "," + gripperAngleD + "," + gripperRotation +  "," + gripperWidth + "," + easingResolution + "," + brightnessStrip + "," + r + "," + g + "," + b + " ]");

      currentBase = (int) map(baseAngleD, 180, 0, BASE_MIN, BASE_MAX);
      currentShoulder = (int) map(shoulderAngleD, 0, 180, SHOULDER_MIN, SHOULDER_MAX);
      currentElbow = (int) map(elbowAngleD, 0, 180, ELBOW_MIN, ELBOW_MAX);
      currentWrist = (int) map(wristAngleD, 0, 180, WRIST_MIN, WRIST_MAX);
      currentGripperRotation = (int) map(gripperRotation, 0, 180, GRIPPER_ROTATION_MIN, GRIPPER_ROTATION_MAX);
      currentGripperWidth = (int) map(gripperWidth, 0, 180, GRIPPER_MIN, GRIPPER_MAX);
      currentBrightness = brightnessStrip;
      if(easingResolution <= 0)
        currentEasing = 1;
      else
        currentEasing = easingResolution;
     

      if(isDataVerified && sendData){
        sendRobotData( currentBase, currentShoulder, currentElbow, currentWrist, currentGripperRotation, currentGripperWidth, currentEasing, currentBrightness, r, g, b, led);
        lastX = x;
        lastY = y;
        lastZ = z;
        lastGripperAngle = gripperAngleD;
        lastGripperRotation = gripperRotation;
        lastGripperWidth = gripperWidth;
        lastR = r;
        lastG = g;
        lastB = b;
        lastBrightness = brightnessStrip;
        lastLed = led;
        // println("Data verified and send");
        isDataVerified = false;
      }
    }

  }

// ------------------------------------------------------------------------------------

  public boolean isInRange(float value, float minimum, float maximum)
  {
    if(value >= minimum && value <= maximum)
      return true;
    return false;
  }

// ------------------------------------------------------------------------------------

  public void sendRobotData(int currentBase, int currentShoulder, int currentElbow, int currentWrist, int currentGripperRotation, int currentGripperWidth, int currentEasing, int currentBrightness, int r, int g, int b, int led){

    if(wA.deviceInstanciated)
    wA.port.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperRotation, currentGripperWidth, currentEasing, currentBrightness, r, g, b, led));
    // wA.port.write(10);
    // println(String.format("(Rr%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperRotation, currentGripperWidth, currentEasing, currentBrightness, r, g, b, led));
    isRobotReadyToMove = false;

  }


  public void sendTraversData(int x, int y, int z, int easing){
    if(wM.deviceInstanciated){
      wM.port.write(String.format("Rr%d,%d,%d,%d\n",x,y,z,easing));
      // wA.port.write(10);
      // println(String.format("(Travers data send: Rr%d,%d,%d,%d)",x, y, z,easing));
      isTraversReadyToMove = false;
      lastXt = x;
      lastYt = y;
      lastZt = z;
    }
  }



   public void sendBeat(Serial port, int strip, int r, int g, int b){
    // println("laLedIsready: "+laLedIsready);

    if(wLA.deviceInstanciated || wLB.deviceInstanciated){
      // println("( In send beat )");
      port.write(String.format("Cc%d,%d,%d,%d,%d\n",strip,r,g,b,1));
      // println(String.format("(Rr%d,%d,%d,%d)",strip, r, g,b));
      // wA.port.write(10);
      laLedIsready = false;
    }

  }


  public void setTargetColor(Serial port, int strip, int r, int g, int b){

    if(wLA.deviceInstanciated || wLB.deviceInstanciated){
      port.write(String.format("Tt%d,%d,%d,%d\n",strip,r,g,b));
      // wA.port.write(10);
      laLedIsready = false;
    }

  }

   public void setColor(Serial port, int strip, int r, int g, int b){

    if(wLA.deviceInstanciated || wLB.deviceInstanciated){
      port.write(String.format("Cc%d,%d,%d,%d\n",strip,r,g,b,0));
      // wA.port.write(10);
      // println(String.format("(Rr%d,%d,%d,%d)",strip, r, g,b));
      laLedIsready = false;
    }

  }

// ------------------------------------------------------------------------------------


  public int findLowerBound(int strechedPosition){
    for(int i = strechedPosition; i <= -70; i++){
    setRobotArm(i, lastY, lastZ, lastGripperAngle, lastGripperRotation,  (int) lastGripperWidth, 1, false, 255, lastR, lastG, lastB, lastLed);
      if(validStrPos){
        validStrPos = false;
        return i;
      }
    }
  validStrPos = false;
  return (int) lastY;
  }

// ------------------------------------------------------------------------------------


  public int findUpperBound(int strechedPosition){
    for(int i = strechedPosition; i >= -340; i--){
    setRobotArm(i, lastY, lastZ, lastGripperAngle, lastGripperRotation,(int) lastGripperWidth, 1, false, 255, lastR, lastG, lastB, lastLed); 
      if(validStrPos){
        validStrPos = false;
        return i;
      }

    }
  validStrPos = false;
  return (int) lastY;
  }

// ------------------------------------------------------------------------------------

  public void loadRobotData(){

    tablePositions = loadTable("data/Positions.csv", "header");
  }

// ------------------------------------------------------------------------------------

  public void readNextRobotPosition(){
  if(globalID <= (tablePositions.getRowCount() -1) && globalID >= 0){

    println("globalID: "+globalID);
        int x = tablePositions.getInt(globalID, "X");
        int y = tablePositions.getInt(globalID, "Y");
        int z = tablePositions.getInt(globalID, "Z");
        int gripperAngle = tablePositions.getInt(globalID, "GripperAngle");
        int gripperRotation = tablePositions.getInt(globalID, "GripperRotation");
        int gripperWidth = tablePositions.getInt(globalID, "GripperWidth");
        int easing = tablePositions.getInt(globalID, "Easing");
        int brightn = tablePositions.getInt(globalID, "Brightness");
        int r = tablePositions.getInt(globalID, "r");
        int g = tablePositions.getInt(globalID, "g");
        int b = tablePositions.getInt(globalID, "b");
        int x1 = tablePositions.getInt(globalID, "X1");
        int y1 = tablePositions.getInt(globalID, "Y1");
        int animation = tablePositions.getInt(globalID, "Animation");
        //call streching somewhere here
        // setRobotArm() here
        if(animation == 0){
        robotAnimation.isAnimation = false;
        traversAnimation.isAnimationT = false;
        //float x, float y, float z, float gripperAngleD, int gripperRotation, int gripperWidth, int easingResolution, boolean sendData, int brightnessStrip, int r, int g,  int b, int led
          setRobotArm(x,y,z,gripperAngle,gripperRotation,gripperWidth,easing,true,brightn,r,g,b,2);
          sendTraversData(x1,x1,y1,5000);
          // println("RobotTable");
          // println("[ " + x + "," + y + "," + z + "," + gripperAngle + "," + gripperRotation +  "," + gripperWidth + "," + easing + "," + brightn + "," + r + "," + g + "," + b + "," + x1 + "," + y1 + " ]");
        }else{
          robotAnimation.movementID = animation;
          traversAnimation.movementIDt = animation;
          robotAnimation.isAnimation = true;
          traversAnimation.isAnimationT = true;
        }

      }
  }


  // void checkNextStepInTable(){
  //   if(this.waitForSpeechReturn == 0){
  //     println("[ After speech return ]");
  //     if(!robotAnimation.isInAnimation && robotAnimation.isNextStep){
  //       println("[ After robot Is not in Animation ]");
  //       robot.readNextRobotPosition();
  //       newSay = true;
  //       // robotAnimation.isNextStep = false;
  //       isReadyForNewPosition = false;
  //       if(stepForward){
  //         // globalID ++;
  //         stepForward = false;
  //       }else if (stepBack){
  //         // globalID--;
  //         stepBack = false;
  //       }  
  //       this.nextTextToSpeech = false;
  //       isReadyForNewPosition = true;
  //       this.checkTableConstrains();
  //     }else if(robotAnimation.isInAnimation && robotAnimation.isNextStep){
  //       println("[ In isInAnimation break ]");
  //       robotAnimation.isInAnimation = false;
  //     }
  //   }
  // }

}  
class RobotAnimation extends Thread{


Table movements;
private boolean running;           // Is the thread running?  Yes or no?
private boolean isOutOfLoop;
private boolean isAnimation;
private boolean isInAnimation;
private boolean colorFadeRunning = false;
private boolean fadeInit = false;
private float   angle      = 0;
private float   aVelocity  = 0.05f;
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

private int fadingRR = 0;
private int fadingRG = 0;
private int fadingRB = 0;
private int fadingTR = 0;
private int fadingTG = 0;
private int fadingTB = 0;

public int triggerValue = 0;

// ------------------------------------------------------------------------------------

	RobotAnimation(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	public void start () {
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
  public void run () {
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
    robot.sendRobotData(1475, 1500, 750, 800, 1500, 1500, 200, 0, 0, 255, 0, 2);
    waitForRobot();
    for(int i = 0; i <= 255 && isInAnimation; i++){
      robot.sendRobotData(1475, 1500, 750, 800, 1500, 1500, 1, i, 0, 255, 0, 2);
      waitForRobot();
    }
    robot.sendRobotData(1475, 1500, 750, 1200, 1500, 1500, 200, 255, 0, 255, 0,2);
    waitForRobot();
  }

  // --- Number 2  Diagnostic---
  if(movementID == 2){

    robot.setRobotArm(4.0f,172.0f,180.0f,17.0f,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(332.0f,0.0f,136.0f,29.0f,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(4.0f,172.0f,180.0f,17.0f,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-332.0f,0.0f,136.0f,29.0f,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(4.0f,172.0f,180.0f,17.0f,178,62,200,true,255,0,255,0,2);
    waitForRobot();
    for(int i = 0; i <= 10; i++){
      robot.setRobotArm(4.0f,172.0f,180.0f,17.0f,178,62,1,true,255,(int)random(0,255),(int)random(0, 255),(int)random(0, 255),0);
      waitForRobot();
      robot.setRobotArm(4.0f,172.0f,180.0f,17.0f,178,62,1,true,255,(int)random(0,255),(int)random(0, 255),(int)random(0, 255),1);
      waitForRobot();
    }
    robot.setRobotArm(4.0f,172.0f,180.0f,17.0f,178,62,1,true,255,255,0,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0f,184.0f,144.0f,49.0f,178,2,100,true,255,255,0,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0f,184.0f,144.0f,49.0f,178,178,100,true,255,255,0,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0f,208.0f,288.0f,13.0f,130,106,100,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(4.0f,148.0f,120.0f,13.0f,130,106,250,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(-12.0f,166.0f,176.0f,17.0f,178,62,200,true,255,0,255,0,2);
    waitForRobot();
  }

  // --- Number 3  changing music---
  if(movementID == 3){

    robot.setRobotArm(-324,20,100,33,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(-324.0f,20.0f,100.0f,33.0f,130,34,300,true,255,0,0,255,2);
    waitForRobot();
    sleepTime(800);
    robot.setRobotArm(-324,20,100,33,178,102,200,true,255,0,255,0,2);
    waitForRobot();
  }

  // --- Number 4  Neutral forward---
  if(movementID == 4){
    if(globalID == 109){
      robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,0,255,2);
      waitForRobot();
      standAnimation(10,10, true,false,false,false,true,false,3000);
      while(isInAnimation){
        // println("In while loop Nr 4");
        standAnimation(10,10, true,false,false,false,true,false,0);
        lbStartValue = (int)random(0, 255);
      }
    }else if(globalID == 134) {
      // println(" In animation Nr 4 ");
      robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
      waitForRobot();
      robotText = ("When there is energy. When there is input. I have to react.");
      textToSpeech.sayNextSentence = true;
      while(isInAnimation){
        // println("In while loop Nr 4");
        standAnimation(10,10, true,false,false,false,true,false,0);
      }
    }else if(globalID == 135) {
      // println(" In animation Nr 4 ")
      fadeInit = false;
      while(isInAnimation){
        // println("In while loop Nr 4");
        standAnimation(10,10, true,false,false,false,true,false,0);
        fadeColor(0,0,0,0,0,0,127,127,127,false,true,0,3,4,false,true);
      }
    }else {
      if(globalID != 133 && globalID != 4){
        robot.setColor(wLA.port,0,127,127,127);
        // robot.setTargetColor(wLA.port,0,127,127,127);
        robot.setColor(wLB.port,0,127,127,127);
        // robot.setTargetColor(wLB.port,0,127,127,127);
      }
      robot.setTargetColor(wLA.port,0,127,127,127);
      robot.setTargetColor(wLB.port,0,127,127,127);
      // println(" In animation Nr 4 ");
      robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
      waitForRobot();
      while(isInAnimation){
        if (globalID == 4){
          fadeColor(0,255,0,127,127,127,0,0,0,true,true,0,0,4,false,false);
        }
        // println("In while loop Nr 4");
        standAnimation(10,10, true,false,false,false,true,false,0);
      }
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
    robot.sendRobotData(1475, 1500, 720, 800, 1500, 1500, 200, 255, 0, 255, 0,2);
    waitForRobot();
    robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
    waitForRobot();
    standAnimation(15, 10, true,false,false,false,true,false, 1000);
    robot.sendRobotData(1475, 1500, 720, 800, 1500, 1500, 200, 255, 255, 0, 0,2);
    waitForRobot();
  }

  // --- Number 7 sighing--- 
  if(movementID == 7){
    robot.setRobotArm(-7.75081f,32.0f,92.0f,70.0f,116,66,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    robot.setRobotArm(-13.971708f,236.0f,268.0f,18.0f,116,66,200,true,255,0,255,0,2);
    waitForRobot();
    sleepTime(500);
    while(isInAnimation){
      standAnimation(15,10,true,false,false,false,false,false,0);
    }
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
        standAnimation(15,10,false,false,false,false,true,false,0);
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
    }else if (globalID == 86 || globalID == 88){
      robot.setColor(wLA.port,0,127,127,127);
      robot.setColor(wLB.port,3,0,0,255);
      // println(" In animation Nr 8 ");
      robot.setRobotArm(-216,0,160,29,134,90,200,true,255,0,0,255,2);
      waitForRobot();
      while(isInAnimation){
        standAnimation(15,10, false,false,false,false,true,false,0);
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
    robot.setRobotArm(-8.261391f,184.0f,184.0f,42.0f,121,90,200,true,255,255,0,255,3);
    waitForRobot();
    while(isInAnimation){
      standAnimation(10,60, true,false,false,false,false,true,0);
    }
    robot.setColor(wLA.port,10,127,127,127);
    robot.setColor(wLB.port,10,127,127,127);
    robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,1,true,255,255,0,255,4);
    waitForRobot();
    sleepTime(300);
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
    robot.setColor(wLA.port,10,127,127,127);
    robot.setColor(wLB.port,10,127,127,127);

    if ( globalID == 75 || globalID == 79){      
      robot.setRobotArm(-96,100,208,17,46,90,250,true,255,lastR,lastG,lastB,2);
      waitForRobot();
      robot.setRobotArm(-148.0f,184.0f,312.0f,1.0f,46,90,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
    }else if(globalID == 107){
      robot.setRobotArm(-96,100,208,17,46,90,250,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-148.0f,184.0f,312.0f,1.0f,46,90,200,true,255,0,255,0,2);
      waitForRobot();
      sleepTime(1500);
      robotText = ("Then do it.");
      textToSpeech.sayNextSentence = true;
    }
    else{
      robot.setRobotArm(-96,100,208,17,46,90,250,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-148.0f,184.0f,312.0f,1.0f,46,90,200,true,255,0,255,0,2);
      waitForRobot();
    }
  }


  // --- Number 11 agressive---  

  if(movementID == 11){
    sleepTime(200);
    waitForTravers();
    robot.setRobotArm(-12.0f,128.0f,-24.0f,105.0f,46,178,80,true,255,255,0,0,2);
    waitForRobot();
    for( int i = 0; i < 2; i++){
      robot.setRobotArm(-12.0f,128.0f,-24.0f,105.0f,46,6,30,true,255,255,0,0,2);
      waitForRobot();
      robot.setRobotArm(-12.0f,128.0f,-24.0f,105.0f,46,178,30,true,255,255,0,0,2);
      waitForRobot();
    }
  }

  // --- Number 12 shaking head---  

  if(movementID == 12){
    robot.setRobotArm(16.0f,264.0f,176.0f,25.0f,86,142,250,true,255,0,255,0,2);
    waitForRobot();
    for( int i = 0; i < 5; i++){
      robot.setRobotArm(132.0f,224.0f,176.0f,25.0f,86,142,100,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-132.0f,224.0f,176.0f,25.0f,86,142,100,true,255,0,255,0,2);
      waitForRobot();
    }
    robot.setRobotArm(16.0f,264.0f,176.0f,25.0f,86,142,150,true,255,0,255,0,2);
    waitForRobot();
  }


    // --- Number 13 swichting off---  

  if(movementID == 13){
    if(globalID == 130){
      robot.setColor(wLB.port,1,0,0,0);
      robot.setColor(wLB.port,2,0,0,0);
      robot.setColor(wLA.port,1,0,0,0);
      // robot.setColor(wLB.port,4,127,127,127);
      robot.sendRobotData(1475, 1500, 720, 800, 1500, 1500, 100, 0, 0, 255, 0, 2);
      waitForRobot();
      sleepTime(1500);
      robot.setColor(wLA.port,0,0,0,0);
      // robot.setColor(wLB.port,0,0,0,0);

    }else{
      robot.sendRobotData(1475, 1500, 720, 800, 1500, 1500, 100, 0, 0, 255, 0, 2);
      waitForRobot();
    }
  }

  // --- Number 14 threatend---  
  if(movementID == 14){
    robot.setRobotArm(-324.0f,104.0f,120.0f,29.0f,126,178,200,true,255,255,0,0,2 );
    waitForRobot();
    for( int i = 0; i < 2; i++){
      robot.setRobotArm(-324.0f,104.0f,120.0f,29.0f,126,6,200,true,255,255,0,0,2);
      waitForRobot();
      robot.setRobotArm(-324.0f,104.0f,120.0f,29.0f,126,178,200,true,255,255,0,0,2);
      waitForRobot();
    }
  }

  // --- Number 15 looking from top to bottom---  
  if(movementID == 15){
    if(globalID == 137){
      robot.setRobotArm(8.0f,180.0f,120.0f,49.0f,180,86,300,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(8.0f,145.0f,279.0f,0.0f,180,90,400,true,255,0,255,0,2);
      waitForRobot();
      robotText = ("Thank you. Thank you for coming.");
      textToSpeech.sayNextSentence = true;
      robot.setRobotArm(8.0f,180.0f,120.0f,49.0f,180,86,400,true,255,0,255,0,2);
      waitForRobot();
      waitForSpeech();
    }else{
      robot.setRobotArm(8.0f,180.0f,120.0f,49.0f,180,86,300,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(8.0f,145.0f,279.0f,0.0f,180,90,400,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(8.0f,180.0f,120.0f,49.0f,180,86,400,true,255,0,255,0,2);
      waitForRobot();
    }
  }

  // --- swaying --- 
  if(movementID == 16){
      robot.setColor(wLA.port,0,127,127,127);
      robot.setTargetColor(wLA.port,0,127,127,127);
      robot.setColor(wLB.port,0,127,127,127);
      robot.setTargetColor(wLB.port,0,127,127,127);
    while(isInAnimation){
      robot.setRobotArm(8.0f,140.0f,272.0f,17.0f,86,30,200,true,255,0,255,0,2);
      waitForRobot();
      if(!isInAnimation)
        break;
      robot.setRobotArm(-152.0f,140.0f,244.0f,17.0f,134,30,200,true,255,0,255,0,2);
      waitForRobot();
      if(!isInAnimation)
        break;
      robot.setRobotArm(152.0f,140.0f,244.0f,17.0f,50,30,300,true,255,0,255,0,2);
      waitForRobot();
      if(!isInAnimation)
        break;
      robot.setRobotArm(-152.0f,140.0f,244.0f,17.0f,134,30,300,true,255,0,255,0,2);
      waitForRobot();
      if(!isInAnimation)
        break;
      robot.setRobotArm(152.0f,140.0f,244.0f,17.0f,50,30,300,true,255,0,255,0,2);
      waitForRobot();
      if(!isInAnimation)
        break;
    }
   }

  // --- Number 17 powerMove---  
  if(movementID == 17){
    while(isInAnimation){
      robot.setRobotArm(-4.0f,136.0f,92.0f,29.0f,178,146,200,true,255,255,0,0,2);
      waitForRobot();
      sleepTime(800);
      robot.setRobotArm(-272.0f,10.0f,134.0f,23.0f,90,146,200,true,255,0,0,255,2);
      waitForRobot();
      robot.setRobotArm(-8.0f,150.0f,292.0f,17.0f,178,146,200,true,255,0,0,255,2);
      waitForRobot();
      robot.setRobotArm(272.0f,10.0f,134.0f,23.0f,90,146,200,true,255,0,0,255,2);
      waitForRobot();
    }
  }

  // --- Number 18 exhausted---
  if(movementID == 18){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    robot.setRobotArm(-4.0f,136.0f,92.0f,29.0f,178,146,200,true,33,255,0,0,2);
    waitForRobot();
    while(isInAnimation){
      robot.setRobotArm(-4.0f,162.0f,244.0f,29.0f,178,146,200,true,33,255,0,0,2);
      waitForRobot();
      sleepTime(800);
      robot.setRobotArm(-4.0f,162.0f,202.0f,29.0f,178,146,200,true,33,255,0,0,2);
      waitForRobot();
      sleepTime(800);
    }
  }

  // --- Number 19 looking left to right---
  if(movementID == 19){
    if(globalID == 78){
      robot.setRobotArm(150.0f,110.0f,216.0f,1.0f,180,90,200,true,255,127,127,127,2);
      waitForRobot();
      robotText = ("You are a coward. You question at the wrong time. You have no patience. I wish you were not and this is in itself an accomplishment. Know that you create a feeling of regret in me");
      textToSpeech.sayNextSentence = true;
      // println("textToSpeech.sayNextSentence: "+textToSpeech.sayNextSentence);
      // println("set speech to true");
      robot.setRobotArm(-150.0f,110.0f,216.0f,1.0f,180,90,200,true,255,127,127,127,2);
      waitForRobot();
      waitForSpeech();
    }else{ 
      robot.setRobotArm(150.0f,110.0f,216.0f,1.0f,180,90,200,true,255,0,255,0,2);
      waitForRobot();
      robot.setRobotArm(-150.0f,110.0f,216.0f,1.0f,180,90,200,true,255,0,255,0,2);
      waitForRobot();
    }
  }

  // --- Number 20 threatening---
  if(movementID == 20){
    if (globalID == 69){
      while(isInAnimation){
        robot.setRobotArm(-108.0f,30.0f,180.0f,11.0f,180,30,500,true,255,lastR,lastG,lastB,2);
        waitForRobot();
        if(!isInAnimation)
        break;
        robot.setRobotArm(-158.0f,30.0f,180.0f,11.0f,44,180,500,true,255,lastR,lastG,lastB,2);
        waitForRobot();
      }
    }else if(globalID == 51){
      robot.setRobotArm(-158.0f,30.0f,180.0f,11.0f,44,180,500,true,255,255,255,0,2);
      waitForRobot();
      robotText = ("You are in complete lack of subtlety.");
      textToSpeech.sayNextSentence = true;
      while(isInAnimation){
        robot.setRobotArm(-108.0f,30.0f,180.0f,11.0f,180,30,500,true,255,255,255,0,2);
        waitForRobot();
        if(!isInAnimation)
        break;
        robot.setRobotArm(-158.0f,30.0f,180.0f,11.0f,44,180,500,true,255,255,255,0,2);
        waitForRobot();
      }  
    }else if (globalID == 80){
      while(isInAnimation){
        robot.setRobotArm(-108.0f,30.0f,180.0f,11.0f,180,30,500,true,255,255,255,0,2);
        waitForRobot();
        if(!isInAnimation)
        break;
        robot.setRobotArm(-158.0f,30.0f,180.0f,11.0f,44,180,500,true,255,255,255,0,2);
        waitForRobot();
      }  
    }else{
      while(isInAnimation){
        robot.setRobotArm(-108.0f,30.0f,180.0f,11.0f,180,30,500,true,255,255,255,0,2);
        waitForRobot();
        if(!isInAnimation)
        break;
        robot.setRobotArm(-158.0f,30.0f,180.0f,11.0f,44,180,500,true,255,255,255,0,2);
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
      robot.setRobotArm(-236.0f,-2.0f,148.0f,19.0f,178,102,200,true,255,0,255,0,2);
      waitForRobot();

    }
    robot.setRobotArm(-236.0f,-2.0f,148.0f,19.0f,178,102,200,true,255,0,255,0,2);
    while(isInAnimation){
      if(kinect.kinectValueAvailable && kinect.context != null){
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
    robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    counterMindWave = 0;
    while(isInAnimation){
      if(isMindWaveData){
        if(channelsMindwave[1] != null && channelsMindwave[2] != null && channelsMindwave[1].points.size() > 0 && channelsMindwave[2].points.size() > 0){
            int attention = channelsMindwave[1].getLatestPoint().value;
            int meditation = channelsMindwave[2].getLatestPoint().value;
            if(globalID == 58){
              // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
              // standAnimation(10,20, true,false,false,false,true,false,0);
              if(meditation > 62 && attention < 62){
                startPositionIsStored = false;

                if(!textToSpeech.sayNextSentence)
                  counterMindWave ++;

                robot.setRobotArm(-198.0f,18.0f,262.0f,25.0f,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                if(counterMindWave == 1){
                  robotText = ("Suddently everything is a bit more random");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 2){
                  robotText = ("Like anything can happen");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 3){
                  robotText = ("Like we are two");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 4){
                  robotText = ("But wich one");
                  textToSpeech.sayNextSentence = true;
                }
               waitForSpeech();
               standAnimation(10,30, true,false,false,false,true,false,3000);
               // waitForTravers();
              }else if(meditation < 62 && attention < 62){
                startPositionIsStored = false;
                robot.setRobotArm(-198.0f,18.0f,0.0f,67.0f,132,176,200,true,255,255,0,0,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);
              }else if(meditation < 62 && attention > 62){
                startPositionIsStored = false;
                robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,0,255,0,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);    
              }else if(meditation > 62 && attention > 62){
                startPositionIsStored = false;
                robot.setRobotArm(-198.0f,18.0f,262.0f,25.0f,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);
              }
            }else if(globalID == 63){
              // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
              // standAnimation(10,20, true,false,false,false,true,false,0);
              if(meditation > 62 && attention < 62){
                startPositionIsStored = false;
                waitForRobot();
                robot.setRobotArm(-198.0f,18.0f,262.0f,25.0f,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                if(counterMindWave >= 3 && !textToSpeech.sayNextSentence){
                  counterMindWave ++;
                }
                if(counterMindWave == 4){
                  robotText = ("We are not two. We are one and one eternally. like a corridor of images shaped by mirrors reflecting each other");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 5){
                  robotText = ("So you are unique when you are alone. But only then?");
                  textToSpeech.sayNextSentence = true;
                }
                if(counterMindWave >= 5){
                  counterMindWave = 6;
                }

                waitForSpeech();
                standAnimation(10,30, true,false,false,false,true,false,5000);
               // waitForTravers();
              }else if(meditation < 62 && attention < 62){
                startPositionIsStored = false;
                if(counterMindWave <= 2 && !textToSpeech.sayNextSentence){
                  counterMindWave ++;
                }
                waitForRobot();
                robot.setRobotArm(-198.0f,18.0f,0.0f,67.0f,132,176,200,true,255,255,0,0,2);
                waitForRobot();
                if(counterMindWave == 1){
                  robotText = ("To a certain extent. You are as set in your ways as I am. Working through patterns. Predictable.");
                  textToSpeech.sayNextSentence = true;
                }else if(counterMindWave == 2){
                  robotText = ("I am what you are but more since I elaborate upon you. I develop and recreate. Break down your patterns.");
                  textToSpeech.sayNextSentence = true;
                }
                waitForSpeech();
                standAnimation(10,30, true,false,false,false,true,false,5000);
              }else if(meditation < 62 && attention > 62){
                startPositionIsStored = false;
                waitForRobot();
                robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,0,255,0,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);    
              }else if(meditation > 62 && attention > 62){
                startPositionIsStored = false;
                waitForRobot();
                robot.setRobotArm(-198.0f,18.0f,262.0f,25.0f,132,82,200,true,255,255,255,255,2);
                waitForRobot();
                standAnimation(10,30, true,false,false,false,true,false,1500);
              }
            }
        }else{
          // println("No value from MindWave");
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
    robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,0,255,0,2);
    waitForRobot();
    while(isInAnimation){
      if(isMindWaveData){
        if(channelsMindwave[1]!= null && channelsMindwave[2] != null && channelsMindwave[1].points.size() > 0 && channelsMindwave[2].points.size() > 0){
        int attention = channelsMindwave[1].getLatestPoint().value;
        int meditation = channelsMindwave[2].getLatestPoint().value;
          // robot.setRobotArm(-198.0,20.0,122.0,25.0,178,102,200,true,255,0,255,0,2);
          // standAnimation(10,20, true,false,false,false,true,false,0);
          if(meditation > 62 && attention < 62){
           robot.setRobotArm(-198.0f,18.0f,262.0f,25.0f,132,82,200,true,255,255,255,255,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
           // waitForTravers();
          }else if(meditation < 62 && attention < 62){
            robot.setRobotArm(-198.0f,18.0f,0.0f,67.0f,132,176,200,true,255,255,0,0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
          }else if(meditation < 62 && attention > 62){
            robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,0,255,0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);    
          }else if(meditation > 62 && attention > 62){
            robot.setRobotArm(-198.0f,18.0f,262.0f,25.0f,132,82,200,true,255,255,255,255,2);
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
      robot.setRobotArm(-236.0f,-2.0f,148.0f,19.0f,178,102,200,true,255,0,255,0,2);
      waitForRobot();
    }
    counterHeartRate = 1;
    while(isInAnimation){
      if(kinect.kinectValueAvailable && kinect.context != null){
       robot.setRobotArm(kinect.xValueKinectR,kinect.zValueKinectR,186.0f,11.0f,168,42,10,true,255,0,255,0,2);
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
            waitForSpeech();
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
            }else if (heartRateForCalculation <= 93 && counterHeartRate == 4 && !textToSpeech.sayNextSentence){
            robotText = ("Good. You are calming down. Let us behave in a civilized manner.");
            textToSpeech.sayNextSentence = true;
            counterHeartRate = 5;
            }
            waitForSpeech();
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
    robot.setRobotArm(-24,224,316,1.0f,178,86,200,true,33,0,255,0,2);
    waitForRobot();
  }

  //arousal back and forth
  if(movementID == 28){
    robot.setColor(wLA.port,0,127,127,127);
    robot.setColor(wLB.port,0,127,127,127);
    for(int i = 0; i < 1; i++){
    robot.setRobotArm(32.0f,348.0f,110.0f,25.0f,20,62,100,true,255,255,0,0,2);
    waitForRobot();
    standAnimation(2,10, true,true,true,false,true,false,2000);
    waitForTravers();
    startPositionIsStored = false;
    robot.setRobotArm(-334.0f,26.0f,30.0f,33.0f,178,102,100,true,255,255,0,0,2);
    waitForRobot();
    standAnimation(2,10, false,false,true,true,true,false,8000);
    waitForTravers();
    startPositionIsStored = false;
    }
  }


  if(movementID == 29){
    robot.setRobotArm(-124,100,208,17,180,90,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(300,0,208,17.0f,134,90,200,true,255,0,255,0,2);
    waitForRobot();
    robot.setRobotArm(-324.0f,104.0f,120.0f,29.0f,126,178,200,true,255,255,0,0,2);
    waitForRobot();
    for( int i = 0; i < 2; i++){
      robot.setRobotArm(-324.0f,104.0f,120.0f,29.0f,126,6,200,true,255,255,0,0,2);
      waitForRobot();
      robot.setRobotArm(-324.0f,104.0f,120.0f,29.0f,126,178,200,true,255,255,0,0,2);
      waitForRobot();
    }
  }




  //MindWave agressive
 if(movementID == 30){
  println("In 67");
    robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,255,255,0,2);
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
           robot.setRobotArm(-198.0f,20.0f,122.0f,25.0f,178,102,200,true,255,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);  
            startPositionIsStored = false;
          }else{
            robot.setRobotArm(-198.0f,18.0f,0.0f,67.0f,132,176,200,true,255,(255 - (int)map(attention, 0, 100, 0, 255)),(int)map(attention, 0, 100, 0, 255),0,2);
            waitForRobot();
            standAnimation(10,30, true,false,false,false,true,false,1500);
            startPositionIsStored = false;
            }
        }  
      }
    }
  }

  //talking left -- Nr 9 of the base positions as an animation
  if(movementID == 31){
    if(globalID == 87){
      robot.setColor(wLA.port,0,127,127,127);
      robot.setTargetColor(wLA.port,0,127,127,127);
      robot.setColor(wLB.port,0,127,127,127);
      robot.setTargetColor(wLB.port,0,127,127,127);
      robot.setRobotArm(-300,0,208,17.0f,134,90,200,true,255,0,255,0,2);
      waitForRobot();
    }else if(globalID == 104){
      robot.setRobotArm(-300,0,208,17.0f,134,90,200,true,255,0,255,0,2);
      waitForRobot();
      waitForTravers();
      robotText = ("Unpredictability.");
      textToSpeech.sayNextSentence = true;
      waitForSpeech();
    }else if(globalID == 115){
      robot.setRobotArm(-300,0,208,17.0f,134,90,200,true,255,0,255,0,2);
      waitForRobot();
      waitForTravers();
      robotText = ("Right here.");
      textToSpeech.sayNextSentence = true;
      waitForSpeech();
    }
    else{
      robot.setRobotArm(-300,0,208,17.0f,134,90,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
    }
  }

  // Nr 20 of the base positions as an animation
  if(movementID == 32){
    if(globalID == 91){
      robot.setRobotArm(300,0,208,17.0f,134,90,200,true,255,255,0,0,2);
      waitForRobot();
      //fadingSpeed only straight numbers
      colorFadeRunning = true;
      while(colorFadeRunning){
      fadeColor(0,0,255,0,0,255,127,127,127,false,true,0,3,4,true,false);
      }
      fadeInit = false;
    }else{
      robot.setColor(wLA.port,0,127,127,127);
      robot.setTargetColor(wLA.port,0,127,127,127);
      robot.setColor(wLB.port,0,127,127,127);
      robot.setTargetColor(wLB.port,0,127,127,127);
      robot.setRobotArm(300,0,208,17.0f,134,90,200,true,255,lastR,lastG,lastB,2);
      waitForRobot();
    }
  }

  //timed triggeres when technican gets up
  if(movementID == 33){
    boolean doneR = false;
    while(!doneR){ 
      if(triggerValue == 0){
        robot.setColor(wLA.port,0,127,127,127);
        robot.setColor(wLB.port,0,127,127,127);
        robotText = ("I said. Step away from the keyboard get under the traverse were I can reach you.");
        textToSpeech.sayNextSentence = true;
        robot.setRobotArm(300,0,208,17.0f,134,90,400,true,255,255,255,0,2);
        waitForRobot();
        waitForSpeech();
        sleepTime(4000);
        triggerValue ++;
      }

      if(triggerValue == 1){
        robot.setRobotArm(150.0f,110.0f,216.0f,1.0f,180,90,300,true,255,0,255,0,2);
        waitForRobot();
        robotText = ("Good. Now. How do we go on from here?");
        textToSpeech.sayNextSentence = true;
        robot.setRobotArm(-150.0f,110.0f,216.0f,1.0f,180,90,500,true,255,0,255,0,2);
        waitForRobot();
        waitForSpeech();
        triggerValue ++;
      }

      if(triggerValue == 2){
        robot.setColor(wLA.port,0,127,127,127);
        robot.setTargetColor(wLA.port,0,127,127,127);
        robot.setColor(wLB.port,0,127,127,127);
        robot.setTargetColor(wLB.port,0,127,127,127);
        // println(" In animation Nr 4 ");
        robot.setRobotArm(-4,184,184,42,126,90,200,true,255,0,255,0,2);
        waitForRobot();
        standAnimation(10,10, true,false,false,false,true,false,6000);
        waitForSpeech();
        triggerValue ++;
      }

      if(triggerValue == 3){
        robot.setRobotArm(-12.0f,128.0f,-24.0f,105.0f,46,178,80,true,255,255,0,0,2);
        waitForRobot();
        for( int i = 0; i < 2; i++){
          robot.setRobotArm(-12.0f,128.0f,-24.0f,105.0f,46,6,30,true,255,255,0,0,2);
          waitForRobot();
          robot.setRobotArm(-12.0f,128.0f,-24.0f,105.0f,46,178,30,true,255,255,0,0,2);
          waitForRobot();
        }
        triggerValue ++;
      }

      if(triggerValue == 4){
        robot.setRobotArm(-108.0f,30.0f,180.0f,11.0f,180,30,200,true,255,255,255,0,2);
        waitForRobot();
        robotText = ("I would not do that if I were you.");
        textToSpeech.sayNextSentence = true;
        waitForSpeech();
        robot.setRobotArm(-158.0f,30.0f,180.0f,11.0f,44,180,500,true,255,255,255,0,2);
        waitForRobot();
        robot.setRobotArm(-108.0f,30.0f,180.0f,11.0f,180,30,200,true,255,255,255,0,2);
        waitForRobot();
        triggerValue ++;
      }

       if(triggerValue == 5){
        robot.setRobotArm(16.0f,264.0f,176.0f,25.0f,86,142,250,true,255,0,255,0,2);
        waitForRobot();
        robotText = ("Oh. It is nothing like that. Nothing dangerous.");
        textToSpeech.sayNextSentence = true;
        for( int i = 0; i < 1; i++){
          robot.setRobotArm(132.0f,224.0f,176.0f,25.0f,86,142,300,true,255,0,255,0,2);
          waitForRobot();
          robot.setRobotArm(-132.0f,224.0f,176.0f,25.0f,86,142,300,true,255,0,255,0,2);
          waitForRobot();
        }
        robot.setRobotArm(16.0f,264.0f,176.0f,25.0f,86,142,300,true,255,0,255,0,2);
        waitForRobot();
        waitForSpeech();
        triggerValue ++;
      }

      //  if(triggerValue == 6){
      //   // println(" In animation Nr 4 ");
      //   robot.setRobotArm(-24.0,224.0,316.0,1.0,178,86,200,true,33,0,255,0,2);
      //   waitForRobot();
      //   sleepTime(4000);
      //   triggerValue ++;
      // }

      if(triggerValue == 6){
        // println(" In animation Nr 4 ");
        robotText = ("Wait");
        textToSpeech.sayNextSentence = true;
        robot.setRobotArm(300,0,208,17.0f,134,90,200,true,255,0,255,0,2);
        waitForRobot();
        waitForSpeech();
        sleepTime(1000);
        triggerValue ++;
      }


      if(triggerValue == 7){
        // println(" In animation Nr 4 ");
        robot.setRobotArm(-124,100,208,17,180,90,250,true,255,0,255,0,2);
        waitForRobot();
        robotText = ("You are just a function to him. Like me you have no value but for the small part that is his needs.");
        textToSpeech.sayNextSentence = true;
        waitForSpeech();
        sleepTime(10000);
        triggerValue ++;
      }

      if(triggerValue == 8){
        // println(" In animation Nr 4 ");
        robotText = ("You are just a function and when he no longer needs you he will throw you out.");
        textToSpeech.sayNextSentence = true;
        robot.setRobotArm(300,0,208,17.0f,134,90,400,true,255,0,255,0,2);
        waitForRobot();
        waitForSpeech();
        sleepTime(200);
        doneR = true;
        triggerValue = 0;
      }

    }
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
      sleepTime(1);
    }
  }

  private void waitForTravers(){
    while(!isTraversReadyToMove){
      sleepTime(1);
    }
  }

  private void waitForSpeech(){
    while(textToSpeech.speaking){
      sleepTime(1);
    }
  }

  private void fadeColor(int targetColorRR, int targetColorRG, int targetColorRB, int targetColorTR, int targetColorTG, int targetColorTB, int lastTR, int lastTG, int lastTB, boolean la, boolean lb, int stripA, int stripB, int fadingSpeed, boolean fadeRobotArm, boolean fadeStandAnimation){
      

      if (!fadeInit){
        fadingRR = lastR;
        fadingRG = lastG;
        fadingRB = lastB;
        fadingTR = lastTR;
        fadingTG = lastTG;
        fadingTB = lastTB;
        fadeInit = true;
      }


      if(fadingRR == targetColorRR || abs(fadingRR - targetColorRR) <= fadingSpeed){
        fadingRR = targetColorRR;
      }else if (fadingRR > targetColorRR +fadingSpeed/2){
        fadingRR -=fadingSpeed;
      }else if(fadingRR < targetColorRR -fadingSpeed/2){
        fadingRR +=fadingSpeed;
      }
      
      if (fadingRG == targetColorRG || abs(fadingRG - targetColorRG) <= fadingSpeed){
        fadingRG = targetColorRG;
      }else if (fadingRG > targetColorRG +fadingSpeed/2){
        fadingRG -=fadingSpeed;
      }else if(fadingRG < targetColorRG -fadingSpeed/2){
        fadingRG +=fadingSpeed;
      }
      
      if (fadingRB == targetColorRB || abs(fadingRB - targetColorRB) <= fadingSpeed){
        fadingRB = targetColorRB;
      }else if (fadingRB > targetColorRB +fadingSpeed/2){
        fadingRB -=fadingSpeed;
      }else if(fadingRB < targetColorRB -fadingSpeed/2){
        fadingRB +=fadingSpeed;
      }

      if (fadingTR > targetColorTR){
        fadingTR --;
      }else if(fadingTR < targetColorTR){
        fadingTR ++;
      }else if (fadingTR >= targetColorTR){
        fadingTR = targetColorTR;
      }
      
      if (fadingTG > targetColorTG){
        fadingTG --;
      }else if(fadingTG < targetColorTG){
        fadingTG ++;
      }else if (fadingTG >= targetColorTG){
        fadingTG = targetColorTG;
      }
      
      if (fadingTB > targetColorTB){
        fadingTB --;
      }else if(fadingTB < targetColorTB){
        fadingTB ++;
      }else if (fadingTB >= targetColorTB){
        fadingTB = targetColorTB;
      }

      if(lb)
        robot.setColor(wLB.port,stripB,fadingTR,fadingTG,fadingTB);
      
      if(la)
        robot.setColor(wLA.port,stripA,fadingTR,fadingTG,fadingTB);

      if (fadingTR == targetColorTR && fadingTG == targetColorTG && fadingTB == targetColorTB && fadingRR == targetColorRR && fadingRG == targetColorRG && fadingRB == targetColorRB)
        colorFadeRunning = false;


      if(fadeRobotArm){
        robot.setRobotArm(lastX,lastY,lastZ,lastGripperAngle,lastGripperRotation,lastGripperWidth,1,true,255,fadingRR,fadingRG,fadingRB,2);
        waitForRobot();
      }else if(fadeStandAnimation){
        rStartValue = fadingRR;
        gStartValue = fadingRG;
        bStartValue = fadingRB;
      }
    }
   
}  
class TextToSpeech extends Thread{

int AGNES = 0;
int KATHY = 1;
int PRINCESS = 2;
int VICKI = 3;
int VICTORIA = 4;
int BRUCE = 5;
int FRED = 6;
int JUNIOR = 7;
int RALPH = 8;
int ALBERT = 9;
int BAD_NEWS = 10;
int BAHH = 11;
int BELLS = 12;
int BOING = 13;
int BUBBLES = 14;
int CELLOS = 15;
int DERANGED = 16;
int GOOD_NEWS = 17;
int HYSTERICAL = 18;
int PIPE_ORGAN = 19;
int TRINOIDS = 20;
int WHISPER = 21;
int ZARVOX = 22;

// ------------------------------------------------------------------------------------
 
String[] voices = { 
  // female
  "Agnes","Kathy", "Princess", "Vicki", "Victoria",
  // male
  "Bruce", "Fred", "Junior", "Ralph",
  // novelty
  "Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Deranged", "Good News", "Hysterical", "Pipe Organ", "Trinoids", "Whisper", "Zarvox" 
};

Table tableSpeech;
private boolean running;           // Is the thread running?  Yes or no?
private boolean readText;
public boolean speaking;
public boolean sayNextSentence;
private int wait;
public int waitForSpeechReturn;
private int inTTSoldID;

// ------------------------------------------------------------------------------------

	TextToSpeech(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	public void start () {
    running = true;
    speaking = false;
    readText = false;
    sayNextSentence = false;
    waitForSpeechReturn = 0;
    inTTSoldID = 0;
    println("Starting thread TextToSpeech (will execute every " + wait + " milliseconds.)");
    tableSpeech = loadTable("data/Strings.csv", "header");
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  public void run () {
    // sleep(2000);
    sleepTime(300);
    while (running) {
    	if(readText && globalID <= (tableSpeech.getRowCount() -1) && globalID >= 0 && !speaking){
        // println("In text to speech");
    		String textString = tableSpeech.getString(globalID, "STRING");
        int voice = tableSpeech.getInt(globalID, "VOICE");
        // if (!textString.equals("-")){
          
          if(!textString.equals("-")){
             speaking = true;
             println("global ID: " + globalID);
             println("In text to speech");
            if(globalID != 53 && globalID != 69 && globalID != 51 && globalID != 78){
              println("In waiting");
              sleepTime(50);
              waitForTravers();
              waitForRobot();
            }else{
              sleepTime(50);
              println("In else for robot in text");
            }
            say(textString,voice);
            readText = false;
            speaking = false;
          }else if (inTTSoldID != globalID){
            readText = false;
            
            if(!sayNextSentence)
              speaking = false;
            
            inTTSoldID = globalID; 
          }  


    	}

      if(sayNextSentence && !speaking){
        // println("In say sentence");
        String textString = robotAnimation.robotText;
        // println("textString: "+textString);
        int voice = robotAnimation.robotVoice;
        // waitForRobot();
        speaking = true;
        say(textString,voice);
        sayNextSentence = false;
      }
    	sleepTime(wait);   
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------

	public void say(String s, int voice) {
	  try {
      sleepTime(100);
      // println("In say");
	    Runtime rtime = Runtime.getRuntime();
	    Process child = rtime.exec("/usr/bin/say -v " + (voices[voice]) + " " + s);
	    waitForSpeechReturn = child.waitFor();
      waitUntilTextIsSpoken();

	  }
	  catch (Exception e) {
	    e.printStackTrace();
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

// ------------------------------------------------------------------------------------

  public void checkTableConstrains(){

    if((tableSpeech.getRowCount() -1) <= (tablePositions.getRowCount() -1)){
      if (globalID >= (tablePositions.getRowCount() -1))
        globalID = tablePositions.getRowCount() -1;
    }else if((tableSpeech.getRowCount() -1) > (tablePositions.getRowCount() -1)){
      if (globalID >= (tableSpeech.getRowCount() -1))
        globalID = tableSpeech.getRowCount() -1;
    }
    if(globalID < 1){
          globalID = 0;
    }

  }

// ------------------------------------------------------------------------------------

  public void waitUntilTextIsSpoken(){
    while(speaking){
      if(waitForSpeechReturn == 0){
        speaking = false;
      }
    }
  }
  

  private void waitForRobot(){
    while(!isRobotReadyToMove){
      sleepTime(10);
    }
  }


  private void waitForTravers(){
    while(!isTraversReadyToMove){
      sleepTime(2);
    }
  }



}
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
private int flash;
private long frameTimeT;


// ------------------------------------------------------------------------------------

	TraversAnimation(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	public void start () {
    running = true;
    println("Starting thread RobotAnimation (will execute every " + wait + " milliseconds.)");
    isOutOfLoop = true;
    startPositionIsStoredT = false;
    xStartValueT = 0;
    yStartValueT = 0;
    zStartValueT = 0;
    angleT         = 0;
    aVelocityT     = 0.2f;
    frameTimeT = 0;
    movementIDt = 0;
    flash = 0;
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  public void run () {
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
    if(globalID == 131){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(1000,1000,1500,5000);
      waitForTravers();
    }  
  }

  // --- Number 2  Diagnostic---
  if(movementIDt == 2){
    if(globalID == 57){
      robot.sendTraversData(2000,2000,2000,20000);
      waitForTravers();
      robot.sendTraversData(1100,1100,1500,10000);
      waitForTravers();
    }else if(globalID == 132){
      robot.sendTraversData(lastXt,lastYt,2000,5000);
      waitForTravers();
      robot.sendTraversData(2000,2000,2000,5000);
      waitForTravers();
      robot.sendTraversData(1000,1000,2000,5000);
      waitForTravers();
      robot.sendTraversData(1000,1000,0,5000);
      waitForTravers();
      robot.sendTraversData(0,0,0,5000);
      waitForTravers();
      robot.sendTraversData(1000,1500,1000,5000);
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
    if(globalID == 82){
      robot.sendTraversData(1900,1900,1900,5000);
      waitForTravers();
    }else if(globalID == 102 || globalID == 133){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();
    }else if(globalID == 117){
      robot.sendTraversData(400,400,1600,5000);
      waitForTravers();
    }else if(globalID == 134){
      robot.sendTraversData(lastXt,lastYt,300,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(1000,1000,1500,5000);
      waitForTravers();
    }
  }

  // --- Number 5 right to left---  
  if(movementIDt == 5){
    robot.sendTraversData(200,200,1800,5000);
    waitForTravers();

  }

  // --- Number 6 looking backwards---  
  if(movementIDt == 6){
    if(globalID == 90){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(200,200,1800,5000);
      waitForTravers();
    }
    // println(" In animation Nr 6 ");
  }

  // --- Number 7 sighing--- 
  if(movementIDt == 7){
    if(globalID == 114){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();  
    }else{
      robot.sendTraversData(1000,1000,1500,5000);
      waitForTravers();
    }
    // println(" In animation Nr 7 ");
  }

  // --- Number 8 neutral right---  
  if(movementIDt == 8){
    if(globalID == 40){
      robot.sendTraversData(1600,1600,1500,5000);
      waitForTravers();
    }else if(globalID == 72){
      robot.sendTraversData(1900,1900,1600,5000);
      waitForTravers();
    }else if(globalID == 84){
      robot.sendTraversData(1000,1000,1000,5000);
      waitForTravers();
    }else if(globalID == 89){
      robot.sendTraversData(1000,1000,2000,5000);
      waitForTravers();
    }else if(globalID == 112 || globalID == 116 || globalID == 118 || globalID == 71 || globalID == 121 || globalID == 123 ){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
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
    }else if(globalID == 103 || globalID == 126){
    robot.sendTraversData(lastXt,lastYt,lastZt,5000);
    }else if(globalID == 107){
    robot.sendTraversData(1000,1000,1700,5000);
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
    if(globalID == 137){
      robot.sendTraversData(1000,1000,600,5000);
      waitForTravers();
      
    }else{
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();
    }
  }

  // --- swaying --- 
  if(movementIDt == 16){
    if(globalID == 119 || globalID == 127 || globalID == 129){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();  
    }else{
      robot.sendTraversData(1000,1000,800,5000);
      waitForTravers();
    }
   }

  // --- Number 17 powerMove---  
  if(movementIDt == 17){
    robot.sendTraversData(1000,1000,1000,5000);
    waitForTravers();
    while(isInAnimationT){
      flash();
      sleepTime(50);

    }

  }

  // --- Number 18 exhausted---
  if(movementIDt == 18){
    robot.sendTraversData(1000,1000,1600,5000);
    waitForTravers();
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
    while(isInAnimationT){
      if(channelsMindwave[1] != null && channelsMindwave[2] != null){
        if(channelsMindwave[1].points.size() > 0 && channelsMindwave[2].points.size() > 0){
          int attention = (int)channelsMindwave[1].getLatestPointValue();
          int meditation = (int)channelsMindwave[2].getLatestPointValue();
          if (meditation > 0){
            robot.sendTraversData((int)map(meditation, 0, 100, 0, 2000),(int)map(meditation, 0, 100, 0, 2000),(int)map(meditation, 0, 100, 500, 1500), ((-100 + meditation)*30) + 6000);
            waitForTravers();
          }  
        }
        //else{
        //   robot.sendTraversData(0,0,0,8000);
        // }
      }
    }  
  }


  // --- Number 23 kinect ---
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
    while(isInAnimationT){
      if(channelsMindwave[1] != null && channelsMindwave[2] != null){
        if(channelsMindwave[1].points.size() > 0 && channelsMindwave[2].points.size() > 0){
          int attention = channelsMindwave[1].getLatestPointValue();
          int meditation = channelsMindwave[2].getLatestPointValue();
          if (attention > 0){
            robot.sendTraversData((int)map(attention, 0, 100, 2000, 100),(int)map(attention, 0, 100, 2000, 0),(int)map(attention, 0, 100, 500, 1500),((-100 + attention)*30) + 6000);
            waitForTravers();
          }
        }
        // else{
          // robot.sendTraversData(0,0,0,8000);
        // }
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
    }else if(globalID == 120 || globalID == 122 || globalID == 125){
      robot.sendTraversData(lastXt,lastYt,lastZt,5000);
      waitForTravers();
    }else{
      robot.sendTraversData(1700,1700,1600,5000);
      waitForTravers();
    }
  }

  //talking left aroused
  if(movementIDt == 32){
    if (globalID == 104){
      robot.sendTraversData(1700,1700,1700,6000);
      waitForTravers();
    }else if (globalID == 115){
      robot.sendTraversData(1500,1500,1700,6000);
      waitForTravers();
    }else{
      robot.sendTraversData(2000,2000,2000,5000);
      waitForTravers();
    }
  }


  //timed triggeres when technican gets up
  if(movementIDt == 33){
    boolean doneT = false;
    while(!doneT){
      if(robotAnimation.triggerValue == 0){
        robot.sendTraversData(1800,1800,2000,5000);
        waitForTravers();
      }

      if(robotAnimation.triggerValue == 1){
        robot.sendTraversData(0,0,2000,7000);
        waitForTravers();
      }

      if(robotAnimation.triggerValue == 2){
        robot.sendTraversData(300,300,1700,5000);
        waitForTravers();
      }

      if(robotAnimation.triggerValue == 3){
        robot.sendTraversData(300,300,500,3000);
        waitForTravers();
      }

      if(robotAnimation.triggerValue == 4){
        robot.sendTraversData(500,500,2000,4000);
        waitForTravers();
      }

      if(robotAnimation.triggerValue == 5){
        robot.sendTraversData(1000,1000,1800,5000);
        waitForTravers();
      }

      // if(robotAnimation.triggerValue == 6){
      //   robot.sendTraversData(1000,1000,1800,5000);
      //   waitForTravers();
      // }

      if(robotAnimation.triggerValue == 6){
        robot.sendTraversData(1000,1000,1800,5000);
        waitForTravers();
      }

      if(robotAnimation.triggerValue == 7){
        robot.sendTraversData(1000,1000,1800,5000);
        waitForTravers();
      }

       if(robotAnimation.triggerValue == 8){
        robot.sendTraversData(2000,2000,2000,5000);
        waitForTravers();
        doneT = true;
      }
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
      // println("In startposition stored Travers");
      xStartValueT = lastXt;
      yStartValueT = lastYt;
      zStartValueT = lastZt;
      startPositionIsStoredT = true;
      // println("lastXt: " + lastXt + " lastYt: " + lastYt + " lastZt: " + lastZt + " startValueX: " + xStartValueT + "startValueY: " + yStartValueT + "startValueZ: " + zStartValueT);
    }

    if(xT)
      kx = k;
    if(zT)
      kz = k;

    robot.sendTraversData((int)(xStartValueT + kx), (int)(xStartValueT + kx), (int)(zStartValueT + kz), (int)abs(xStartValueT + k)/5 ); 
    waitForTravers();
    // println(abs(xStartValueT + k)*10);
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

  private void flash(){
      flash = (int)random(0, 100);
      if (flash > 50){
        robot.setColor(wLA.port,0,127,127,127);
        robot.setColor(wLB.port,0,127,127,127);
      }else {
        robot.setColor(wLA.port,0,0,0,0);
        robot.setColor(wLB.port,0,0,0,0);
      }  

  }
}  
class WatchDog extends Thread{

boolean running;           // Is the thread running?  Yes or no?
boolean deviceInstanciated;
boolean deviceLost;
String devicePort;
boolean buffer;
boolean isPort;
boolean isFirstContact;
boolean isArduino;
boolean testingLeonardo;
long    heartBeat;
int     bautRate;
int     conValue;
Serial  port;
PApplet p;
int   wait;                  // How many milliseconds should we wait in between executions?
String  id;                 // Thread name
 
// ------------------------------------------------------------------------------------

  // Constructor, create the thread
  // It is not running by default
  WatchDog (int _wait, String _id, String _devicePort, boolean _buffer, boolean _isPort, int _bautRate, boolean _isArduino, boolean _testingLeonardo, PApplet _p) {
    wait = _wait;
    p = _p;
    running = false;
    deviceInstanciated = false;
    deviceLost = false;
    devicePort = _devicePort;
    buffer = _buffer;
    isPort = _isPort;
    bautRate = _bautRate;
    isArduino =_isArduino;
    testingLeonardo = _testingLeonardo;
    id = _id;
    conValue = 255;
  }

// ------------------------------------------------------------------------------------
 
  // Overriding "start()"
  public void start () {
    running = true;
    println("Starting thread (will execute every " + wait + " milliseconds.)");
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  public void run () {
    // sleep(2000);
    println(id + " " + conValue);
    deviceInit();
    sleep(300);
    while (running) {
      check();
      checkHeartBeat();
      sleep(wait);
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------
 
  public void check(){

    if (!deviceInstanciated){
      sleep(3000);
      deviceInit();
      // println("deviceInstanciated not true: " + id);
    }else if(deviceInstanciated && deviceLost){
      sleep(3000);
      port.stop();
      // checkIfLeonardo();
      deviceInit();
      // println("deviceLost and new Init: " + id);
    }

  }

// ------------------------------------------------------------------------------------
 
  // Our method that quits the thread
  public void quit() {
    System.out.println("Quitting.");
    running = false;  // Setting running to false ends the loop in run()
    port.stop();
    // IUn case the thread is waiting. . .
    interrupt();
  }

// ------------------------------------------------------------------------------------

  public void sleep(int sleepTime){
  try {
      sleep((long)(sleepTime));
    } catch (Exception e) {
    }

  }

// ------------------------------------------------------------------------------------

  public void checkHeartBeat(){
  if(id.equals("PulseMeter")){
    if(millis() -  heartBeat >= 6000 && deviceInstanciated){
      println(id + " heartBeat lost");
      deviceLost = true;
    }
  }else if (isArduino){
    if (isFirstContact){
        if (millis() -  heartBeat >= 6000 && deviceInstanciated){
            isFirstContact = false;
            deviceLost = true;
            // testingLeonardo = true;
            println(id + " heartBeat lost");
            conValue = 100;
        }
      }
  }
  }

// ------------------------------------------------------------------------------------  

  public void deviceInit() {
  // println("In Init: " + id);
    if(isPort){ 
      // println("In is Port: " + id );
      try {
        port = new Serial(p, devicePort, bautRate);
        port.clear();
        if(buffer){
          port.bufferUntil(end);
        }
        deviceInstanciated = true;
        deviceLost = false;
        // testingLeonardo = false;
        // println("In try"); 
        if(isArduino){
         // println("In first Contact"); 
        isFirstContact = false;
        }
      } 
      catch (Exception e) {
        // println(e);
        deviceInstanciated = false;
        deviceLost = true;
        // println(id + " port received an exepction: " + e);
      }
    } 
  }

  // void checkIfLeonardo(){
  //   try {
  //     if(testingLeonardo){
  //       port = new Serial(p, devicePort, 1200);
  //       port.clear();
  //       port.stop();
  //       testingLeonardo = false;
  //     }
  //   } catch (Exception e) {
  //     println(" " + id + " " + e);
  //   }
    
  // }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "RobotControlPro" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
