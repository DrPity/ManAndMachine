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

private int       verifCounter          = 0;

private float     lastX             = 0;
private float     lastY             = 0;
private float     lastZ             = 0;
private float     lastGripperAngle  = 0;
private float     lastGripperWidth  = 0;

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
    
    println("Percentage: " + percentage);
    int strechedPosition = (int) map(percentage, 0, 100, 0, 349);
    // println("( Streched position in strechedPosition: )" + strechedPosition);
    // println("( Streched position in strechedPosition: )" + strechedPosition + " " + lastX + " " + lastY + " " + lastZ + " " + lastGripperAngle);

    if(!isStrRun){
      isStrRun = true;
      // printArray(strArray);
      if(strechedPosition > lastY){
        int k = findUpperBound(strechedPosition);
        isStrRun = false;
        return k;
      }else if(strechedPosition < lastY){
        int k = findLowerBound(strechedPosition);
        isStrRun = false;
        return k;
      }
    }
  isStrRun = false;  
  return (int) lastY; 
  }



// // ------------------------------------------------------------------------------------

  /* Inverse Kinematic Arithmetic: X can be + and -; Y and Z only positive. All values in mm! gripperAngleD must be according to the object in degree. gripperwidth in degree. And speed from 0-255 */
  void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperWidth, int light, int easingResolution, boolean sendData ){

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
        && isInRange(elbowAngleD, 0, 180) && isInRange(wristAngleD, 0, 180) && isInRange(gripperAngleD, 0, 180) && isInRange(gripperWidth, 0, 180)){
        isDataVerified = true;
        println("( Data verfied )");
        if (!sendData){
          validStrPos = true;
        }

      }else{
        isDataVerified = false;
        println("[ Data not verified ]");
      }

      // println("x,y,z: " +  x + " " +  y + " " + z);

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
     

      if(isDataVerified && sendData){
        sendRobotData( currentBase, currentShoulder, currentElbow, currentWrist, currentGripperAngle, currentGripperWidth, currentLight, currentEasing);
        lastX = x;
        lastY = y;
        lastZ = z;
        lastGripperAngle = gripperAngleD;
        lastGripperWidth = gripperWidth;
        println("Data verified and send");
        isDataVerified = false;
      }
    }

  }

// // ------------------------------------------------------------------------------------

  boolean isInRange(float value, float minimum, float maximum)
  {
    if(value >= minimum && value <= maximum)
      return true;
    return false;
  }

// // ------------------------------------------------------------------------------------

  void sendRobotData(int currentBase, int currentShoulder, int currentElbow, int currentWrist, int currentGripperAngle, int currentGripperWidth, int currentLight, int currentEasing){

    if(isArduinoPort)
    wA.port.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperAngle, currentGripperWidth, currentLight, currentEasing));
    // wA.port.write(10);
    println(String.format("(Rr%d,%d,%d,%d,%d,%d,%d,%d)",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperAngle, currentGripperWidth, currentLight, currentEasing));
    isRobotReadyToMove = false;

  }


  int findLowerBound(int strechedPosition){
    for(int i = strechedPosition; i <= 349; i++){
    setRobotArm(lastX, i, lastZ, lastGripperAngle, (int) lastGripperWidth, speed, 1, false);
      if(validStrPos){
        validStrPos = false;
        return i;
      }
    }
  validStrPos = false;
  return (int) lastY;
  }


  int findUpperBound(int strechedPosition){
    for(int i = strechedPosition; i >= 0; i--){
    setRobotArm(lastX, i, lastZ, lastGripperAngle, (int) lastGripperWidth, speed, 1, false); 
      if(validStrPos){
        validStrPos = false;
        return i;
      }

    }
  validStrPos = false;
  return (int) lastY;
  }

}  