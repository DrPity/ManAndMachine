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

private static final String   DATA_CHANNEL = "private-data";
private static final String   ROBOT_CONTROL_EVENT = "client-robot-control";
private static final String   YAW_COORD = "yaw";
private static final String   PITCH_COORD = "pitch";
private static final String   Z_COORD = "z_coord";
private static final String   ID_ROBOT = "id";
private static final Integer  DISPLAY_DURATION = 4000;

/* Arm dimensions( mm ) */
private static final Float BASE_HEIGHT = 101.0;   //height of robot-base"
private static final Float SHL_ELB = 105.0;       //shoulder-to-elbow
private static final Float ULNA = 98.0;           //elbow-to-wrist
private static final Float GRIPLENGTH = 155.0;    //lengh-of-grip
private static final Float WRIST_OFFSET = 28.0;   //offset wrist-gripper

private long currentBase = 00;
private long currentShoulder = 00;
private long currentElbow = 00;
private long currentWrist = 00;

private Pusher          mPusher;
private PrivateChannel  mPrivateChannel;
private PusherOptions   mPusherOptions;
private Integer failedConnectionAttempts = 0;


private double   id;
private int      x;
private int      y;
private int      yaw;
private int      pitch;
private int      inByte = 0;

private String msg = "No Event";
private String connectionPusher = "No Connection";
private String error;

private boolean ready = false;

monitoring mMonitoring;
boolean gIsDebugOn = true;
int gFontSize = 12;
PusherConnection mPusherConnection;
Serial myPort;
PFont f;

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
      mMonitoring.setColor(#65EC3B, 14);
    }
    
    else if (change.getCurrentState() == ConnectionState.DISCONNECTED) {
      
      
      
      failedConnectionAttempts ++;
      connectToPusher();
      delay(2000);    
      
    }

  }

  public void onError(String message, String code, Exception e) {
    connectionPusher = String.format("Connection error: [%s] [%s] [%s]", message, code, e);
    mMonitoring.setColor(#FF4540, 14);
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


void setup() {
	
// mHandlePusher = new HandlePusher();	
size(1280,720, OPENGL);
myPort = new Serial(this, Serial.list()[0], 9600);
myPort.clear();
myPort.bufferUntil(255);
mPusherConnection = new PusherConnection();
mPusherConnection.onCreate();
mMonitoring = new monitoring();

for (int i = 0; i < 16; ++i) {
  mMonitoring.setColor(color(255, 255, 255), i);
}

mMonitoring.setColor(#00D7FF, 0);
mMonitoring.setColor(#00D7FF, 2);
mMonitoring.setColor(#00D7FF, 4);
mMonitoring.setColor(#00D7FF, 6);
mMonitoring.setColor(#00D7FF, 11);

delay(500);
robotHandshake();

delay(500);
}

void draw() {
  background(100);


/* Degugg output */
  if(ready){mMonitoring.add("SERIAL READY");};
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
  mMonitoring.draw();
  smooth(4);
}


// x can be + and -; y and z only positive. All values in mm. grip_angle_d must be according to the object in degree. gripperwidth in degree.
void set_arm( float x, float y, float z, float grip_angle_d, int gripperWidth )
{

  float gripAngle = radians( grip_angle_d );

  float ulnaEved = ULNA + (WRIST_OFFSET*sin(gripAngle));
  float zEved = z - (WRIST_OFFSET*cos(gripAngle));

  float baseAngle = atan2( y, x );
  float rDist = sqrt(( x * x ) + ( y * y ));
  
  
  float rShlWri = rDist - (cos(gripAngle) * GRIPLENGTH);
  float zShlWri = zEved - BASE_HEIGHT + (sin(gripAngle) * GRIPLENGTH);
  float h = sqrt((zShlWri * zShlWri) + (rShlWri * rShlWri));


  float elbowAngle = PI - acos( ( (h*h) - (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) ) / (-2.0* ulnaEved * SHL_ELB) );
  float shoulderAngle = acos( ( (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) - (h*h) )/(-2.0*SHL_ELB*h) ) + atan2(zShlWri, rShlWri);
  float wristAngle = shoulderAngle - elbowAngle + gripAngle;
  

  long wristAngleD = (long) degrees(wristAngle);
  long elbowAngleD = (long) degrees(elbowAngle);
  long shoulderAngleD = (long) degrees(shoulderAngle);
  long baseAngleD = (long) degrees(baseAngle);

    currentBase = baseAngleD;
    currentShoulder = shoulderAngleD;
    currentElbow = elbowAngleD;
    currentWrist = wristAngleD;

/* send start byte */
myPort.write(35);

/* send calculated angles */
  // myPort.write(map(baseAngleD, 180, 0, 670, 2270));
  // delay(20);
  // myPort.write(map(shoulderAngleD, 180, 0, 670, 2270));
  // delay(20);
  // myPort.write(map(elbowAngleD, 180, 0, 700, 2300));
  // delay(20);
  // myPort.write(map(wristAngleD, 0, 180, 670, 2270));
  // delay(20);
  // myPort.write(map(grip_angle_d, 0, 180, 670, 2270));
  // delay(20);
  // myPort.write(map(gripperWidth, 0, 180, 670, 2270));
  // delay(20);

/* send stop byte */
myPort.write(4);  
  
}



void keyPressed(){
 
  // We should be able to toggle the debugger so
  // it doesn't consume resources.»
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
         set_arm(100, 80, 30, 90, 120);
      }
      if (keyCode == RIGHT){
          set_arm(10, 80, 30, 90, 120);
      }
      if (keyCode == UP){
          set_arm(100, 30, 50, 90, 120);
      }
      if (keyCode == DOWN){
          set_arm(79, 80, 30, 70, 120);
      }
    }
}

//Wait for serial events 
void serialEvent(Serial myPort) {
 while (myPort.available() > 0) { 
  inByte = myPort.read();
  println(inByte);
  
    if (inByte == 41){
    println("Serial communication Ready");
    ready = true;
    }
  }  
  //     if(inByte == 42){
  //     println("Copying Triggered");
  //     copyCubes(myPort.read(), myPort.read());  
  //     }

  //     //recording cube
  //     if(inByte == 35 && !boxIsTapped){
  //     println("Recording Triggered");
  //     boxIsTapped = true;
  //     sleepTime = millis();
  //     cubeToRecord = myPort.read(); 
  //     }

  //     //trigger cube
  //     if(inByte == '/'){
  //     println("IR-Sensor Triggered");
  //     int cube = myPort.read();
  //     int value = myPort.read();
  //     print(cube);print('\t');println(value);
  //     startBeat(cube, value);
  //     }

  //     //trigger cube off
  //     if(inByte == 92){
  //     println("IR-Sensor Off");
  //     stopBeat(myPort.read());
  //     }
  //   }
}


void robotHandshake(){
  println("Establish connection to robot");
  myPort.write(40);
}