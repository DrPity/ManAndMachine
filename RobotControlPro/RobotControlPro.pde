import processing.serial.*;
import controlP5.*;
import processing.net.*;
import org.json.*;
/* Static Robot Values used for Inverse Kinematic */
/* Arm dimensions( mm ) */
private static final Float BASE_HEIGHT  = 101.0;   //height of robot-base"
private static final Float SHL_ELB      = 105.0;   //shoulder-to-elbow
private static final Float ULNA         = 98.0;    //elbow-to-wrist
private static final Float GRIPLENGTH   = 155.0;   //lengh-of-grip
private static final Float WRIST_OFFSET = 28.0;    //offset wrist-gripper

/* Dynamic Robot Values Send to Arduino */
private int currentBase          = 00;
private int currentShoulder      = 00;
private int currentElbow         = 00;
private int currentWrist         = 00;
private int currentGripperAngle  = 00;
private int currentGripperWidth  = 00;
private int currentSpeed         = 00;
private boolean robotIsReadyToMove = false;

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
Plotter[] plotter = new Plotter[10];
Channel[] channels = new Channel[11];
int packetCount = 0;
int globalMax;
String scaleMode;



/*Connection Status */
ConnectionStatus connectionStatus;

void setup() {
	
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
  channels[1] = new Channel("Attention", color(100), "");
  channels[2] = new Channel("Meditation", color(50), "");
  channels[3] = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep");
  channels[4] = new Channel("Theta", color(245, 80, 71), "Drowsy");
  channels[5] = new Channel("Low Alpha", color(237, 0, 119), "Relaxed");
  channels[6] = new Channel("High Alpha", color(212, 0, 149), "Relaxed");
  channels[7] = new Channel("Low Beta", color(158, 18, 188), "Alert");
  channels[8] = new Channel("High Beta", color(116, 23, 190), "Alert");
  channels[9] = new Channel("Low Gamma", color(39, 25, 159), "???");
  channels[10] = new Channel("High Gamma", color(23, 26, 153), "???");
  
  // Manual override for a couple of limits.
  channels[0].minValue = 0;
  channels[0].maxValue = 200;
  channels[1].minValue = 0;
  channels[1].maxValue = 100;
  channels[2].minValue = 0;
  channels[2].maxValue = 100;
  // channels[0].allowGlobal = false;
  // channels[1].allowGlobal = false;
  // channels[2].allowGlobal = false;

  // Set up the plotter, skip the signal quality
  
  for (int i = 0; i < plotter.length; i++) {
    plotter[i] = new Plotter(channels[i + 1], i * (width / 10), height / 2, width / 10, height / 2);
  }
  
  plotter[plotter.length - 1].w += width % plotter.length;

    for (int i = 0; i < 20; ++i) {
      monitoring.setColor(color(255, 255, 255), i);
    }
    monitoring.setColor(#00D7FF, 0);
    monitoring.setColor(#00D7FF, 2);
    monitoring.setColor(#00D7FF, 4);
    monitoring.setColor(#00D7FF, 6);
    monitoring.setColor(#00D7FF, 11);
    monitoring.setColor(#00D7FF, 15);
    }

void draw() {
  background(100);
  connectionStatus.update();
  connectionStatus.draw(); 
  monitoring();

    // find the global max
  if(scaleMode == "Global") {
    if(channels.length > 3) {
      for(int i = 3; i < channels.length; i++) {
        if (channels[i].maxValue > globalMax) globalMax = channels[i].maxValue;
      }
    }
  } 

 for (int i = 0; i < plotter.length; i++) {
    plotter[i].update();
    plotter[i].draw();
  }
  
  
  

/* Check if Serial heartbeat is lost */
  if (firstContact){
    if (millis() - heartbeat >= 5000){
     firstContact = false; 
     println("Heartbeat lost");
     serialConnection = "Heartbeat lost!";
    }
  }
}



void keyPressed(){
 
  // We should be able to toggle the debugger so
  // it doesn't consume resources.»
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
void serialEvent(Serial myPort) {
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



void clientEvent(Client  myClient) {
  
  // Sample JSON data:
  // {"eSense":{"attention":67,"meditation":43},"eegPower":{"delta":657208,"theta":69277,"lowAlpha":15004,"highAlpha":7692,"lowBeta":10326,"highBeta":8686,"lowGamma":4384,"highGamma":1974},"poorSignalLevel":0}
  // {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}
  
  if (myClient.available() > 0) {
    
  byte[] inBuffer = myClient.readBytesUntil(breakLine);
  
  if (inBuffer != null){
  String myString = new String(inBuffer);
  // print(myString);

    try {
      org.json.JSONObject json = new org.json.JSONObject(myString);
      
      channels[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));

    
      org.json.JSONObject esense = json.getJSONObject("eSense");
      println(esense);
      if (esense != null) {
        channels[1].addDataPoint(Integer.parseInt(esense.getString("attention")));
        println("Channel one: " + channels[1].getLatestPoint().value);
        channels[2].addDataPoint(Integer.parseInt(esense.getString("meditation")));
        println("Channel two: " + channels[2].getLatestPoint().value);
        // print(esense);
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

      }

      packetCount++;
  
      
    }
    catch (JSONException e) {
     // println (e);
     // e.printStackTrace();
     print(myString);
    };
  }  
  
  }

}

void monitoring(){
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


void sendRobotData(int currentBase,int currentShoulder,int currentElbow,int currentWrist,int currentGripperWidth,int currentGripperAngle,int currentSpeed){

  myPort.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentSpeed));
  // myPort.write(10);
  print(String.format("Rr%d,%d,%d,%d,%d,%d,%d",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentSpeed));
  robotIsReadyToMove = false;

}


/* Inverse Kinematic Arithmetic: X can be + and -; Y and Z only positive. All values in mm! gripperAngleD must be according to the object in degree. gripperwidth in degree. And speed from 0-255 */
void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperWidth, int speed )
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

    float elbowAngle = PI - acos( ( (h*h) - (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) ) / (-2.0* ulnaEved * SHL_ELB) );
    float shoulderAngle = acos( ( (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) - (h*h) )/(-2.0*SHL_ELB*h) ) + atan2(zShlWri, rShlWri);
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