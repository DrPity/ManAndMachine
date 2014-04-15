class Robot {

  //List of robot data: x1-10,y1-10,  xx,yy to xx2,yy2, Turn towards or away TT or TA, Open or Close claw OC or CC, Stretch or Contract S or C, Arousal in %, Classification of move <A>, Other: emotions etc
  void moveRobot(int x, int y, boolean turning, boolean claw, boolean stretchOrContract, int arousal){

    // setTraversPosition(x, y);
    // setTurning();
    // setClaw();
    // setStretchOrContract();
    // setArousal();



  }

  /* Inverse Kinematic Arithmetic: X can be + and -; Y and Z only positive. All values in mm! gripperAngleD must be according to the object in degree. gripperwidth in degree. And speed from 0-255 */
  void setRobotArm( float x, float y, float z, float gripperAngleD, int gripperWidth, int light, int easingResolution )
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

  boolean isInRange(float value, float minimum, float maximum)
  {
    if(value >= minimum && value <= maximum)
      return true;
    return false;
  }

  void sendRobotData(int currentBase,int currentShoulder,int currentElbow,int currentWrist,int currentGripperWidth,int currentGripperAngle, int currentLight, int currentEasing){

    myPort.write(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d\n",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentLight, currentEasing));
    // myPort.write(10);
    println(String.format("Rr%d,%d,%d,%d,%d,%d,%d,%d",currentBase, currentShoulder, currentElbow, currentWrist, currentGripperWidth, currentGripperAngle, currentLight, currentEasing));
    isRobotReadyToMove = false;

  }


	
}