class Drawings  {
  Textarea consolTextArea;
  RadioButton toggleTestMode;

  private int sF = 1; //scaleFactor

  void drawLine(int x1, int y1, int x2, int y2, int th){
    
    pushMatrix();
    stroke(0);
    strokeWeight(th);  // Thicker
    line(x1, y1, x2, y2);
    popMatrix();
  }

  // ------------------------------------------------------------------------------------

  void drawRectangle(int x1, int y1, int x2, int y2, int tx, int ty, int f1, int f2, int f3, int fa){
    pushMatrix();
    translate(tx,ty);
    fill(f1, f2, f3, fa);
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
    PFont fontHeadline_3 = createFont("ProximaNova-Light",20);
    PFont fontHeadLableBig = createFont("ProximaNova-Thin",80);

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
  
  controlP5.addButton("X+")
    .setValue(0)
    .setCaptionLabel("X+")
    .setSize(round(30),round(30))
    .setPosition(440,round(height * 0.55))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("X-")
    .setValue(0)
    .setCaptionLabel("X-")
    .setSize(round(30),round(30))
    .setPosition(440,round(height * 0.60))
    .setColorBackground(color(0, 200, 0))
    ;
  
  controlP5.addButton("Y+")
    .setValue(0)
    .setCaptionLabel("Y+")
    .setSize(round(30),round(30))
    .setPosition(490,round(height * 0.55))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("Y-")
    .setValue(0)
    .setCaptionLabel("Y-")
    .setSize(round(30),round(30))
    .setPosition(490,round(height * 0.60))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("Z+")
    .setValue(0)
    .setCaptionLabel("Z+")
    .setSize(round(30),round(30))
    .setPosition(540,round(height * 0.55))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("Z-")
    .setValue(0)
    .setCaptionLabel("Z-")
    .setSize(round(30),round(30))
    .setPosition(540,round(height * 0.60))
    .setColorBackground(color(0, 200, 0))
    ;
  
  controlP5.addButton("GA+")
    .setValue(0)
    .setCaptionLabel("GA+")
    .setSize(round(30),round(30))
    .setPosition(590,round(height * 0.55))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("GA-")
    .setValue(0)
    .setCaptionLabel("GA-")
    .setSize(round(30),round(30))
    .setPosition(590,round(height * 0.60))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("GC+")
  .setValue(0)
  .setCaptionLabel("GC+")
  .setSize(round(30),round(30))
  .setPosition(640,round(height * 0.55))
  .setColorBackground(color(0, 200, 0))
  ;

  controlP5.addButton("GC-")
    .setValue(0)
    .setCaptionLabel("GC-")
    .setSize(round(30),round(30))
    .setPosition(640,round(height * 0.60))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("GR+")
    .setValue(0)
    .setCaptionLabel("GR+")
    .setSize(round(30),round(30))
    .setPosition(690,round(height * 0.55))
    .setColorBackground(color(0, 200, 0))
    ;

  controlP5.addButton("GR-")
    .setValue(0)
    .setCaptionLabel("GR-")
    .setSize(round(30),round(30))
    .setPosition(690,round(height * 0.60))
    .setColorBackground(color(0, 200, 0))
    ;  
  // controlP5.addButton("loadBtnDefault")
  //   .setValue(0)
  //   .setCaptionLabel("load Default")
  //   .setSize(round(100),round(20))
  //   .setPosition(round(20),round(height * 0.51))
  //   .setColorActive(127)
  //   .setColorBackground(color(200, 130, 0))
  //   ;

  // controlP5.addButton("loadBtnLastPosition")
  //   .setValue(0)
  //   .setCaptionLabel("load last Position")
  //   .setSize(round(100),round(20))
  //   .setPosition(round(140),round(height * 0.51))
  //   .setColorCaptionLabel(0) 
  //   .setColorValueLabel(127)
  //   .setColorBackground(color(200, 130, 0))
  //   ;
  
  // controlP5.addButton("Start_Robot")
  //  .setValue(0)
  //  .setCaptionLabel("START ROBOT")
  //  .setPosition(round(500),round(height * 0.42))
  //  .setSize(round(100),round(20))
  //  ;
  
  // controlP5.addButton("Reset_Robot")
  //  .setValue(0)
  //  .setCaptionLabel("RESET ROBOT")
  //  .setPosition(round(width*0.3),round(height * 0.44))
  //  .setSize(round(100),round(20))
  //  ;
     
  controlP5.addButton("Back")
   .setValue(0)
   .setCaptionLabel("Back")
   .setPosition(round(width*0.09),round(height * 0.53))
   .setSize(round(100*sF),round(20*sF))
   ;

   controlP5.addButton("Forward")
   .setValue(0)
   .setCaptionLabel("Forward")
   .setPosition(round(width*0.15),round(height * 0.53))
   .setSize(round(100*sF),round(20*sF))
   ;

  // toggleTestMode = controlP5.addRadioButton("testMode")
  //        .setPosition(round(20),round(height * 0.458))
  //        .setSize(round(20),round(10))
  //        .setColorForeground(color(120))
  //        .setColorActive(color(0,190,0))
  //        .setColorLabel(color(255,0,0))
  //        .addItem("Toggle Test Mode",1)
  //        ;      

// ------------------------------------------------------------------------------------

// -------------    Mindwave Lables   ---------------------

  textMindwave = controlP5.addTextlabel("label2")
              .setText("MINDWAVE")
              .setPosition(round(width*0.01),round(height*0.08))
              .setColor(0)
              .setFont(fontSmallBold)
              .setLetterSpacing(110);
              ;
  attentionLevel = controlP5.addTextlabel("attentionLevel")
              .setText("Attention Level:")
              .setPosition(round(width*0.07),round(height*0.08))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  attentionValue = controlP5.addTextlabel("attentionValue")
              .setText("Na")
              .setPosition(round(width*0.125),round(height*0.076))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;
  meditationLevel = controlP5.addTextlabel("meditationLevel")
              .setText("Meditation Level:")
              .setPosition(round(width*0.15),round(height*0.08))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  meditationValue = controlP5.addTextlabel("meditationValue")
              .setText("Na")
              .setPosition(round(width*0.21),round(height*0.076))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;
  blinkStrength = controlP5.addTextlabel("blinkStrength")
              .setText("Blink Strength:")
              .setPosition(round(width*0.235),round(height*0.08))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  blinkValue = controlP5.addTextlabel("blinkValue")
              .setText("Na")
              .setPosition(round(width*0.287),round(height*0.076))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;

// -------------    Pulsemeter Lables   ---------------------

  textPulseMeter = controlP5.addTextlabel("pulseMeter")
              .setText("PULSEMETER")
              .setPosition(round(width*0.01),round(height*0.18))
              .setColor(0)
              .setFont(fontSmallBold)
              .setLetterSpacing(110);
              ;
  pulseLevel = controlP5.addTextlabel("pulseLevel")
              .setText("Pulse:")
              .setPosition(round(width*0.07),round(height*0.18))
              .setColor(0)
              .setFont(fontSmallLight)
              ;
  pulseValue = controlP5.addTextlabel("pulseValue")
              .setText("Na")
              .setPosition(round(width*0.095),round(height*0.176))
              .setColor(0)
              .setFont(fontHeadline_3)
              ;                          

// -------------    HeadLines   ---------------------

  headlineText_1 = controlP5.addTextlabel("label4")
                  .setText("ROBOT CONTROLS: ")
                  .setPosition(round(width*0.01),round(height * 0.42))
                  .setColorValue(255)
                  .setFont(fontHeadline)
                  ;
 
  // headlineText_2 = controlP5.addTextlabel("label5")
  //               .setText("ROBOT CONTROLS: ")
  //               .setPosition(round(490),round(height * 0.42))
  //               .setColorValue(255)
  //               .setFont(fontHeadline_2)
  //               ;



  controlP5.addTextfield("Set Global ID - [ ENTER ]")
                .setPosition(round(width*0.09),round(height * 0.49))
                .setSize(150,20)
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

  controlP5.addFrameRate().setInterval(10).setColor(0).setPosition(round(10),height - round(30)).setFont(fontSmallLight);
  // console = controlP5.addConsole(consolTextArea);              


   lableID = controlP5.addTextlabel("lableID")
                .setText("global ID")
                .setPosition(round(width*0.01),round(height * 0.44))
                .setColorValue(255)
                .setFont(fontHeadLableBig)
                ;
    textID = controlP5.addTextlabel("label7")
                .setText("ID")
                .setPosition(round(width*0.02),round(height*0.53))
                .setColorValue(255)
                .setFont(fontHeadline)
                ;                     


  }

}



