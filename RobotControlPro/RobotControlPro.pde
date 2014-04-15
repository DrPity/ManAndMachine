import controlP5.*;
import org.json.*; 
import processing.net.*;
import processing.serial.*;
import java.awt.Frame;
import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GLCapabilities;
import javax.media.opengl.GLContext;
import javax.media.opengl.GLEventListener;
import javax.media.opengl.GLProfile;
import javax.media.opengl.awt.GLCanvas;
import processing.core.PGraphics;
import processing.opengl.PGL;
import processing.opengl.PGraphicsOpenGL;
import processing.opengl.Texture;

private int[]   bitArray            = new int[8];
private int     lastPulseBit        = 0;
private int     counter             = 0;
private int     heartRate           = 0;
private int     end                 = 10;
private int     pulsMeterConValue   = 200;
private int     robotConValue       = 200;
private int     pose                = 1;
private int     gAngle              = 90;
private int     debugVariable       = 0;
private int     z                   = 120;
private int     gGripperWidth       = 0;
private int     bioValue            = 0;
private int     speed               = 0;
private int     recordColor         = color(127, 127, 127);
private int     id                  = 0;
private int     packetCount         = 0;
private int     globalMax;
private int     tableIndex          = 0;
private byte    caReturn            = 13;
private long    heartbeat;
private String  pulseString        = "";
private String  heartRateString    = "NA";
private String  inChar;
private String  scaleMode;
private String  pulseMeterPort      = "/dev/tty.BerryMed-SerialPort";
private String  arduinoPort         = "/dev/tty.usbmodem1421";
private float   angle               = 0;
private float   aVelocity           = 0.05;
private boolean isRobotReadyToMove  = false;
private boolean isFirstContact      = false;
private boolean isHashtrue          = false;
private boolean isRobotStarted      = false;
private boolean isDataVerified      = false;
private boolean isRecording         = false;
private boolean isEsenseEvent       = false;
private boolean isReadyToRecord     = false;
private boolean gridYisDrawn        = false;
private boolean gridXisDrawn        = false;
private boolean isArduinoPort       = false;
private boolean isPulseMeterPort    = false;
private boolean isDataToGraph       = false;
private boolean isTimerStarted      = false;


/* Static Robot Values used for Inverse Kinematic */
/* Arm dimensions( mm ) */

private static final Float  BASE_HEIGHT  = 101.0;   //height of robot-base"
private static final Float  SHL_ELB      = 105.0;   //shoulder-to-elbow
private static final Float  ULNA         = 98.0;    //elbow-to-wrist
private static final Float  GRIPLENGTH   = 155.0;   //lengh-of-grip
private static final Float  WRIST_OFFSET = 28.0;    //offset wrist-gripper

/* Constrains of servo motors in milliseconds */
private static final Integer  BASE_MAX            = 2300;
private static final Integer  BASE_MIN            = 720;
private static final Integer  SHOULDER_MAX        = 2350; 
private static final Integer  SHOULDER_MIN        = 720; 
private static final Integer  ELBOW_MAX           = 2370; 
private static final Integer  ELBOW_MIN           = 720;
private static final Integer  WRIST_MAX           = 2370; 
private static final Integer  WRIST_MIN           = 720;
private static final Integer  GRIPPER_ANGLE_MAX   = 2400;
private static final Integer  GRIPPER_ANGLE_MIN   = 700;
private static final Integer  GRIPPER_MAX         = 2100;
private static final Integer  GRIPPER_MIN         = 1450;  

/* Dynamic values of the robot arm */
private int     currentBase             = 00;
private int     currentShoulder         = 00;
private int     currentElbow            = 00;
private int     currentWrist            = 00;
private int     currentGripperAngle     = 00;
private int     currentGripperWidth     = 00;
private int     currentLight            = 00;
private int     currentEasing           = 00;

PImage bg;
Table table;
ControlFont font;
Client myClient;
Drawings drawings;
ControlP5 controlP5;
Serial pulseMeter, myPort;
Kinect kinect;
HelperClass helpers;
ManageCLE mindWaveCLE;
ManageSE manageSE;
Robot robot;

Channel[] channels = new Channel[11];
Graph mindWave, emg, ecg, eda;
Textlabel lableHeartRate, textHeartRate, timerLable, lableID, textID, fRate;
ConnectionLight connectionLight, bluetoothConnection, robotConnection;


void setup() {

  frameRate(60);
	size(displayWidth, displayHeight, P2D);
  noSmooth();
  // bg = loadImage("brain.png");
  // bg.resize(width, height);
  smooth(4);

  manageSE  = new ManageSE();
  robot = new Robot();
	
	// Set up the knobs and dials
	controlP5 = new ControlP5(this);
	controlP5.setColorLabel(color(0));
	controlP5.setColorBackground(color(127));

	for (int i = 0; i < Serial.list().length; i++) {
    println("[" + i + "] " + Serial.list()[i]);

    // Flag serial ports as true
    if(Serial.list()[i].equals(pulseMeterPort)){
      isPulseMeterPort = true;
    }else if (Serial.list()[i].equals(arduinoPort)){
      isArduinoPort = true;
    }
  }

  if(isPulseMeterPort){
    // if(Serial.list()[i].available() > 0){
    try {
      pulseMeter = new Serial(this, pulseMeterPort, 115200);
      pulseMeter.clear();
      
    } catch (Exception e) {
      isPulseMeterPort = false;
      println("PulseMeter port received an exepction: " + e);
    }
   
  }else println("PulseMeter not available");
  
  if(isArduinoPort){
    myPort = new Serial(this, arduinoPort, 115200);
    myPort.bufferUntil(end);
    myPort.clear();
  }else println("Arduino not available");

  helpers = new HelperClass();
  drawings = new Drawings();
  mindWaveCLE = new ManageCLE();
  drawings.CP5Init();
  // mindWaveCLE.thingearInit();

	font = new ControlFont(createFont("DIN-MediumAlternate", 12), 12);
  mindWaveCLE.connectToMindWave(this);
       
	// Creat the channel objects
	// yellow to purple and then the space in between, grays for the alphas
	channels[0]  = new Channel("Signal Quality", color(0), "");
	channels[1]  = new Channel("Attention", color(100), "");
	channels[2]  = new Channel("Meditation", color(50), "");
	channels[3]  = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep");
	channels[4]  = new Channel("Theta", color(245, 80, 71), "Drowsy");
	channels[5]  = new Channel("Low Alpha", color(237, 0, 119), "Relaxed");
	channels[6]  = new Channel("High Alpha", color(212, 0, 149), "Relaxed");
	channels[7]  = new Channel("Low Beta", color(158, 18, 188), "Alert");
	channels[8]  = new Channel("High Beta", color(116, 23, 190), "Alert");
	channels[9]  = new Channel("Low Gamma", color(39, 25, 159), "???");
	channels[10] = new Channel("High Gamma", color(23, 26, 153), "???");
	
	// Manual override for a couple of limits.
	channels[0].minValue = 0;
	channels[0].maxValue = 200;
	channels[1].minValue = 0;
	channels[1].maxValue = 100;
	channels[2].minValue = 0;
	channels[2].maxValue = 100;
	channels[0].allowGlobal = false;
	channels[1].allowGlobal = false;
	channels[2].allowGlobal = false;
	
	// Set up the graph
	mindWave = new Graph(0, 0, width, round(height * 0.10));
  emg = new Graph(0, round(height * 0.10), width, round(height * 0.10));
  eda = new Graph(0, round(height * 0.20), width, round(height * 0.10));
  ecg = new Graph(0, round(height * 0.30), width, round(height * 0.10));
	
	connectionLight     = new ConnectionLight(width - 98, 10, 10);
  bluetoothConnection = new ConnectionLight(width - 98, 30, 10);
  robotConnection     = new ConnectionLight(width - 98, 50, 10);
  

	globalMax = 0;
  isReadyToRecord = true;
  inChar = null;
  // kinect = addControlFrame("extra", 320,240);
    
}

void draw() {
  
  background(200);
  drawings.drawRectangle(0,0,width,round(height * 0.40),0,0,255,150); 
  lableHeartRate.setValue(heartRateString);
  fRate.setValue(Float.toString(frameRate));
  // lableID.setValue(String.valueOf(id));

	// mindWave.update();
	mindWave.draw();
  mindWave.drawGrid();
  // emg.update();
  emg.draw();
  // // ecg.update();
  ecg.draw();
  // // eda.update();
  eda.draw();
  drawings.drawLine(0,round(mindWave.y + (height * 0.10)), width, round(mindWave.y + (height * 0.10)));
  drawings.drawLine(0,round(emg.y + (height * 0.10)), width, round(emg.y + (height * 0.10)));
  drawings.drawLine(0,round(ecg.y + (height * 0.10)), width, round(ecg.y + (height * 0.10)));
  drawings.drawLine(0,round(eda.y + (height * 0.10)), width, round(eda.y + (height * 0.10)));
  noStroke();
  drawings.drawRectangle(10,10,195,300,0,0,255,150);  
  drawings.drawRectangle(0, 0, 88, 58, width - 98, 10, 255, 150);
	connectionLight.update(channels[0].getLatestPoint().value);
	connectionLight.draw();
  connectionLight.mindWave.draw();
  bluetoothConnection.update(pulsMeterConValue);
  bluetoothConnection.draw();
  bluetoothConnection.pulseMeter.draw();
  robotConnection.update(robotConValue);
  robotConnection.draw();
  robotConnection.robot.draw();


  if (isFirstContact){
    if (millis() - heartbeat >= 5000){
       isFirstContact = false; 
       println("Heartbeat lost");
       robotConValue = 100;
    }
  }
  

  if (!isRobotStarted){

    if(true){

      float amplitude = 100;
      float x = amplitude * cos(angle);
      angle += aVelocity;
      calculateBioInput();

      if (debugVariable > 0 && debugVariable <= 100){
        gAngle = (int) map(debugVariable, 0, 100, 90, 00);
        z = (int) map (debugVariable,0, 100, 120, 250);
        gGripperWidth = (int) map(debugVariable, 0, 100, 0, 180);
        speed = (int) map(debugVariable, 0, 100, 0, 255);
      }
    
      robot.setRobotArm(x, 130, z, gAngle, gGripperWidth, speed, 5);
      // println("Robot Movement");
    }
  }

  if(isTimerStarted)
    timerLable.setValue(String.valueOf(second()));

  gridYisDrawn = false;
  gridXisDrawn = false;

}

void clientEvent(Client  myClient) {

  
	if (myClient.available() > 0) {
  
    byte[] inBuffer = myClient.readBytesUntil(caReturn);
    
    if (inBuffer != null){
    	String data = new String(inBuffer);
    	// print(data);
      mindWaveCLE.mindWave(data);

	  }
	}

}


void serialEvent(Serial thisPort){


  if (thisPort == pulseMeter && isPulseMeterPort){
    
    counter++;

     while (pulseMeter.available() > 0) {
      // Expand array size to the number of bytes you expect:
      int inByte = pulseMeter.read();
      for (int i = 7; i >= 0; i--){ 
        bitArray[i] = manageSE.bitRead(inByte, i);
      }
    }
    manageSE.newPulse();
  }

  if (thisPort == myPort && isArduinoPort){
    
    while (myPort.available() > 0){
      inChar = myPort.readStringUntil(end);
    }
    if (inChar != null) {

      manageSE.arduino(inChar);

    }
  }
}


public void Start_Recording() {
  if(isReadyToRecord){
    helpers.BeginRecording();
  }
}

public void Stop_Recording() {
  if(isReadyToRecord){
    helpers.EndRecording();
  }
}

public void Start_Robot() {
  isRobotStarted = !isRobotStarted;
  println("robot started");
  //isTimerStarted = !isTimerStarted;
}



void keyPressed(){

   if (key == CODED){
      if (keyCode == LEFT){
        // setRobotArm(-100, 80, 50, 90, 180, 127);
      }
      if (keyCode == RIGHT){
        // setRobotArm(100, 80, 10, 90, 180, 127);
      }
      if (keyCode == UP){
        debugVariable += 2;

      }
      if (keyCode == DOWN){
        debugVariable -= 2;
      }
    }

    println("Debug Variable : " + debugVariable);
}


  int bitRead(int b, int bitPos)
{
  int x = b & (1 << bitPos);
  return x == 0 ? 0 : 1;
}

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




void calculateBioInput(){


  bioValue = ((100 - channels[2].getLatestPoint().value) + (heartRate - 60))/2;
  // println("Bio Value:" + bioValue + " " + channels[2].getLatestPoint().value + " " + heartRate );


}