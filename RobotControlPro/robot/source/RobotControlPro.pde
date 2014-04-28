import controlP5.*;
import org.json.*; 
import processing.net.*;
import processing.serial.*;
import java.awt.Frame;

private int     end                 = 10;
private int     pose                = 1;
private int     gAngle              = 90;
private int     debugVariable       = 0;
private int     z                   = 120;
private int     gGripperWidth       = 0;
private int     bioValue            = 0;
private int     globalID            = 0;
private int     speed               = 0;
private int     recordColor         = color(127, 127, 127);
private int     id                  = 0;
private int     storingID           = 0;
private int     packetCount         = 0;
private int     globalMax;
private int     tableIndex          = 0;
private int     tableIndexStoring   = 0;
private int     receivedHeartRate   = 0;
private int     voice               = 0;
private byte    caReturn            = 13;
private String  heartRateString    = "NA";
private String  inCharA;
private String  inCharM;
private String  scaleMode;
private String  arduinoPort         = "/dev/tty.usbmodem1421";
private String  melziPort           = "/dev/tty.usbserial-AH01SIVE";
private String  pulseMeterPort      = "/dev/tty.BerryMed-SerialPort";
private float   angle               = 0;
private float   aVelocity           = 0.05;
private boolean isRobotReadyToMove  = false;
private boolean isTraversReadyToMove  = false;
private boolean isFirstContact      = false;
private boolean isRobotStarted      = false;
private boolean isRecording         = false;
private boolean isStoring           = false;
private boolean isEsenseEvent       = false;
private boolean isReadyToRecord     = false;
private boolean isReadyToStore      = true;
private boolean gridYisDrawn        = false;
private boolean gridXisDrawn        = false;
private boolean isArduinoPort       = false;
private boolean isMelziPort         = false;
private boolean isPulseMeterPort    = false;
private boolean isDataToGraph       = false;
private boolean isTimerStarted      = false;
private boolean isTableSpeechLoaded = false;
private boolean isReadyForButtonCommands = false;
private boolean newSay              = false;
private boolean newPosition         = false;
private boolean nextStep            = false;

// ------------------------------------------------------------------------------------
// Println console;
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
Robot robot;

Channel[] channels = new Channel[11];
Graph mindWave, emg, ecg, eda;
Textlabel lableHeartRate, textHeartRate, timerLable, lableID, textID, fRate, headlineText_1, headlineText_2;
ConnectionLight connectionLight, bluetoothConnection, robotConnection, traversConnection;

// ------------------------------------------------------------------------------------

void setup() {
  frameRate(120);
	size(displayWidth, displayHeight,P2D);
  // size(1280,720,P2D);
  noSmooth();
  hint(ENABLE_RETINA_PIXELS);
  // bg = loadImage("brain.png");
  // bg.resize(width, height);
  // background(bg);
  smooth(4);
  helpers = new HelperClass();
  manageSE  = new ManageSE();
  robot = new Robot();
  robot.loadRobotData();
  helpers.checkSerialPorts();

  // WachtDog: SleepTime Thread, NameDevice, Port, Buffering, initOK?, BautRate, isTypArduino, PApplet 
  wPm = new WatchDog(1,"PulseMeter", pulseMeterPort, false, isPulseMeterPort, 115200, false, this);
  wPm.start();
  wA = new WatchDog(1,"Arduino", arduinoPort, true, isArduinoPort, 115200, true, this);
  wA.start();
  wM = new WatchDog(1,"Melzi", melziPort, true, isMelziPort, 115200, true, this);
  wM.start();

  //active textToSpeech Thread
  textToSpeech = new TextToSpeech(1);
  textToSpeech.start();

 

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
  lableHeartRate.setValue(heartRateString);
  drawings.drawRectangle(0,0,width,round(height*0.40),0,0,255,150);
  
  lableID.setValue(String.valueOf(globalID));
	

  mindWave.draw();
  mindWave.drawGrid();
  emg.draw();
  ecg.draw();
  eda.draw();
  drawings.drawLine(0,round(mindWave.y + (height * 0.10)), width, round(mindWave.y + (height * 0.10)),2);
  drawings.drawLine(0,round(emg.y + (height * 0.10)), width, round(emg.y + (height * 0.10)),2);
  drawings.drawLine(0,round(ecg.y + (height * 0.10)), width, round(ecg.y + (height * 0.10)),2);
  drawings.drawLine(0,round(eda.y + (height * 0.10)), width, round(eda.y + (height * 0.10)),2);
  drawings.drawLine(20,round(height * 0.44), 210, round(height * 0.44),1);
  noStroke();
  drawings.drawRectangle(10,10,195,300,0,0,255,150);
  drawings.drawRectangle(10, round(height * 0.408) ,360,300,0,0,255,150);  
  drawings.drawRectangle(0, 0, 88, 58, width - 98, 10, 255, 150);
	connectionLight.update(channels[0].getLatestPoint().value);
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

    if((frameCount%10)==0){

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
    
      robot.setRobotArm(x, 130, z, gAngle, gGripperWidth, speed, 1, true);
      println("Robot Movement");
    }
  }

  if(isTimerStarted)
    timerLable.setValue(String.valueOf(second()));

  gridYisDrawn = false;
  gridXisDrawn = false;

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
      
      voice = Integer.parseInt(theEvent.getStringValue());

      // if(isStoring){

      //   String[] s = split(theEvent.getStringValue(), ',');
      //   helpers.storePositionToTable(Integer.parseInt(s[1]),
      //                               Integer.parseInt(s[2]), 
      //                               Integer.parseInt(s[3]), 
      //                               Integer.parseInt(s[4]), 
      //                               Integer.parseInt(s[5]), 
      //                               Integer.parseInt(s[6]), 
      //                               Integer.parseInt(s[7]), 
      //                               Integer.parseInt(s[8]), 
      //                               Integer.parseInt(s[9]), 
      //                               Integer.parseInt(s[10]), 
      //                               Integer.parseInt(s[11]), 
      //                               Integer.parseInt(s[12]), 
      //                               Integer.parseInt(s[13]));

      // }

      if(theEvent.getStringValue().equals("NewTable") && isReadyToStore){
         println("New Table Created");
         // helpers.newStorePositionTable();
      }
    }

    if(theEvent.getName().equals("Reset_Robot")){
      println("reset robot event ");
      robot.setRobotArm( 0, 150, 80, 90, 90, 254, 200, true); 
    }

    if(theEvent.getName().equals("saveBtn")){
      println("save button event");
    }

    if(theEvent.getName().equals("loadBtnDefault")){
      println("load default button");
      // tableRm = loadTable("data/RobotMovements.csv");
    }

    if(theEvent.getName().equals("loadBtnLastPosition")){
      println("load last Position");
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
      if(!nextStep){
        nextStep = true;
        globalID --;
      }
    }

    if(theEvent.getName().equals("Forward")){
      if(!nextStep){
        nextStep = true;
        globalID ++;
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
        robot.setRobotArm(0, yy, 80, 45, 90, 255, 200, true);
        println("+ IsStRun: +" + isStrRun); 
      }
      if (keyCode == RIGHT){
        int yy = robot.stretching(50);
        println("( streched Position in keyPressed Right: )"  + yy);
        robot.setRobotArm(0, yy , 80, 45, 90, 255, 200, true);
        println("+ IsStRun: +" + isStrRun); 
      }
      if (keyCode == UP){
        // robot.setRobotArm(0, debugVariable, 80, 45, 90, 255, 200, true);
        debugVariable += 2;

      }
      if (keyCode == DOWN){
        // robot.setRobotArm(0, debugVariable, 80, 45, 90, 255, 200, true);
        debugVariable -= 2;
      }
    }

    // println("Debug Variable : " + debugVariable);
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
  bioValue = ((100 - channels[2].getLatestPoint().value) + (100 - 60))/2;
  // println("Bio Value:" + bioValue + " " + channels[2].getLatestPoint().value + " " + heartRate );


}

 boolean sketchFullScreen() {
  return true;
  }
