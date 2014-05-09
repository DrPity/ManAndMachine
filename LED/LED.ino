


///////REMEMBER TO SET THIS FUCKING VALUE

#define ArduinoB

#ifdef ArduinoB
#define STRIP_PIN_CENTER 2
#define STRIP_PIN_RF 3
#define STRIP_PIN_LF 4
#define STRIP_PIN_ROBOT 5
#define NUMBEROFPIXELSCORNER 107
#define NUMBEROFPIXELSROBOT 40
#define NUMBEROFPIXELSCENTER 116
#define NUMSTRIPS 4
#else
#define STRIP_PIN_LB 2
#define STRIP_PIN_RB 3
#define NUMBEROFPIXELSCORNER 107
#define NUMBEROFPIXELSROBOT 40
#define NUMBEROFPIXELSCENTER 116
#define NUMSTRIPS 2
#endif


#include <Adafruit_NeoPixel.h>
#include "wrapper_class.h"

// // Parameter 1 = number of pixels in strip
// // Parameter 2 = pin number (most are valid)
// // Parameter 3 = pixel type flags, add together as needed:
// //   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
// //   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
// //   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
// //   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
// // Adafruit_NeoPixel stripLB = Adafruit_NeoPixel(NUMBEROFPIXELSCORNER, STRIP_PIN_LB, NEO_GRB + NEO_KHZ800);
// Adafruit_NeoPixel stripRobot = Adafruit_NeoPixel(NUMBEROFPIXELSROBOT, STRIP_PIN_ROBOT, NEO_GRB + NEO_KHZ800);
// Adafruit_NeoPixel stripCenter = Adafruit_NeoPixel(NUMBEROFPIXELSCENTER, STRIP_PIN_CENTER, NEO_GRB + NEO_KHZ800);
// Adafruit_NeoPixel stripRF = Adafruit_NeoPixel(NUMBEROFPIXELSCORNER, STRIP_PIN_RF, NEO_GRB + NEO_KHZ800);
// Adafruit_NeoPixel stripLF = Adafruit_NeoPixel(NUMBEROFPIXELSCORNER, STRIP_PIN_LF, NEO_GRB + NEO_KHZ800);
// // Adafruit_NeoPixel stripRB = Adafruit_NeoPixel(NUMBEROFPIXELSCORNER, STRIP_PIN_RB, NEO_GRB + NEO_KHZ800);


char end                = '\n';
long watchdog;
bool serialReady        = false;
bool watchdogActive     = false;
int parameterArray[5];
int splitArray[5]; 
int connectionTimeOut       =  10;
bool ledsReady              = true;
bool setStrip               = false;
bool positionIsNotRequested = false;
bool startRainbow           = false;
int heartBeat           = 0;
int fadeOutSpeed = 2;
long heartRate          = 0;
long beatTime           = 0;
int rc = 0;
int gc = 0;
int bc = 0;
int rt = 0;
int gt = 0;
int bt = 0;
int beat = 0;
unsigned long beatTimeStamp;
unsigned long loopTime;

uint8_t fadeSpeed        = 4;

String inByte;

Wrapper_class strips[] = {

#ifdef ArduinoB
  Wrapper_class(NUMBEROFPIXELSCENTER, STRIP_PIN_CENTER),
  Wrapper_class(NUMBEROFPIXELSCORNER, STRIP_PIN_RF),
  Wrapper_class(NUMBEROFPIXELSCORNER, STRIP_PIN_LF),
  Wrapper_class(NUMBEROFPIXELSROBOT, STRIP_PIN_ROBOT),
#else
  Wrapper_class(NUMBEROFPIXELSCORNER, STRIP_PIN_RB),
  Wrapper_class(NUMBEROFPIXELSCORNER, STRIP_PIN_LB),
#endif


};


void setup() {
  Serial.begin(115200);
  for (int i = 0; i < NUMSTRIPS; ++i)
  {
    strips[i].init();
  }
establishContact();
}

int d = 0;
void loop() {



  if (Serial.available() > 0){
    // Serial.println("Serial available");
    inByte = Serial.readStringUntil(end);
    inByte.trim();
    
    if(inByte.equals("B") == true){
    serialReady = true;
    }

    if(inByte.equals("W") == true){

      connectionTimeOut ++;

    }

    if(inByte.indexOf('C') == 0 && inByte.indexOf('c') == 1){
      // Serial.println("before split");
      if(true || millis() - beatTimeStamp > 500){
        beatTimeStamp = millis();
        setColor(inByte);
      }
      

      // sendConfirmationData(1, x, y, z, wrist, gripperAngle, gripper, light);
      // Serial.println("after split");
       
    }
    if(inByte.indexOf('T') == 0 && inByte.indexOf('t') == 1){
      // Serial.println("before split");
      setTargetColor(inByte);
      // sendConfirmationData(1, x, y, z, wrist, gripperAngle, gripper, light);
      // Serial.println("after split");
       
    }

  }
  // Serial.println("After serial");
  
  if (!watchdogActive){
    // Serial.println("activating watchdog");
    watchdog = millis();
    watchdogActive = true;

  }else if ((millis() - watchdog) >= 2000){
        watchdogCall();
    }

  if (connectionTimeOut <= 0){

    //Serial.println("TimeOut");
  }

   if(startRainbow){
    // Serial.println("In rainbow");
    if(millis() - loopTime >= 60){
      for (int i = 0; i < NUMSTRIPS; i++){
        strips[i].rainbowCycle(20);
      }
      loopTime = millis();
    }
  }


  if(fadeSpeed > 0 && beat == 1){
    setStrip = true;
    // Serial.println("Before fadeOut");
    for(int i = 0; i < NUMSTRIPS; i++){
      fadeOut(i);
    }  
  }

  // else if(positionIsNotRequested){
  //   // requestNextPosition();
  //   positionIsNotRequested = false;
  // }


  if(setStrip){
  showStrips();
  setStrip = false;
  }

}


void showStrips(){
  for(int i = 0; i < NUMSTRIPS; i++){
    strips[i].show();
  }
}


int setColor(String inByte){

  for (int i = 0; i < 5; i++){
    if(i == 0){
      splitArray[i] = inByte.indexOf(',');
      parameterArray[i] = inByte.substring(2,splitArray[i]).toInt();
    }else if(i > 0){
      splitArray[i] = inByte.indexOf(',', splitArray[i-1] + 1);
      parameterArray[i] = inByte.substring(splitArray[i-1] +1,splitArray[i]).toInt();
    }
  }
  
  int strip          = parameterArray[0];
      rc             = parameterArray[1];
      gc             = parameterArray[2];
      bc             = parameterArray[3];
      beat           = parameterArray[4];
  // heartRate     = parameterArray[3];

  // Serial.println("Splitted Strings");
  Serial.println(strip);
  Serial.println(rc);
  Serial.println(gc);
  Serial.println(bc);
  Serial.println(beat);
  // Serial.println(heartRate);;

  positionIsNotRequested = true;
  if(strip == 0){
    for(int i = 0; i < NUMSTRIPS; i++){
     strips[i].setStripColor(rc,gc,bc);
    }
  }

  if(strip > 0 && strip < 9){
    strips[strip - 1].setStripColor(rc,gc,bc);
  }

  if(strip == 9){
    // Serial.print("Rainbow set to true");
    startRainbow = true;
    loopTime = millis();
  }

  if(strip == 10){
    startRainbow = false;
     for(int i = 0; i < NUMSTRIPS; i++){
     strips[i].setStripColor(rc,gc,bc);
    }
  }

  setStrip = true;
  // positionIsNotRequested = true;
}

int setTargetColor(String inByte){

  for (int i = 0; i < 4; i++){
    if(i == 0){
      splitArray[i] = inByte.indexOf(',');
      parameterArray[i] = inByte.substring(2,splitArray[i]).toInt();
    }else if(i > 0){
      splitArray[i] = inByte.indexOf(',', splitArray[i-1] + 1);
      parameterArray[i] = inByte.substring(splitArray[i-1] +1,splitArray[i]).toInt();
    }
  }
  

  int strip      = parameterArray[0];
  rt             = parameterArray[1];
  gt             = parameterArray[2];
  bt             = parameterArray[3];


  Serial.println("Splitted Strings");
  Serial.println(strip);
  Serial.println(rt);
  Serial.println(gt);
  Serial.println(bt);

  if(strip == 0){
    for(int i = 0; i < NUMSTRIPS; i++){
      strips[i].targetColorR = rt;
      strips[i].targetColorG = gt;
      strips[i].targetColorB = bt;
    }
  }else{
    strips[strip - 1].targetColorR = rt;
    strips[strip - 1].targetColorG = gt;
    strips[strip - 1].targetColorB = bt;
  }

  // positionIsNotRequested = true;

}


// ------------------------------------------------------------------------------------

void requestNextPosition(){

  Serial.print("N");
  Serial.println();
}

// ------------------------------------------------------------------------------------

void watchdogCall() {
    Serial.print("W");   // send a capital A
    Serial.println();
    connectionTimeOut --;
    // delay(30);
    watchdogActive = false;
}  

// ------------------------------------------------------------------------------------

void establishContact() {
   // Serial.println("Hello World...");
  delay(1000);  // do not print too fast!
  while (Serial.available() <= 0 && !serialReady) {
    Serial.print("A");   // send a capital A
    Serial.println();
    ledsReady = true;
    delay(300);
  }

}


void fadeOut(int k){
    for(int i = 0; i < strips[k].getNumPixels(); i++){
      uint32_t color = strips[k].getPixelColor(i);

      int
      r = (uint8_t)(color >> 16),
      g = (uint8_t)(color >>  8),
      b = (uint8_t)color;

      // if(fadeOutSpeed > r){
      //   r = 33;
      // }else{
      //   r -= fadeOutSpeed;
      // }

      // if(fadeOutSpeed > g){
      //   g = 33;
      // }else{
      //   g -= fadeOutSpeed;
      // }

      // if(fadeOutSpeed > b){+
      //   b = 33;
      // }else{
      //   b -= fadeOutSpeed;
      // }

      // if(fadeSpeed >= abs(strips[0].targetColorR - r)){
      //   r = strips[0].targetColorR;
      // }else if(r < strips[0].targetColorR){
      //   r = r+fadeSpeed
      // }

      r = (fadeSpeed >= abs(strips[k].targetColorR - r))?strips[k].targetColorR:r<strips[k].targetColorR?r+fadeSpeed:r-fadeSpeed;
      g = (fadeSpeed >= abs(strips[k].targetColorG - g))?strips[k].targetColorG:g<strips[k].targetColorG?g+fadeSpeed:g-fadeSpeed;
      b = (fadeSpeed >= abs(strips[k].targetColorB - b))?strips[k].targetColorB:b<strips[k].targetColorB?b+fadeSpeed:b-fadeSpeed;

      if(r == strips[k].targetColorR && g == strips[k].targetColorG && b == strips[k].targetColorB){
          beat = 0;
          // Serial.println("Beat is 0");
          // Serial.println(k);
          // if(positionIsNotRequested){
          //   requestNextPosition();
          // }
      }    


      strips[k].setPixelColor(i, r, g, b);
    }
    // delay(20);
}
