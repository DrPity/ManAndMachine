class Drawings  {


  void drawLine(int x1, int y1, int x2, int y2){
    
    pushMatrix();
    stroke(0);
    strokeWeight(2);  // Thicker
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
  
  controlP5.addButton("Start_Robot")
     .setValue(0)
     .setPosition(20,round(height * 0.42))
     .setSize(100,20)
     ;
  
  controlP5.addButton("Reset_Robot")
   .setValue(0)
   .setPosition(20,round(height * 0.44))
   .setSize(100,20)
   ;
     
  controlP5.addButton("Test_Movement")
   .setValue(0)
   .setPosition(20,round(height * 0.46))
   .setSize(100,20)
   ;     

  lableHeartRate = controlP5.addTextlabel("lable")
                    .setText(heartRateString)
                    .setPosition(10,160)
                    .setColorValue(255)
                    .setFont(createFont("Helvetica",100));
  textHeartRate = controlP5.addTextlabel("label2")
                  .setText("Heart Rate")
                  .setPosition(15,260)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",16));


  timerLable = controlP5.addTextlabel("lable2")
                  .setText("00.00")
                  .setPosition(10,20)
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",50))
                  ;


  fRate = controlP5.addTextlabel("lable3")
                  .setText("00")
                  .setPosition(10,round(height * 0.93))
                  .setColorValue(255)
                  .setFont(createFont("Helvetica",12))
                  ;



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



