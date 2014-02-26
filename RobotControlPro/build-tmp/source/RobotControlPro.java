import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import controlP5.*; 
import java.util.Set; 
import java.util.Set; 
import java.util.concurrent.Executors; 
import java.util.concurrent.ScheduledExecutorService; 
import java.util.concurrent.TimeUnit; 
import org.json.JSONException; 
import org.json.JSONObject; 
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
import org.json.*; 
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
private static final String   DATA_CHANNEL        = "private-data";
private static final String   ROBOT_CONTROL_EVENT = "client-robot-control";
private static final String   YAW_COORD           = "yaw";
private static final String   PITCH_COORD         = "pitch";
private static final String   Z_COORD             = "z_coord";
private static final String   ID_ROBOT            = "id";
private static final Integer  DISPLAY_DURATION    = 4000;

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

private boolean robotIsReadyToMove = false;

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

/* Serial Communication */
Serial myPort;
private long    heartbeat;
private String  inByte;
private char    serial1;
private char    serial2;
private char    serial3;
private int     end           = 10;
private boolean firstContact  = false;
private boolean isHashtrue    = false;

/* Monitoring */
monitoring mMonitoring;
boolean gIsDebugOn = true;
int gFontSize = 12;

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
      mMonitoring.setColor(0xff65EC3B, 14);
    }
    
    else if (change.getCurrentState() == ConnectionState.DISCONNECTED) {
            
      failedConnectionAttempts ++;
      connectToPusher();
      delay(2000);    
      
    }

  }

  public void onError(String message, String code, Exception e) {
    connectionPusher = String.format("Connection error: [%s] [%s] [%s]", message, code, e);
    mMonitoring.setColor(0xffFF4540, 14);
  }

  // ChannelEventListener implementation
  public void onEvent(String channelName, String eventName, String data) {
    msg = String.format("Event received: [%s] [%s] [%s]", channelName, eventName, data);
    
    try {
      JSONObject obj = new JSONObject(data);
      
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
      e.printStackTrace();
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


public void setup() {
	
 	/* Basic setup */
  size(1280,720, OPENGL);
  myPort = new Serial(this, Serial.list()[6], 115200);
  mPusherConnection = new PusherConnection();
  mMonitoring = new monitoring();
  mPusherConnection.onCreate();
  myPort.bufferUntil(end);
  inByte = null;
  myPort.clear();

  for (int i = 0; i < 20; ++i) {
    mMonitoring.setColor(color(255, 255, 255), i);
  }
  mMonitoring.setColor(0xff00D7FF, 0);
  mMonitoring.setColor(0xff00D7FF, 2);
  mMonitoring.setColor(0xff00D7FF, 4);
  mMonitoring.setColor(0xff00D7FF, 6);
  mMonitoring.setColor(0xff00D7FF, 11);
  mMonitoring.setColor(0xff00D7FF, 15);
}

public void draw() {
  background(100);
  monitoring();
  smooth(4);
/* Check if Serial heartbeat is lost */
  if (firstContact){
    if (millis() - heartbeat >= 5000){
     firstContact = false; 
     println("Heartbeat lost");
     serialConnection = "Heartbeat lost!";
    }
  }
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
  }else{println("Robot not ready yet!");}
/* send start byte */
/* send calculated angles */
  // myPort.write(map(baseAngleD, 180, 0, 670, 2270));
  // delay(20);
  // myPort.write(map(shoulderAngleD, 180, 0, 670, 2270));
  // delay(20);
  // myPort.write(map(elbowAngleD, 180, 0, 700, 2300));
  // delay(20);
  // myPort.write(map(wristAngleD, 0, 180, 670, 2270));
  // delay(20);
  // myPort.write(map(gripperAngleD, 0, 180, 670, 2270));
  // delay(20);
  // myPort.write(map(gripperWidth, 0, 180, 670, 2270));
  // delay(20);
/* send stop byte */  
  
}



public void keyPressed(){
 
  // We should be able to toggle the debugger so
  // it doesn't consume resources.\u00bb
  if(key == 'd'){
    gIsDebugOn = !gIsDebugOn;
    mMonitoring.setOn(gIsDebugOn);
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
 
  mMonitoring.setFont("verdana", gFontSize);

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

public void monitoring(){
  /* Degugg output */
  mMonitoring.add("FPS:"); 
  mMonitoring.add(" | " + frameRate);
  mMonitoring.add("X/Y:"); 
  mMonitoring.add(" | [" + mouseX + "," + mouseY + "]");
  mMonitoring.add("LAST KEY: ");
  mMonitoring.add(" | " + key + "\n");
  mMonitoring.add("SERVO ANGLES:");
  mMonitoring.add(String.format(" | ba:\t" + "[ %s ]", currentBase));
  mMonitoring.add(String.format(" | sh:\t" + "[ %s ]", currentShoulder));
  mMonitoring.add(String.format(" | el:\t\t" + "[ %s ]", currentElbow));
  mMonitoring.add(String.format(" | wr:\t" + "[ %s ]", currentWrist));
  line(x, 100, x, 65);
 // mMonitoring.add("last serial messages: [" + serial1 + serial2 + serial3 + "]");
  mMonitoring.add("PUSHER: ");
  mMonitoring.add(" | " + error);
  mMonitoring.add(" | " + msg);
  mMonitoring.add(connectionPusher);
  mMonitoring.add("SERIAL:");
  mMonitoring.add(" | last serial messages: [ " + serial1 + serial2 + serial3 + " ]");
  mMonitoring.add("" + serialConnection);
  mMonitoring.draw();
}


public void sendRobotData(int currentBase,int currentShoulder,int currentElbow,int currentWrist,int currentGripperWidth,int currentGripperAngle,int currentSpeed){

  myPort.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentSpeed));
  // myPort.write(10);
  print(String.format("Rr%d,%d,%d,%d,%d,%d,%d",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentSpeed));
  robotIsReadyToMove = false;

}
public class monitoring{
  private ArrayList strings;
  private int[] textColor = new int [32];
  private PFont font;
  private int fontSize;
  private int offset = 0;
  private boolean isOn;
 
  public monitoring(){
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "RobotControlPro" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
