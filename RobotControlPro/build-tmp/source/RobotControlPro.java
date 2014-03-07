import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import controlP5.*; 
import processing.net.*; 
import org.json.*; 
import java.util.Set; 
import java.util.Set; 
import java.util.concurrent.Executors; 
import java.util.concurrent.ScheduledExecutorService; 
import java.util.concurrent.TimeUnit; 
import java.awt.Frame; 
import com.pusher.client.Pusher; 
import com.pusher.client.PusherOptions; 
import com.pusher.client.channel.PrivateChannel; 
import com.pusher.client.channel.PrivateChannelEventListener; 
import com.pusher.client.channel.SubscriptionEventListener; 
import com.pusher.client.connection.ConnectionEventListener; 
import com.pusher.client.connection.ConnectionState; 
import com.pusher.client.connection.ConnectionStateChange; 
import com.pusher.client.util.HttpAuthorizer; 

import org.slf4j.spi.*; 
import org.slf4j.*; 
import com.pusher.client.connection.websocket.*; 
import org.java_websocket.handshake.*; 
import org.java_websocket.client.*; 
import org.java_websocket.framing.*; 
import com.google.gson.*; 
import org.java_websocket.exceptions.*; 
import org.slf4j.impl.*; 
import com.google.gson.reflect.*; 
import com.google.gson.internal.*; 
import com.pusher.client.connection.*; 
import com.pusher.client.*; 
import org.java_websocket.drafts.*; 
import com.pusher.client.channel.impl.*; 
import com.google.gson.stream.*; 
import com.pusher.client.util.*; 
import org.java_websocket.server.*; 
import com.google.gson.internal.bind.*; 
import com.pusher.client.connection.impl.*; 
import com.google.gson.annotations.*; 
import org.java_websocket.*; 
import com.pusher.client.example.*; 
import org.java_websocket.util.*; 
import org.slf4j.helpers.*; 
import com.pusher.client.channel.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class RobotControlPro extends PApplet {





/* Static Robot Values used for Inverse Kinematic */
/* Arm dimensions( mm ) */
private static final Float BASE_HEIGHT  = 101.0f;   //height of robot-base"
private static final Float SHL_ELB      = 105.0f;   //shoulder-to-elbow
private static final Float ULNA         = 98.0f;    //elbow-to-wrist
private static final Float GRIPLENGTH   = 155.0f;   //lengh-of-grip
private static final Float WRIST_OFFSET = 28.0f;    //offset wrist-gripper

/* Dynamic Robot Values Send to Arduino */
private int currentBase          = 00;
private int currentShoulder      = 00;
private int currentElbow         = 00;
private int currentWrist         = 00;
private int currentGripperAngle  = 00;
private int currentGripperWidth  = 00;
private int currentSpeed         = 00;
private int blinkStrength        = 0;
private int k                    = 0;
private int xOffset              = 0;
private int bWristAngle          = 90;
private int barIteration         = 0;
private float attentionValue     = 90.0f;
private float meditationValue    = 120.0f;
private boolean robotIsReadyToMove = false;
private boolean barReadyToDraw  = true;

Client myClient;

/* Serial Communication */
Serial myPort;
private long    heartbeat;
private String  inByte;
private char    serial1;
private char    serial2;
private char    serial3;
private int     end           = 10;
private byte    breakLine     = 13;
// private byte[] byteBuffer = new byte[24];
private boolean firstContact  = false;
private boolean isHashtrue    = false;

/* Monitoring */
Monitoring monitoring;
boolean gIsDebugOn = true;
int gFontSize = 12;

/*Control 5 GUI*/
ControlP5 controlP5;
ControlFont cfont;
Plotter[] plotter = new Plotter[200];
int[] barTracer = new int[10];
Channel[] channels = new Channel[201];
int packetCount = 0;
int globalMax;
String scaleMode;



/*Connection Status */
ConnectionStatus connectionStatus;

public void setup() {
	
 	/* Basic setup */
  size(1280,720);
  smooth(4);
  
  frame.setTitle("Robot Control");  
  
    for (int i = 0; i < Serial.list().length; i++) {
      println("[" + i + "] " + Serial.list()[i]);
    }
 
  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.bufferUntil(end);
  myPort.clear();
  inByte = null;
  
  mPusherConnection = new PusherConnection();
  // mPusherConnection.onCreate();

  monitoring = new Monitoring();

  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(color(0));    
  controlP5.setColorBackground(color(0));
  controlP5.disableShortcuts(); 
  controlP5.disableMouseWheel();
  controlP5.setMoveable(false);
  
  /* Must be declared after ControlP5! */
  connectionStatus = new ConnectionStatus(width - 140, 10, 20);
  cfont = new ControlFont(createFont("DIN-MediumAlternate", 12), 12);

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
        myClient = new Client(this, thinkgearHost, thinkgearPort);
        String command = "{\"enableRawOutput\": false, \"format\": \"Json\"}\n";
        print("Sending command");
        println (command);
        myClient.write(command);


  // Creat the channel objects
  // yellow to purple and then the space in between, grays for the alphas

  channels[0] = new Channel("Signal Quality", color(0), "");
  // Manual override for a couple of limits.

  for (int i = 1; i < plotter.length + 1; ++i) {  
    if(i <= 20){channels[i] = new Channel("Attention", color(10), "");  channels[i].minValue = 0; channels[i].maxValue = 100; channels[i].addDataPoint(0);}
    if(i > 20 && i <= 40){channels[i] = new Channel("Meditation", color(50), ""); channels[i].minValue = 0; channels[i].maxValue = 100; channels[i].addDataPoint(0);}
    if(i > 40 && i <= 60){channels[i] = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep"); channels[i].addDataPoint(0);}
    if(i > 60 && i <= 80){channels[i] = new Channel("Theta", color(245, 80, 71), "Drowsy"); channels[i].addDataPoint(0);}
    if(i > 80 && i <= 100){channels[i] = new Channel("Low Alpha", color(237, 0, 119), "Relaxed"); channels[i].addDataPoint(0);}
    if(i > 100 && i <= 120){channels[i] = new Channel("High Alpha", color(212, 0, 149), "Relaxed"); channels[i].addDataPoint(0);}
    if(i > 120 && i <= 140){channels[i] = new Channel("Low Beta", color(158, 18, 188), "Alert"); channels[i].addDataPoint(0);}
    if(i > 140 && i <= 160){channels[i] = new Channel("High Beta", color(116, 23, 190), "Alert"); channels[i].addDataPoint(0);}
    if(i > 160 && i <= 180){channels[i] = new Channel("Low Gamma", color(39, 25, 159), "???"); channels[i].addDataPoint(0);}
    if(i > 180 && i <= 200){channels[i] = new Channel("High Gamma", color(23, 26, 153), "???"); channels[i].addDataPoint(0);}
  }
  
  channels[0].minValue = 0;
  channels[0].maxValue = 200;
  
  // channels[0].allowGlobal = false;
  // channels[1].allowGlobal = false;
  // channels[2].allowGlobal = false;

  // Set up the plotter, skip the signal quality
  
  for (int i = 0; i < plotter.length; i++) {
    if (i%20 == 0){
      k++;
      xOffset = xOffset + 20;
    }
    plotter[i] = new Plotter(channels[i+1], 1200 + ((8*i) - (8*xOffset)), 40 + (60 * k), 4, 30);
  }
  
  //plotter[plotter.length - 1].w += width % plotter.length;

    for (int i = 0; i < 20; ++i) {
      monitoring.setColor(color(255, 255, 255), i);
    }
    monitoring.setColor(0xff00D7FF, 0);
    monitoring.setColor(0xff00D7FF, 2);
    monitoring.setColor(0xff00D7FF, 4);
    monitoring.setColor(0xff00D7FF, 6);
    monitoring.setColor(0xff00D7FF, 11);
    monitoring.setColor(0xff00D7FF, 15);
}

public void draw() {
  background(100);
  connectionStatus.update();
  connectionStatus.draw(); 
  monitoring();

  //   // find the global max
  // if(scaleMode == "Global") {
  //   if(channels.length > 3) {
  //     for(int i = 3; i < channels.length; i++) {
  //       if (channels[i].maxValue > globalMax) globalMax = channels[i].maxValue;
  //     }
  //   }
  // } 

/* Check if Serial heartbeat is lost */
  if (firstContact){
    if (millis() - heartbeat >= 5000){
       firstContact = false; 
       println("Heartbeat lost");
       serialConnection = "Heartbeat lost!";
    }
  }
  if(barReadyToDraw){
    for (int i = 0; i < plotter.length; ++i) {
      // println("I: " + i);
      plotter[i].update();
      plotter[i].draw(); 
    }
  }
}



public void keyPressed(){
 
  // We should be able to toggle the debugger so
  // it doesn't consume resources.\u00bb
  if(key == 'd'){
    gIsDebugOn = !gIsDebugOn;
    monitoring.setOn(gIsDebugOn);
  }
 
  if(key == '+'){
    gFontSize++;
  }
 
  if(key == '-'){
    gFontSize--;
    if(gFontSize == 0){
      gFontSize = 1;
    }
  }
 
  monitoring.setFont("verdana", gFontSize);

   if (key == CODED){
      if (keyCode == LEFT){
        setRobotArm(-100, 80, 50, 90, 180, 127);
      }
      if (keyCode == RIGHT){
        setRobotArm(100, 80, 10, 90, 180, 127);
      }
      if (keyCode == UP){
        setRobotArm(100, 80, 0, 90, 90, 127);
      }
      if (keyCode == DOWN){
        setRobotArm(0, 100, 50, 90, 90, 127);
      }
    }
}

//Wait for serial events 
public void serialEvent(Serial myPort) {
  // println("In Serial Event");
  while (myPort.available() > 0){
  inByte = myPort.readStringUntil(end);
  //println(inByte);
  }
  if (inByte != null) {

    if (isHashtrue){
      println("Hash received");
      String[] s = split(inByte, ',');
      isHashtrue = false;
      if(s[0].trim().equals("1")){
        println("Value of Base: " +  s[1]);
        println("Value of Shoulder: " +  s[2]);
        // println("Value of E: " +  s[3]);
      }
    }

    if (inByte.trim().equals("W")){
      myPort.write("W");
      myPort.write(10);
      println("+ Heartbeat +");
      heartbeat = millis();
      serialConnection = "Connected";
    }

    if(inByte.trim().equals("N")){
      robotIsReadyToMove = true;
      println("Robot Ready for Next Position");
    }

    if(!firstContact){
      if (inByte.trim().equals("A")) {
        serialConnection = "Connected";
        println("Connected");
        firstContact = true;
        robotIsReadyToMove = true;
        delay(500);                     
        myPort.write("B");
        myPort.write(10);        
      }  
    } 
    else if(inByte.trim().equals("#")){
        isHashtrue = true;
    }
  }
}



public void clientEvent(Client  myClient) {
  // Sample JSON data:
  // {"eSense":{"attention":67,"meditation":43},"eegPower":{"delta":657208,"theta":69277,"lowAlpha":15004,"highAlpha":7692,"lowBeta":10326,"highBeta":8686,"lowGamma":4384,"highGamma":1974},"poorSignalLevel":0}
  // {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}
  
  if (myClient.available() > 0) {
      
    byte[] inBuffer = myClient.readBytesUntil(breakLine);
    
    if (inBuffer != null){
    String myString = new String(inBuffer);
    print(myString);
      try {
        org.json.JSONObject json = new org.json.JSONObject(myString);
        channels[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));
      }
      catch (JSONException e) {
       println (e);
       // e.printStackTrace();
       // print(myString);
      };
    
      try{

        org.json.JSONObject json = new org.json.JSONObject(myString);
        org.json.JSONObject esense = json.getJSONObject("eSense");
        if (esense != null) {
          while (barIteration < (plotter.length - 20)){
            for (int i = 0; i < 10; ++i) {
              if(i != 0){
              barTracer[i] = barIteration;
              barIteration += 20;
              println("for loop: " + barIteration);
              }
              println("I in while: " + barIteration);
            }
          }
          println("After While: " + barIteration);
          barIteration = (200%barIteration);
          println("After Modulo: " + barIteration);
          if(barIteration > 0){barIteration = 20 - barIteration;}
          barIteration++;
          println("Ready for next loop: " + barIteration);

          channels[barTracer[0]].addDataPoint(Integer.parseInt(esense.getString("attention")));
          channels[barTracer[1]].addDataPoint(Integer.parseInt(esense.getString("meditation")));
        }
        
        org.json.JSONObject eegPower = json.getJSONObject("eegPower");
        if (eegPower != null) {
          channels[barTracer[2]].addDataPoint(Integer.parseInt(eegPower.getString("delta")));
          channels[barTracer[3]].addDataPoint(Integer.parseInt(eegPower.getString("theta"))); 
          channels[barTracer[4]].addDataPoint(Integer.parseInt(eegPower.getString("lowAlpha")));
          channels[barTracer[5]].addDataPoint(Integer.parseInt(eegPower.getString("highAlpha")));  
          channels[barTracer[6]].addDataPoint(Integer.parseInt(eegPower.getString("lowBeta")));
          channels[barTracer[7]].addDataPoint(Integer.parseInt(eegPower.getString("highBeta")));
          channels[barTracer[8]].addDataPoint(Integer.parseInt(eegPower.getString("lowGamma")));
          channels[barTracer[9]].addDataPoint(Integer.parseInt(eegPower.getString("highGamma")));
          }

      }
      catch (JSONException e) {
      println (e);
      // e.printStackTrace();
      // print(myString);
      };


      try{
      org.json.JSONObject json = new org.json.JSONObject(myString);  
      blinkStrength = json.getInt("blinkStrength");
      println(blinkStrength);

      }

      catch (JSONException e) {
       println (e);
       // e.printStackTrace();
       // print(myString);
      };
  
      packetCount++;

      if(barIteration == 0){
        barReadyToDraw = true;
      }
      // println("BarIteration after Modulo: " + barIteration);
    }
        
  }
 
    if (channels[0].getLatestPoint().value == 00){  
      if(channels[2].getLatestPoint().value >= 55){
        attentionValue = map(channels[2].getLatestPoint().value, 55, 100, 50, 140);
      }

      if(channels[1].getLatestPoint().value >= 55){
        meditationValue = map(channels[1].getLatestPoint().value, 55, 100, 100, 130);
      }
    }

    if (blinkStrength >= 50){
      bWristAngle = 180;
    }else if (blinkStrength < 50 ){
      bWristAngle = 90;
    }

    setRobotArm(0, meditationValue, attentionValue, 90,bWristAngle,127);
}  

public void monitoring(){
  /* Degugg output */
  monitoring.add("FPS:"); 
  monitoring.add(" | " + frameRate);
  monitoring.add("X/Y:"); 
  monitoring.add(" | [" + mouseX + "," + mouseY + "]");
  monitoring.add("LAST KEY: ");
  monitoring.add(" | " + key + "\n");
  monitoring.add("SERVO ANGLES:");
  monitoring.add(String.format(" | ba:\t" + "[ %s ]", currentBase));
  monitoring.add(String.format(" | sh:\t" + "[ %s ]", currentShoulder));
  monitoring.add(String.format(" | el:\t\t" + "[ %s ]", currentElbow));
  monitoring.add(String.format(" | wr:\t" + "[ %s ]", currentWrist));
  line(x, 100, x, 65);
 // monitoring.add("last serial messages: [" + serial1 + serial2 + serial3 + "]");
  monitoring.add("PUSHER: ");
  monitoring.add(" | " + error);
  monitoring.add(" | " + msg);
  monitoring.add(connectionPusher);
  monitoring.add("SERIAL:");
  monitoring.add(" | last serial messages: [ " + serial1 + serial2 + serial3 + " ]");
  monitoring.add("" + serialConnection);
  monitoring.draw();
}


public void sendRobotData(int currentBase,int currentShoulder,int currentElbow,int currentWrist,int currentGripperWidth,int currentGripperAngle,int currentSpeed){

  myPort.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentSpeed));
  // myPort.write(10);
  print(String.format("Rr%d,%d,%d,%d,%d,%d,%d",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentSpeed));
  robotIsReadyToMove = false;

}


/* Inverse Kinematic Arithmetic: X can be + and -; Y and Z only positive. All values in mm! gripperAngleD must be according to the object in degree. gripperwidth in degree. And speed from 0-255 */
public void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperWidth, int speed )
{

  if(robotIsReadyToMove){
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
    
    long wristAngleD = (long) degrees(wristAngle);
    long elbowAngleD = (long) degrees(elbowAngle);
    long shoulderAngleD = (long) degrees(shoulderAngle);
    long baseAngleD = (long) degrees(baseAngle);

      currentBase = (int) baseAngleD;
      currentShoulder = (int) shoulderAngleD;
      currentElbow = (int) elbowAngleD;
      currentWrist = (int) wristAngleD;
      currentGripperAngle = (int) gripperAngleD;
      currentGripperWidth = gripperWidth;
      currentSpeed = speed;

    sendRobotData( currentBase, currentShoulder, currentElbow, currentWrist, currentGripperAngle, currentGripperWidth, currentSpeed);
  }else{
    // println("Robot not ready yet!");
  }
  
}


// // Utilities

// // Extend Processing's built-in map() function to support the Long datatype
// long mapLong(long x, long in_min, long in_max, long out_min, long out_max) { 
//   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
// }

// // Extend Processing's built-in constrain() function to support the Long datatype
// long constrainLong(long value, long min_value, long max_value) {
//   if (value > max_value) return max_value;
//   if (value < min_value) return min_value;
//   return value;
// }
class Channel { 

	String name;
	int drawColor;
	String description;
	boolean graphMe;
	boolean relative;
	int maxValue;
	int minValue;
	ArrayList points;
	// boolean allowGlobal;
		


	Channel(String _name, int _drawColor, String _description) {
		name = _name;
		drawColor = _drawColor;
		description = _description;
		// allowGlobal = true;
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
class ConnectionStatus{
	int x, y;
	int currentColor 	= 0;
	int greenColor 		= color(0, 255, 0);
	int orangeColor 	= color(255, 255, 0);
	int redColor 		= color(255, 0, 0);
	int diameter;
	int latestConnectionValue;
	Textlabel label;

	ConnectionStatus(int _x, int _y, int _diameter) {
		x = _x;
		y = _y;
		diameter = _diameter;
		
 		label = new Textlabel(controlP5,"CONNECTION\nQUALITY", 32, 6);		
		label.setMultiline(true);
		label.setColorValue(color(0));
	}
	
	public void update() {
		latestConnectionValue = channels[0].getLatestPoint().value;
		if(latestConnectionValue == 200) currentColor 	= redColor;
		if(latestConnectionValue < 200) currentColor 	= orangeColor;
		if(latestConnectionValue == 00) currentColor	= greenColor;
	}
	
	public void draw() {
		
		
		pushMatrix();
		translate(x, y);
		
		noStroke();
		fill(255, 90);
		rect(0, 0, 108, 28);
		
		noStroke();
		fill(currentColor);
		ellipseMode(CORNER);
		ellipse(5, 4, diameter, diameter);
		
 		label.draw(); 		
		popMatrix();
	}

}
public class Monitoring{
  private ArrayList strings;
  private int[] textColor = new int [32];
  private PFont font;
  private int fontSize;
  private int offset = 0;
  private boolean isOn;
 
  public Monitoring(){
    strings = new ArrayList();
    setFont("helvetica", 12);
    isOn = true;
  }
 
  public void add(String s){
    if(isOn){
      strings.add(s);
    }
  }
 
  public void setOn(boolean on){
    isOn = on;
  }
 
  public void setFont(String name, int size){
    fontSize = size <= 0 ? 1 : size;
    font = createFont(name, fontSize);
    textAlign(LEFT);
  }
 
  public void setColor(int c, int i){
    textColor[i] = c;
  }
 
  public void clear(){
    while(strings.size() > 0){
      strings.remove(0);
    }
  }
 
  public void draw(){
    if(isOn){
      pushStyle();
      textFont(font);
      int y = fontSize;
 
      for(int i = 0; i < strings.size(); i++, y += fontSize){
        fill(textColor[i]);
        text((String)strings.get(i), 5, y);
      }
      popStyle();
      clear();
    }
  }
}
class Plotter {
	int x, y, w, h, currentValue, targetValue, backgroundColor;
	Channel sourceChannel;
	Textlable describtion;
	
	
	Plotter(Channel _sourceChannel, int _x, int _y, int _w, int _h) {
		sourceChannel = _sourceChannel;
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		currentValue = 0;
		backgroundColor = color(255);


	}
	
	public void update() {

	}
	
	public void draw() {
		pushMatrix();
		translate(x, y);		
		// Background
		// noStroke();
		// fill(backgroundColor);
		// rect(0, 0, w, h);

		// // border line
		// strokeWeight(1);
		// stroke(220);
		// line(w - 1, 0, w - 1, h);

		
		if(sourceChannel.points.size() > 0) {
		
			Point targetPoint = (Point)sourceChannel.points.get(sourceChannel.points.size() - 1);
			targetValue = round(map(targetPoint.value, sourceChannel.minValue, sourceChannel.maxValue, 0, h));

			// if((scaleMode == "Global") && sourceChannel.allowGlobal) {					
			// 	targetValue = (int)map(targetPoint.value, 0, globalMax, 0, h);	
			// }	
							
			// Calculate the new position on the way to the target with easing
    	currentValue = currentValue + round(((float)(targetValue - currentValue) * .08f));
			
			// Bar
			noStroke();
			fill(sourceChannel.drawColor);
			rect(0, h, w, -currentValue);

			describtion = new Textlabel("label")
                    	.setText(sourceChannel.describtion)
                    	.setPosition(10,h)
                    	.setColorValue(0xffffff00)
                    	.setFont(createFont("Georgia",20));

		}

		// Draw the checkbox matte
		
		noStroke();
		fill(255, 127);		
		rect(10, 50, w - 20, 10);
		popMatrix();	
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


















private static final String   DATA_CHANNEL        = "private-data";
private static final String   ROBOT_CONTROL_EVENT = "client-robot-control";
private static final String   YAW_COORD           = "yaw";
private static final String   PITCH_COORD         = "pitch";
private static final String   Z_COORD             = "z_coord";
private static final String   ID_ROBOT            = "id";
private static final Integer  DISPLAY_DURATION    = 4000;

/* Pusher */
PusherConnection mPusherConnection;
private Pusher          mPusher;
private PrivateChannel  mPrivateChannel;
private PusherOptions   mPusherOptions;
private Integer         failedConnectionAttempts  = 0;
private String          msg                       = "No Event";
private String          connectionPusher          = "No Connection";
private String          serialConnection          = "Establish serial connection...";
private String          error;
private double   id;
private int      x;
private int      y;
private int      yaw;
private int      pitch;




public class PusherConnection implements ConnectionEventListener, SubscriptionEventListener,  PrivateChannelEventListener {
  
  

  public void onCreate() {
    // TODO: login token
    
    connectToPusher();
    
  }
  
  private void connectToPusher() {
    // connect to pusher in order to receive Game stats commands
    // and triggering event, such as pointer
    HttpAuthorizer authorizer = new HttpAuthorizer("http://thehunt.herokuapp.com/pusher/auth");
    mPusherOptions = new PusherOptions().setAuthorizer(authorizer);
    mPusher = new Pusher("b41bf8007ed13fc337cd", mPusherOptions);
    mPusher.connect(this, ConnectionState.ALL);
  }
    
  
  
  

  
  //ConnectionEventListener implementation
  public void onConnectionStateChange(ConnectionStateChange change) {
      connectionPusher = String.format("Connection state changed from [%s] to [%s]", change.getPreviousState(), change.getCurrentState() );
    
    if (change.getCurrentState() == ConnectionState.CONNECTED) {
      // subscribe to channel
      mPrivateChannel = mPusher.subscribePrivate(DATA_CHANNEL, this, ROBOT_CONTROL_EVENT);
      connectionPusher= String.format("Connected");
      monitoring.setColor(0xff65EC3B, 14);
    }
    
    else if (change.getCurrentState() == ConnectionState.DISCONNECTED) {
            
      failedConnectionAttempts ++;
      connectToPusher();
      delay(2000);    
      
    }

  }

  public void onError(String message, String code, Exception e) {
    connectionPusher = String.format("Connection error: [%s] [%s] [%s]", message, code, e);
    monitoring.setColor(0xffFF4540, 14);
  }

  // ChannelEventListener implementation
  public void onEvent(String channelName, String eventName, String data) {
    msg = String.format("Event received: [%s] [%s] [%s]", channelName, eventName, data);
    
    try {
      org.json.JSONObject obj = new org.json.JSONObject(data);
      
      if (channelName.equals(DATA_CHANNEL)) {
        
        
        if (eventName.equals(ROBOT_CONTROL_EVENT)) {
          // id = obj.getDouble(ID_ROBOT);
          // x = obj.getDouble(YAW_COORD);
          // msg[textIteration] = String.format("YAW: [%d]", x);
          // textIteration ++;
          // y = obj.getDouble(PITCH_COORD);
          // msg[textIteration] = String.format("PITCH: [%d]", y);
          // z = obj.getDouble(Y_COORD);
          //Location of the hunter should be updated
          
        }       
        
        
      }  
      
      
    } catch (JSONException e) {
      // TODO Auto-generated catch block
      //e.printStackTrace();
    }
    
  }
  

  public void onSubscriptionSucceeded(String channelName) {
    error = String.format("Subscription succeeded for [%s]", channelName);
  }


  @Override
  public void onAuthenticationFailure(String arg0, Exception arg1) {
    // TODO Auto-generated method stub
    error = (String.format("Authentication failure due to [%s], exception was [%s]",arg0, arg1));
  }
  
  
  public void destroy() {
    // TODO Auto-generated method stub
    mPusher.disconnect();
   
  }
  

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "RobotControlPro" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
