class ManageSE {

private boolean isHashtrue = false;
private int heartRate = 0;
private int[] bitArray  = new int[8];
private String  pulseString  = "";
private int lastPulseBit  = 0;
private int counter = 0;

  void arduino(String inChar) {

   // println("In after Null");
    // println(inChar);
    if (isHashtrue){
      println("Hash received");
      String[] s = split(inChar, ',');
      isHashtrue = false;
      if(s[0].trim().equals("1")){
        println("Value of Base: " +  s[1]);
        println("Value of Shoulder: " +  s[2]);
        println("Value of Elbow: " +  s[3]);
        println("Value of Wrist: " +  s[4]);
      }
    }

    if (inChar.trim().equals("W")){
      wA.port.write("W");
      wA.port.write(10);
      println("+ Heartbeat +");
      if(robotConValue != 00){
        robotConValue = 00;
      }
      wA.heartBeat = millis();
      // serialConnection = "Connected";
    }

    if(inChar.trim().equals("N")){
      isRobotReadyToMove = true;
     // println("Robot Ready for Next Position");
    }

    if(!isFirstContact){
      // println("In first contact");
      if (inChar.trim().equals("A")) {
        // serialConnection = "Connected";
        println("Connected");
        isFirstContact = true;
        isRobotReadyToMove = true;
        // delay(200);
        wA.heartBeat = millis();                   
        wA.port.write("B");
        wA.port.write(10);        
      }  
    } 
    else if(inChar.trim().equals("#")){
        isHashtrue = true;
    }
  
  }

  // ------------------------------------------------------------------------------------

  void newPulse(){

     counter++;  
     
     while (wPm.port.available() > 0) {
      // Expand array size to the number of bytes you expect:
      int inByte = wPm.port.read();
      // println(inByte);
      for (int i = 7; i >= 0; i--){ 
        bitArray[i] = bitRead(inByte, i);
      }
    }



      // Check for 3 byte and add 7th bit to byte 4
      if (counter == 2){
        if (bitArray[6] == 1){
          lastPulseBit = 1;
        }else{
          lastPulseBit = 0;
        }
      }
      // Check for 4 byte
      if (counter == 3){
        bitArray[7] = lastPulseBit;
        for(int i = 7; i >= 0; i--){
          pulseString += bitArray[i]; 
        }
        // println("\nPulse String" + pulseString + "\n");
        // println("Pulse: ");
        heartRate = unbinary(pulseString);
        // println(heartRate);
        heartRateString = String.valueOf(heartRate);
        pulseString = "";
        bitArray[7] = 0;
        if (pulsMeterConValue <= 200){
          pulsMeterConValue = 00;
        }
        if(int(heartRateString) == 255){
          pulsMeterConValue = 100;
        }
      }

      // Check for synch bit
     if (bitArray[7] == 1){
      counter = 0;
      }

      wPm.heartBeat = millis();

  }

  // ------------------------------------------------------------------------------------

  int bitRead(int b, int bitPos)
  {
    int x = b & (1 << bitPos);
    return x == 0 ? 0 : 1;
  }
}