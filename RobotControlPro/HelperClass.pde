class HelperClass {

  public void beginRecording() {
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

  public void endRecording() {
    if(isReadyToRecord){
      println("a button event from Stop_Recording: ");
      saveTable(table, String.format("data/recording_%d.csv", tableIndex), "csv");
      println("isRecording Stoped!!");
      tableIndex ++;
      isRecording = false;
      recordColor = color(127, 127, 127);
    }
  }

//List of robot data: x1-10,y1-10,  xx,yy to xx2,yy2, Turn towards or away TT or TA, Open or Close claw OC or CC, Stretch or Contract S or C, Arousal in %, Classification of move <A>, Other: emotions etc
public void newStorePositionTable() {
  isStoring = true;
  tableRm = new Table();
  tableRm.addColumn("ID");
  tableRm.addColumn("X");
  tableRm.addColumn("Y");
  tableRm.addColumn("Z");
  tableRm.addColumn("GripperAngle");
  tableRm.addColumn("GripperWidth");
  tableRm.addColumn("EyeColor");
  tableRm.addColumn("Easing");
  tableRm.addColumn("X1");
  tableRm.addColumn("Y1");
  tableRm.addColumn("Turning");
  tableRm.addColumn("Claw");
  tableRm.addColumn("Streching");
  tableRm.addColumn("Arousal");
}

public void storePositionToTable(int x, int y, int z, int gripperAngle, int gripperWidth, int eyeColor, int easing, int x1, int y1, int turning, int claw, int streching, int arousal){

  TableRow newRow = tableRm.addRow();
  newRow.setInt("ID", tableRm.getRowCount() -1);
  newRow.setInt("X", x);
  newRow.setInt("Y", y);
  newRow.setInt("Z", z);
  newRow.setInt("GripperAngle", gripperAngle);
  newRow.setInt("GripperWidth", gripperWidth);
  newRow.setInt("EyeColor", eyeColor);
  newRow.setInt("Easing", easing);
  newRow.setInt("X1", x1);
  newRow.setInt("Y1", y1);
  newRow.setInt("Turning", turning);
  newRow.setInt("Claw", claw);
  newRow.setInt("Streching", streching);
  newRow.setInt("Arousal", arousal);
  storingID =  tableRm.getRowCount() -1;
  println("Movement Stored");
}




public void EndStoring() {
    if(isReadyToStore){
      saveTable(table, String.format("data/RobotMovements.csv"), "csv");
      println("Storing finished");
      tableIndexStoring ++;
      isStoring = false;
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