
class ManageCLE {

  void connectToMindWave(PApplet p){
      // Connect to ThinkGear socket (default = 127.0.0.1:13854)
      // By default, Thinkgear only binds to localhost:
      // To allow other hosts to connect and run Processing from another machine, run ReplayTCP (http://www.dlcsistemas.com/html/relay_tcp.html)
      // OR, use netcat (windows or mac) to port forard (clients can now connect to port 13855).  Ex:  nc -l -p 13855 -c ' nc localhost 13854'
      
      String thinkgearHost = "127.0.0.1";
      int thinkgearPort = 13854;
      
      String envHost = System.getenv("THINKGEAR_HOST");
      if (envHost != null) {
        thinkgearHost = envHost;
      }
      String envPort = System.getenv("THINKGEAR_PORT");
      if (envPort != null) {
         thinkgearPort = Integer.parseInt(envPort);
      }
     
      println("Connecting to host = " + thinkgearHost + ", port = " + thinkgearPort);
      myClient = new Client(p, thinkgearHost, thinkgearPort);
      String command = "{\"enableRawOutput\": false, \"format\": \"Json\"}\n";
      print("Sending command");
      println (command);
      myClient.write(command);


  }
	
	void mindWave(String data) {
		

	// Sample JSON data:
  	// {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}

		try {
        org.json.JSONObject json = new org.json.JSONObject(data);
        channels[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));
      	}
      	catch (JSONException e) {
      	// println(e); 	
      	}   
      

      	try{
      		org.json.JSONObject json = new org.json.JSONObject(data);   
        	org.json.JSONObject esense = json.getJSONObject("eSense");
        	if (esense != null) {
          	channels[1].addDataPoint(Integer.parseInt(esense.getString("attention")));
          	channels[2].addDataPoint(Integer.parseInt(esense.getString("meditation")));
          	// print(channels[1].getLatestPoint().value);
          	isEsenseEvent = true;
        }
        
        org.json.JSONObject eegPower = json.getJSONObject("eegPower");
        
        if (eegPower != null) {
          channels[3].addDataPoint(Integer.parseInt(eegPower.getString("delta")));
          channels[4].addDataPoint(Integer.parseInt(eegPower.getString("theta"))); 
          channels[5].addDataPoint(Integer.parseInt(eegPower.getString("lowAlpha")));
          channels[6].addDataPoint(Integer.parseInt(eegPower.getString("highAlpha")));  
          channels[7].addDataPoint(Integer.parseInt(eegPower.getString("lowBeta")));
          channels[8].addDataPoint(Integer.parseInt(eegPower.getString("highBeta")));
          channels[9].addDataPoint(Integer.parseInt(eegPower.getString("lowGamma")));
          channels[10].addDataPoint(Integer.parseInt(eegPower.getString("highGamma")));

         	if (isRecording){
  			TableRow newRow = table.addRow();
  			newRow.setInt("ID", table.getRowCount() -1);
         	newRow.setInt("Heart_Rate", heartRate);
  			newRow.setInt("attention", channels[1].getLatestPoint().value);
  			newRow.setInt("meditation", channels[2].getLatestPoint().value);
  			newRow.setInt("delta", channels[3].getLatestPoint().value);
  			newRow.setInt("theta", channels[4].getLatestPoint().value);
  			newRow.setInt("lowAlpha", channels[5].getLatestPoint().value);
  			newRow.setInt("highAlpha", channels[6].getLatestPoint().value);
  			newRow.setInt("lowBeta", channels[7].getLatestPoint().value);
  			newRow.setInt("highBeta", channels[8].getLatestPoint().value);
  			newRow.setInt("lowGamma", channels[9].getLatestPoint().value);
  			newRow.setInt("highGamma", channels[10].getLatestPoint().value);
  			newRow.setInt("timestamp", millis());
          	id =  table.getRowCount() -1;
          	// println("Packeg");
  		  	}

         isDataToGraph = true; 
       	}
        
       	 packetCount++;
         for (int i = 0; i < 11; ++i) {
          channels[i].graphMe = true; 
         }
       
  	  }
  	  
  	  catch (JSONException e) {
  	    // println ("There was an error parsing the JSONObject." + e);
  	  };
	}

}