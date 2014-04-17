class HelperClass {

  public void BeginRecording() {
    isRecording = true;
    recordColor = color(255, 0, 0);
   println("a button event from Start_Recording: ");
    table = new Table();
    table.addColumn("ID");
    table.addColumn("Heart_Rate");
    table.addColumn("attention");
    table.addColumn("meditation");
    table.addColumn("delta");
    table.addColumn("theta");
    table.addColumn("lowAlpha");
    table.addColumn("highAlpha");
    table.addColumn("lowBeta");
    table.addColumn("highBeta");
    table.addColumn("lowGamma");
    table.addColumn("highGamma");
    table.addColumn("timestamp");
}

// ------------------------------------------------------------------------------------

  public void EndRecording() {
    if(isReadyToRecord){
      println("a button event from Stop_Recording: ");
      saveTable(table, String.format("data/recording_%d.csv", tableIndex), "csv");
      println("isRecording Stoped!!");
      tableIndex ++;
      isRecording = false;
      recordColor = color(127, 127, 127);
    }
  }

// ------------------------------------------------------------------------------------  
// Extend core's Map function to the Long datatype.

  long mapLong(long x, long in_min, long in_max, long out_min, long out_max)  { 
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min; 
  }

// ------------------------------------------------------------------------------------

  long constrainLong(long value, long min_value, long max_value) {
    if(value > max_value) return max_value;
    if(value < min_value) return min_value;
    return value;
  }

// ------------------------------------------------------------------------------------

  void checkSerialPorts(){
   for (int i = 0; i < Serial.list().length; i++) {
       println("[" + i + "] " + Serial.list()[i]);
       // Flag serial ports as true
       if(Serial.list()[i].equals(pulseMeterPort)){
         isPulseMeterPort = true;
       }else if (Serial.list()[i].equals(arduinoPort)){
         isArduinoPort = true;
       }
    }
  }  
	
}