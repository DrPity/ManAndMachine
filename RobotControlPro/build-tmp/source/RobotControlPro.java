import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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
private float   aVelocity           = 0.05f;
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


public void setup() {

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
	mindWave = new Graph(0, 0, width, round(height * 0.10f));
  emg = new Graph(0, round(height * 0.10f), width, round(height * 0.10f));
  eda = new Graph(0, round(height * 0.20f), width, round(height * 0.10f));
  ecg = new Graph(0, round(height * 0.30f), width, round(height * 0.10f));
	
	connectionLight     = new ConnectionLight(width - 98, 10, 10);
  bluetoothConnection = new ConnectionLight(width - 98, 30, 10);
  robotConnection     = new ConnectionLight(width - 98, 50, 10);
  

	globalMax = 0;
  isReadyToRecord = true;
  inChar = null;
  // kinect = addControlFrame("extra", 320,240);
    
}

public void draw() {
  
  background(200);
  drawings.drawRectangle(0,0,width,round(height * 0.40f),0,0,255,150); 
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
  drawings.drawLine(0,round(mindWave.y + (height * 0.10f)), width, round(mindWave.y + (height * 0.10f)));
  drawings.drawLine(0,round(emg.y + (height * 0.10f)), width, round(emg.y + (height * 0.10f)));
  drawings.drawLine(0,round(ecg.y + (height * 0.10f)), width, round(ecg.y + (height * 0.10f)));
  drawings.drawLine(0,round(eda.y + (height * 0.10f)), width, round(eda.y + (height * 0.10f)));
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

public void clientEvent(Client  myClient) {

  
	if (myClient.available() > 0) {
  
    byte[] inBuffer = myClient.readBytesUntil(caReturn);
    
    if (inBuffer != null){
    	String data = new String(inBuffer);
    	// print(data);
      mindWaveCLE.mindWave(data);

	  }
	}

}


public void serialEvent(Serial thisPort){


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



public void keyPressed(){

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


  public int bitRead(int b, int bitPos)
{
  int x = b & (1 << bitPos);
  return x == 0 ? 0 : 1;
}

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
  return p;
}




public void calculateBioInput(){


  bioValue = ((100 - channels[2].getLatestPoint().value) + (heartRate - 60))/2;
  // println("Bio Value:" + bioValue + " " + channels[2].getLatestPoint().value + " " + heartRate );


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
		


	Channel(String _name, int _drawColor, String _description) {
		name = _name;
		drawColor = _drawColor;
		description = _description;
		allowGlobal = true;
		points = new ArrayList();
	}
	
	
	public void addDataPoint(int value) {
		
		long time = System.currentTimeMillis();
		
		if(value > maxValue) maxValue = value;
		if(value < minValue) minValue = value;
		
		points.add(new Point(time, value));
		
		// tk max length handling
	}
	
	public Point getLatestPoint() {
		if(points.size() > 0) {
			return (Point)points.get(points.size() - 1);
		}
		else {
			return new Point(0, 0);
		}
	}


}
class ConnectionLight {
	int x, y;
	int currentColor = 0;
	int goodColor = color(0, 255, 0);
	int badColor = color(255, 255, 0);
	int noColor = color(255, 0, 0);
	int diameter;
	int latestConnectionValue;
	Textlabel mindWave;
	Textlabel pulseMeter;
	Textlabel robot;
	PShape circle;
	
	

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
	}
	
	public void update( int value) {
		latestConnectionValue = value;
		if(latestConnectionValue == 200) currentColor = noColor;
		if(latestConnectionValue < 200) currentColor = badColor;
		if(latestConnectionValue == 00) currentColor = goodColor;
	}
	
	public void draw() {
		
		
		pushMatrix();
		translate(x, y);
		
		// fill(255, 150);
		// rect(0, 0, 88, 28);
		
		
		// fill(currentColor);
		// ellipseMode(CORNER);
		circle.setFill(currentColor);
		shape(circle);
		//ellipse(5, 4, diameter, diameter);
				
		popMatrix();

	
	}

}
class Drawings  {


  public void drawLine(int x1, int y1, int x2, int y2){
    
    pushMatrix();
    stroke(0);
    strokeWeight(2);  // Thicker
    line(x1, y1, x2, y2);
    popMatrix();
  }

  public void drawRectangle(int x1, int y1, int x2, int y2, int tx, int ty, int f, int fa){
    pushMatrix();
    translate(tx,ty);
    fill(f, fa);
    rect(x1, y1, x2, y2);
    popMatrix();
  }

  public void Draw_Elipse(int x, int y, int dx, int dy){
    fill(recordColor);
    ellipseMode(CORNER);
    ellipse(x, y, dx, dy);

  }

  public void CP5Init(){

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
  
  controlP5.addButton("Start_Robot")
     .setValue(0)
     .setPosition(30,500)
     .setSize(100,20)
     ;

  lableHeartRate = controlP5.addTextlabel("lable")
                    .setText(heartRateString)
                    .setPosition(10,160)
                    .setColorValue(255)
                    .setFont(createFont("Helvetica",100));
  textHeartRate = controlP5.addTextlabel("label2")
                  .setText("Heart Rate")
                  .setPosition(15,260)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",16));


  timerLable = controlP5.addTextlabel("lable2")
                  .setText("00.00")
                  .setPosition(10,20)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",50))
                  ;


  fRate = controlP5.addTextlabel("lable3")
                  .setText("00")
                  .setPosition(10,height - 70)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",12))
                  ;



     // lableID = controlP5.addTextlabel("lable3")
   //                .setText("id")
   //                .setPosition(250,100)
   //                .setColorValue(255)
   //                .setFont(createFont("Helvetica",100))
   //                ;
   // textID = controlP5.addTextlabel("label4")
   //                .setText("ID")
   //                .setPosition(270,200)
   //                .setColorValue(255)
   //                .setFont(createFont("Helvetica",16))
   //                ;                     


  }






}



class Graph {
	int x, y, w, h, pixelsPerSecond, gridColor, gridX, originalW, originalX;
	long leftTime, rightTime, gridTime;
	boolean scrollGrid;
	String renderMode;
	float gridSeconds;
	Slider pixelSecondsSlider;
	RadioButton renderModeRadio;
	RadioButton scaleRadio;



	Graph(int _x, int _y, int _w, int _h) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		pixelsPerSecond = 10;
		gridColor = color(0);
		gridSeconds = 1; // seconds per grid line
		scrollGrid = false;



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
	
	public void update() {
	}
	
	public void draw() {
		
		

		
		//pixelsPerSecond = round(pixelSecondsSlider.value());
		renderMode = "Lines";
		

		w = originalW;
		x = originalX;

		w += (pixelsPerSecond * 2);
		x -= pixelsPerSecond;

		
		// Figure out the left and right time bounds of the graph, based on
		// the pixels per second value
		rightTime = System.currentTimeMillis();
		leftTime = rightTime - ((w / pixelsPerSecond) * 1000);
		
		if(isDataToGraph){

			pushMatrix();
			translate(x, y);
			
		
			
			// Draw each channel (pass in as constructor arg?)

			noFill();				
			// if(renderMode == "Shaded" || renderMode == "Triangles") noStroke();		
			if(renderMode == "Lines") strokeWeight(1.5f);
			
			for (int i = 0; i < channels.length; i++) {
				Channel thisChannel = channels[i];
				
				if(thisChannel.graphMe) {
				
					//Draw the line
					if(renderMode == "Lines") stroke(thisChannel.drawColor);

					// if(renderMode == "Shaded" || renderMode == "Triangles") {
					// 	noStroke();
					// 	fill(thisChannel.drawColor, 120);
					// }
				
					// if(renderMode == "Triangles") {
					// 	beginShape(TRIANGLES);
					// }
					// else {
						beginShape();			
					// }

					// if(renderMode == "Curves" || renderMode == "Shaded") vertex(0, h);
				
				
					for (int j = 0; j < thisChannel.points.size(); j++) {
						Point thisPoint = (Point)thisChannel.points.get(j);
							
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
					
							// if(renderMode == "Curves") {
							// 	curveVertex(pointX, pointY);					
							// }
							// else {
								vertex(pointX, pointY);
							// }				
						}
					}
				}
				
				// if(renderMode == "Curves" || renderMode == "Shaded") vertex(w, h);
				if(renderMode == "Lines") endShape();
				// if(renderMode == "Shaded") endShape(CLOSE);
			}
			


			
			popMatrix();
			
			
			// gui matte
			noStroke();
			// fill(255, 150);
			// rect(10, 10, 195, 300);

		}

	}

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
				line(gridX, 0, gridX, round(height * 0.40f));
				gridTime -= (long)(1000 * gridSeconds);
			}
		gridXisDrawn = true;
		}

		strokeWeight(0.6f);
		stroke(127,80);
		//Draw square horizontal grid for now
		if(!gridYisDrawn){
			// println("Drawing GridY");
			int gridY = round(height * 0.40f);
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

  public void BeginRecording() {
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

  public void EndRecording() {
    if(isReadyToRecord){
      println("a button event from Stop_Recording: ");
      saveTable(table, String.format("data/recording_%d.csv", tableIndex), "csv");
      println("isRecording Stoped!!");
      tableIndex ++;
      isRecording = false;
      recordColor = color(127, 127, 127);
    }
  }
  
    // Extend core's Map function to the Long datatype.
  public long mapLong(long x, long in_min, long in_max, long out_min, long out_max)  { 
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min; 
  }

  public long constrainLong(long value, long min_value, long max_value) {
    if(value > max_value) return max_value;
    if(value < min_value) return min_value;
    return value;
  }
	
}




public class Kinect extends PApplet{

SimpleOpenNI  context;

int w, h;

int abc = 100;

  public void setup()
  {


    context = new SimpleOpenNI(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
     if(context.isInit() == false)
    {
       println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
       exit();
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
   
  // draws a circle at the position of the head
  public void circleForAHead(int userId)
  {
    // get 3D position of a joint
    PVector jointPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,jointPos);


    println("X: " + jointPos.x + " Y:" + jointPos.y + " Z: " + jointPos.z);

   
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

    //println("X: " + jointPos_Proj.x + " Y: " + jointPos_Proj.y + " Z: " + jointPos_Proj.z);
  }


   
  // when a person ('user') enters the field of view
  public void onNewUser(SimpleOpenNI curContext,int userId)
  {
    println("New User Detected - userId: " + userId);
   
   // start pose detection
    curContext.startTrackingSkeleton(userId);
  }  
   
  // when a person ('user') leaves the field of view 
  public void onLostUser(int userId)
  {
    println("User Lost - userId: " + userId);
  }


  public Kinect(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return controlP5;
  }



  // ControlP5 controlP5;

  Object parent;
  
}

 

class ManageCLE {

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
	
	public void mindWave(String data) {
		

	// Sample JSON data:
  	// {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}

		try {
        org.json.JSONObject json = new org.json.JSONObject(data);
        channels[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));
      	}
      	catch (JSONException e) {
      	// println(e); 	
      	}   
      

      	try{
      		org.json.JSONObject json = new org.json.JSONObject(data);   
        	org.json.JSONObject esense = json.getJSONObject("eSense");
        	if (esense != null) {
          	channels[1].addDataPoint(Integer.parseInt(esense.getString("attention")));
          	channels[2].addDataPoint(Integer.parseInt(esense.getString("meditation")));
          	// print(channels[1].getLatestPoint().value);
          	isEsenseEvent = true;
        }
        
        org.json.JSONObject eegPower = json.getJSONObject("eegPower");
        
        if (eegPower != null) {
          channels[3].addDataPoint(Integer.parseInt(eegPower.getString("delta")));
          channels[4].addDataPoint(Integer.parseInt(eegPower.getString("theta"))); 
          channels[5].addDataPoint(Integer.parseInt(eegPower.getString("lowAlpha")));
          channels[6].addDataPoint(Integer.parseInt(eegPower.getString("highAlpha")));  
          channels[7].addDataPoint(Integer.parseInt(eegPower.getString("lowBeta")));
          channels[8].addDataPoint(Integer.parseInt(eegPower.getString("highBeta")));
          channels[9].addDataPoint(Integer.parseInt(eegPower.getString("lowGamma")));
          channels[10].addDataPoint(Integer.parseInt(eegPower.getString("highGamma")));

         	if (isRecording){
  			TableRow newRow = table.addRow();
  			newRow.setInt("ID", table.getRowCount() -1);
         	newRow.setInt("Heart_Rate", heartRate);
  			newRow.setInt("attention", channels[1].getLatestPoint().value);
  			newRow.setInt("meditation", channels[2].getLatestPoint().value);
  			newRow.setInt("delta", channels[3].getLatestPoint().value);
  			newRow.setInt("theta", channels[4].getLatestPoint().value);
  			newRow.setInt("lowAlpha", channels[5].getLatestPoint().value);
  			newRow.setInt("highAlpha", channels[6].getLatestPoint().value);
  			newRow.setInt("lowBeta", channels[7].getLatestPoint().value);
  			newRow.setInt("highBeta", channels[8].getLatestPoint().value);
  			newRow.setInt("lowGamma", channels[9].getLatestPoint().value);
  			newRow.setInt("highGamma", channels[10].getLatestPoint().value);
  			newRow.setInt("timestamp", millis());
          	id =  table.getRowCount() -1;
          	// println("Packeg");
  		  	}

         isDataToGraph = true; 
       	}
        
       	 packetCount++;
         for (int i = 0; i < 11; ++i) {
          channels[i].graphMe = true; 
         }
       
  	  }
  	  
  	  catch (JSONException e) {
  	    // println ("There was an error parsing the JSONObject." + e);
  	  };
	}

}
class ManageSE {

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
      myPort.write("W");
      myPort.write(10);
      // println("+ Heartbeat +");
      if(robotConValue != 00){
        robotConValue = 00;
      }
      heartbeat = millis();
      // serialConnection = "Connected";
    }

    if(inChar.trim().equals("N")){
      isRobotReadyToMove = true;
     // println("Robot Ready for Next Position");
    }

    if(!isFirstContact){
      // println("In first contact");
      if (inChar.trim().equals("A")) {
        // serialConnection = "Connected";
        println("Connected");
        isFirstContact = true;
        isRobotReadyToMove = true;
        delay(200);                     
        myPort.write("B");
        myPort.write(10);        
      }  
    } 
    else if(inChar.trim().equals("#")){
        isHashtrue = true;
    }
  
    
  
  }

  public void newPulse(){
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
        // println(heartRate);
        heartRateString = String.valueOf(heartRate);
        pulseString = "";
        bitArray[7] = 0;
        if (pulsMeterConValue <= 200){
          pulsMeterConValue = 00;
        }
        if(PApplet.parseInt(heartRateString) == 255){
          pulsMeterConValue = 100;
        }
      }

      // Check for synch bit
     if (bitArray[7] == 1){
      counter = 0;
      }

  }

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
	
	public void update() {

	}
	
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
	
	Point(long _time, int _value) {
		time = _time;
		value = _value;
	}
	
}
class Robot {

  //List of robot data: x1-10,y1-10,  xx,yy to xx2,yy2, Turn towards or away TT or TA, Open or Close claw OC or CC, Stretch or Contract S or C, Arousal in %, Classification of move <A>, Other: emotions etc
  public void moveRobot(int x, int y, boolean turning, boolean claw, boolean stretchOrContract, int arousal){

    // setTraversPosition(x, y);
    // setTurning();
    // setClaw();
    // setStretchOrContract();
    // setArousal();



  }

  /* Inverse Kinematic Arithmetic: X can be + and -; Y and Z only positive. All values in mm! gripperAngleD must be according to the object in degree. gripperwidth in degree. And speed from 0-255 */
  public void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperWidth, int light, int easingResolution )
  {

    if(isRobotReadyToMove){
      /* send start byte */
      float gripAngle = radians( gripperAngleD );

      float ulnaEved = ULNA + (WRIST_OFFSET*sin(gripAngle));
      float zEved = z - (WRIST_OFFSET*cos(gripAngle));

      // float ulnaEved = ULNA + (sin(gripAngle));
      // float zEved = z - (cos(gripAngle));

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
        && isInRange(elbowAngleD, 0, 180) && isInRange(wristAngleD, 0, 180) && isInRange(gripperAngleD, 0, 180) && isInRange(gripperWidth, 0, 180)){
        isDataVerified = true;
      }else{
        isDataVerified = false;
      }

      currentBase = (int) map(baseAngleD, 180, 0, BASE_MIN, BASE_MAX);
      currentShoulder = (int) map(shoulderAngleD, 0, 180, SHOULDER_MIN, SHOULDER_MAX);
      currentElbow = (int) map(elbowAngleD, 180, 0, ELBOW_MIN, ELBOW_MAX);
      currentWrist = (int) map(wristAngleD, 0, 180, WRIST_MIN, WRIST_MAX);
      currentGripperAngle = (int) map(gripperAngleD, 0, 180, GRIPPER_ANGLE_MIN, GRIPPER_ANGLE_MAX);
      currentGripperWidth = (int) map(gripperWidth, 0, 180, GRIPPER_MIN, GRIPPER_MAX);
      currentLight = light;
      if(easingResolution <= 0)
        currentEasing = 1;
      else
        currentEasing = easingResolution;
     

      if(isDataVerified){
        sendRobotData( currentBase, currentShoulder, currentElbow, currentWrist, currentGripperAngle, currentGripperWidth, currentLight, currentEasing);
        // println("Data Send");
      }
    
    }

  }

  public boolean isInRange(float value, float minimum, float maximum)
  {
    if(value >= minimum && value <= maximum)
      return true;
    return false;
  }

  public void sendRobotData(int currentBase,int currentShoulder,int currentElbow,int currentWrist,int currentGripperWidth,int currentGripperAngle, int currentLight, int currentEasing){

    myPort.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentLight, currentEasing));
    // myPort.write(10);
    println(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentLight, currentEasing));
    isRobotReadyToMove = false;

  }


	
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
