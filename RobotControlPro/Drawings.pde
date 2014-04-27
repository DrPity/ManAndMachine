class Drawings  {
Textarea consolTextArea;
RadioButton toggleTestMode;

  void drawLine(int x1, int y1, int x2, int y2, int th){
    
    pushMatrix();
    stroke(0);
    strokeWeight(th);  // Thicker
    line(x1, y1, x2, y2);
    popMatrix();
  }

  // ------------------------------------------------------------------------------------

  void drawRectangle(int x1, int y1, int x2, int y2, int tx, int ty, int f, int fa){
    pushMatrix();
    translate(tx,ty);
    fill(f, fa);
    rect(x1, y1, x2, y2);
    popMatrix();
  }

  // ------------------------------------------------------------------------------------

  void Draw_Elipse(int x, int y, int dx, int dy){
    fill(recordColor);
    ellipseMode(CORNER);
    ellipse(x, y, dx, dy);

  }

  // ------------------------------------------------------------------------------------

  void CP5Init(){
  PFont fontSmallBold = createFont("ProximaNova-Bold",15);
  PFont fontSmallLight = createFont("ProximaNova-Light",15);
  PFont fontHeadline = createFont("ProximaNova-Thin",20);
  PFont fontHeadline_2 = createFont("ProximaNova-Bold",20);
  PFont fontHeadLableBig = createFont("ProximaNova-Thin",100);

  // fontHeadline

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
  
  controlP5.addButton("saveBtn")
    .setValue(0)
    .setCaptionLabel("save Values")
    .setSize(100,20)
    .setPosition(260,round(height * 0.47))
    .setColorBackground(color(0, 200, 0))
    ;

  
  controlP5.addButton("loadBtnDefault")
    .setValue(0)
    .setCaptionLabel("load Default")
    .setSize(100,20)
    .setPosition(20,round(height * 0.51))
    .setColorActive(127)
    .setColorBackground(color(200, 130, 0))
    ;

  controlP5.addButton("loadBtnLastPosition")
    .setValue(0)
    .setCaptionLabel("load last Position")
    .setSize(100,20)
    .setPosition(140,round(height * 0.51))
    .setColorCaptionLabel(0) 
    .setColorValueLabel(127)
    .setColorBackground(color(200, 130, 0))
    ;
  
  controlP5.addButton("Start_Robot")
   .setValue(0)
   .setCaptionLabel("START ROBOT")
   .setPosition(500,round(height * 0.42))
   .setSize(100,20)
   ;
  
  controlP5.addButton("Reset_Robot")
   .setValue(0)
   .setCaptionLabel("RESET ROBOT")
   .setPosition(500,round(height * 0.44))
   .setSize(100,20)
   ;
     
  controlP5.addButton("Test_Movement")
   .setValue(0)
   .setCaptionLabel("TEST MOVEMENT")
   .setPosition(500,round(height * 0.46))
   .setSize(100,20)
   ;

  toggleTestMode = controlP5.addRadioButton("testMode")
         .setPosition(20,round(height * 0.458))
         .setSize(20,10)
         .setColorForeground(color(120))
         .setColorActive(color(0,190,0))
         .setColorLabel(color(255,0,0))
         .addItem("Toggle Test Mode",1)
         ;      

// ------------------------------------------------------------------------------------

  lableHeartRate = controlP5.addTextlabel("lable")
                  .setText(heartRateString)
                  .setPosition(10,160)
                  .setColorValue(255)
                  .setFont(fontHeadLableBig)
                  ;

  textHeartRate = controlP5.addTextlabel("label2")
                  .setText("Heart Rate")
                  .setPosition(15,260)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",16))
                  ;

  timerLable = controlP5.addTextlabel("lable3")
                  .setText("00.00")
                  .setPosition(10,20)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",50))
                  ;
  headlineText_1 = controlP5.addTextlabel("label4")
                  .setText("ROBOT CONTROLS: ")
                  .setPosition(15,round(height * 0.42))
                  .setColorValue(255)
                .setFont(fontHeadline);
 
  headlineText_2 = controlP5.addTextlabel("label5")
                .setText("ROBOT CONTROLS: ")
                .setPosition(490,round(height * 0.42))
                .setColorValue(255)
                .setFont(fontHeadline_2);



  controlP5.addTextfield("Enter Robot Position - Press [ ENTER ] to test")
                .setPosition(20,round(height * 0.47))
                .setSize(220,20)
                .setFont(fontSmallBold)
                .setFocus(true)
                .setColorActive(0)
                .setColorValue(255)
                .setColorBackground(color(255, 255))
                 ;

  // consolTextArea = controlP5.addTextarea("txt")
  //                 .setPosition(10, round(height * 0.80))
  //                 .setSize(200, 200)
  //                 .setFont(createFont("", 10))
  //                 .setLineHeight(14)
  //                 .setColor(color(200))
  //                 .setColorBackground(color(0, 100))
  //                 .setColorForeground(color(255, 100))

  controlP5.addFrameRate().setInterval(10).setColor(0).setPosition(10,height - 30).setFont(fontSmallLight);
  // console = controlP5.addConsole(consolTextArea);              


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



