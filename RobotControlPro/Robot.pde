/* Static Robot Values used for Inverse Kinematic */
/* Arm dimensions( mm ) */

private static final Float  BASE_HEIGHT  = 101.0;   //height of robot-base"
private static final Float  SHL_ELB      = 105.0;   //shoulder-to-elbow
private static final Float  ULNA         = 98.0;    //elbow-to-wrist
private static final Float  GRIPLENGTH   = 155.0;   //lengh-of-grip
private static final Float  WRIST_OFFSET = 28.0;    //offset wrist-gripper

/* Constrains of servo motors in milliseconds */
private static final Integer  BASE_MAX            = 2150;//2300;
private static final Integer  BASE_MIN            = 800;//720;
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

private boolean     sendData        = false;
private boolean     isDataVerified  = false;
private boolean     isStrRun        = false;
private boolean     validStrPos     = false;

// private boolean[]   strArray        = new boolean[350];


// ------------------------------------------------------------------------------------

class Robot{

  //List of robot data: x1-10,y1-10,  xx,yy to xx2,yy2, Turn towards or away TT or TA, Open or Close claw OC or CC, Stretch or Contract S or C, Arousal in %, Classification of move <A>, Other: emotions etc
  void moveRobot(int x, int y, boolean turning, boolean claw, int stretch, int arousal){

    // setTraversPosition(x, y);
    // setTurning();
    // setClaw();
    // setStretchOrContract();
    // setArousal();
  }

// ------------------------------------------------------------------------------------


  int stretching(int percentage){
    
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
  void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperRotation, int gripperWidth, int easingResolution, boolean sendData, int brightnessStrip, int r, int g,  int b, int led){

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

      float elbowAngle = PI - acos( ( (h*h) - (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) ) / (-2.0* ulnaEved * SHL_ELB) );
      float shoulderAngle = acos( ( (ulnaEved*ulnaEved) - (SHL_ELB*SHL_ELB) - (h*h) )/(-2.0*SHL_ELB*h) ) + atan2(zShlWri, rShlWri);
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
        println("( Data verfied )");
        if (!sendData){
          validStrPos = true;
        }

      }else{
        isDataVerified = false;
        println("[ Data not verified ]");
      }

      println("[ " + x + "," + y + "," + z + "," + gripperAngleD + "," + gripperRotation +  "," + gripperWidth + "," + easingResolution + "," + brightnessStrip + "," + r + "," + g + "," + b + " ]");

      currentBase = (int) map(baseAngleD, 180, 0, BASE_MIN, BASE_MAX);
      currentShoulder = (int) map(shoulderAngleD, 0, 180, SHOULDER_MIN, SHOULDER_MAX);
      currentElbow = (int) map(elbowAngleD, 180, 0, ELBOW_MIN, ELBOW_MAX);
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

  boolean isInRange(float value, float minimum, float maximum)
  {
    if(value >= minimum && value <= maximum)
      return true;
    return false;
  }

// ------------------------------------------------------------------------------------

  void sendRobotData(int currentBase, int currentShoulder, int currentElbow, int currentWrist, int currentGripperRotation, int currentGripperWidth, int currentEasing, int currentBrightness, int r, int g, int b, int led){

    if(wA.deviceInstanciated)
    wA.port.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperRotation, currentGripperWidth, currentEasing, currentBrightness, r, g, b, led));
    // wA.port.write(10);
    // println(String.format("(Rr%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperRotation, currentGripperWidth, currentEasing, currentBrightness, r, g, b, led));
    isRobotReadyToMove = false;

  }


  void sendTraversData(int x, int y, int z, int easing){
    if(wM.deviceInstanciated){
      wM.port.write(String.format("Rr%d,%d,%d,%d\n",x,y,z,easing));
      // wA.port.write(10);
      println(String.format("(Rr%d,%d,%d,%d)",x, y, z,easing));
      isTraversReadyToMove = false;
    }
  }



   void sendBeat(Serial port, int strip, int r, int g, int b){
    // println("laLedIsready: "+laLedIsready);

    if(wLA.deviceInstanciated || wLB.deviceInstanciated){
      // println("( In send beat )");
      port.write(String.format("Cc%d,%d,%d,%d,%d\n",strip,r,g,b,1));
      println(String.format("(Rr%d,%d,%d,%d)",strip, r, g,b));
      // wA.port.write(10);
      laLedIsready = false;
    }

  }


  void setTargetColor(Serial port, int strip, int r, int g, int b){

    if(wLA.deviceInstanciated || wLB.deviceInstanciated){
      port.write(String.format("Tt%d,%d,%d,%d\n",strip,r,g,b));
      // wA.port.write(10);
      laLedIsready = false;
    }

  }

   void setColor(Serial port, int strip, int r, int g, int b){

    if(wLA.deviceInstanciated || wLB.deviceInstanciated){
      port.write(String.format("Cc%d,%d,%d,%d\n",strip,r,g,b,0));
      // wA.port.write(10);
      println(String.format("(Rr%d,%d,%d,%d)",strip, r, g,b));
      laLedIsready = false;
    }

  }

// ------------------------------------------------------------------------------------


  int findLowerBound(int strechedPosition){
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


  int findUpperBound(int strechedPosition){
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

  void loadRobotData(){

    tablePositions = loadTable("data/Positions.csv", "header");
  }

// ------------------------------------------------------------------------------------

  void readNextRobotPosition(){
  if(globalID <= (tablePositions.getRowCount() -1) && globalID >= 0){

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
        //float x, float y, float z, float gripperAngleD, int gripperRotation, int gripperWidth, int easingResolution, boolean sendData, int brightnessStrip, int r, int g,  int b, int led
          setRobotArm(x,y,z,gripperAngle,gripperRotation,gripperWidth,easing,true,brightn,r,g,b,2);
          println("RobotTable");
          println("[ " + x + "," + y + "," + z + "," + gripperAngle + "," + gripperRotation +  "," + gripperWidth + "," + easing + "," + brightn + "," + r + "," + g + "," + b + "," + x1 + "," + y1 + " ]");
        }else{
          robotAnimation.movementID = animation;
          robotAnimation.isAnimation = true;
          println("robotAnimation.isAnimation: "+robotAnimation.isAnimation);
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