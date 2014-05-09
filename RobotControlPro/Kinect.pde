import processing.core.PApplet.*;
import SimpleOpenNI.*;

// ------------------------------------------------------------------------------------

public class Kinect extends PApplet{

SimpleOpenNI  context;
int w, h;
int abc = 100;
float zValueKinectR = 0;
float xValueKinectR = 0;
float zValueKinectT = 0;
float xValueKinectT = 0;
float oldXValueKinectT = 0;
float oldZValueKinectT = 0;
boolean kinectValueAvailable = false;
boolean zPositionUpdatedT = false;
boolean xPositionUpdatedT = false;

// ------------------------------------------------------------------------------------

  void setup()
  {


    context = new SimpleOpenNI(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
     if(context.isInit() == false)
    {
       println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
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

// ------------------------------------------------------------------------------------
   
  void draw()
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
// ------------------------------------------------------------------------------------ 
// draws a circle at the position of the head

  void circleForAHead(int userId)
  {
    // get 3D position of a joint
    PVector jointPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,jointPos);


    // println("X: " + jointPos.x + " Y:" + jointPos.y + " Z: " + jointPos.z);

   
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

    // println("X: " + jointPos_Proj.x + " Y: " + jointPos_Proj.y + " Z: " + jointPos_Proj.z);

    if(jointPos_Proj.z > 848 && jointPos_Proj.z < 3300){
      kinectValueAvailable = true;
      zValueKinectR = map(jointPos_Proj.z,848, 3300,-70, -340);
      oldZValueKinectT = zValueKinectT;
      if(abs(oldZValueKinectT - map(jointPos_Proj.z,848, 3300,0, 2000)) > 100){
        zValueKinectT = map(jointPos_Proj.z,848, 3300,0, 2000);
        zPositionUpdatedT = true;
      }
    } 
    if(jointPos_Proj.x > 0 && jointPos_Proj.x < 600){
      kinectValueAvailable = true;
      xValueKinectR = map(jointPos_Proj.x,0, 600,0, 200);
      oldXValueKinectT = xValueKinectT;
      if(abs(oldXValueKinectT - map(jointPos_Proj.x,0, 600,0, 2000)) > 10){
        xValueKinectT = map(jointPos_Proj.x,0, 600,0, 2000);
        xPositionUpdatedT = true;
      }
    }
    else
      kinectValueAvailable = false;
  }

// ------------------------------------------------------------------------------------
// when a person ('user') enters the field of view

  void onNewUser(SimpleOpenNI curContext,int userId)
  {
    println("New User Detected - userId: " + userId);
   
   // start pose detection
    curContext.startTrackingSkeleton(userId);
  }

// ------------------------------------------------------------------------------------    
// when a person ('user') leaves the field of view 

  void onLostUser(int userId)
  {
    println("User Lost - userId: " + userId);
  }

// ------------------------------------------------------------------------------------

  public Kinect(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

// ------------------------------------------------------------------------------------

  public ControlP5 control() {
    return controlP5;
  }



  // ControlP5 controlP5;

  Object parent;
  
}

 
