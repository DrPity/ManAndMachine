
class ManageCLE {

  // ------------------------------------------------------------------------------------

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

  // ------------------------------------------------------------------------------------
	
	void mindWave(String data) {
		

	// Sample JSON data:
  	// {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}

		try {
        org.json.JSONObject json = new org.json.JSONObject(data);
        channelsMindwave[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));
      	}
      	catch (JSONException e) {
      	// println(e); 	
      	}   
      

      	try{
      		org.json.JSONObject json = new org.json.JSONObject(data);   
        	org.json.JSONObject esense = json.getJSONObject("eSense");
        	if (esense != null) {
          	channelsMindwave[1].addDataPoint(Integer.parseInt(esense.getString("attention")));
          	channelsMindwave[2].addDataPoint(Integer.parseInt(esense.getString("meditation")));
          	// print(channelsMindwave[1].getLatestPoint().value);
          	isEsenseEvent = true;
        }
        
        org.json.JSONObject eegPower = json.getJSONObject("eegPower");
        
        if (eegPower != null) {
          channelsMindwave[3].addDataPoint(Integer.parseInt(eegPower.getString("delta")));
          channelsMindwave[4].addDataPoint(Integer.parseInt(eegPower.getString("theta"))); 
          channelsMindwave[5].addDataPoint(Integer.parseInt(eegPower.getString("lowAlpha")));
          channelsMindwave[6].addDataPoint(Integer.parseInt(eegPower.getString("highAlpha")));  
          channelsMindwave[7].addDataPoint(Integer.parseInt(eegPower.getString("lowBeta")));
          channelsMindwave[8].addDataPoint(Integer.parseInt(eegPower.getString("highBeta")));
          channelsMindwave[9].addDataPoint(Integer.parseInt(eegPower.getString("lowGamma")));
          channelsMindwave[10].addDataPoint(Integer.parseInt(eegPower.getString("highGamma")));

         	if (isRecording){
  			TableRow newRow = table.addRow();
  			newRow.setInt("ID", table.getRowCount() -1);
         	newRow.setInt("Heart_Rate", receivedHeartRate);
  			newRow.setInt("attention", channelsMindwave[1].getLatestPoint().value);
  			newRow.setInt("meditation", channelsMindwave[2].getLatestPoint().value);
  			newRow.setInt("delta", channelsMindwave[3].getLatestPoint().value);
  			newRow.setInt("theta", channelsMindwave[4].getLatestPoint().value);
  			newRow.setInt("lowAlpha", channelsMindwave[5].getLatestPoint().value);
  			newRow.setInt("highAlpha", channelsMindwave[6].getLatestPoint().value);
  			newRow.setInt("lowBeta", channelsMindwave[7].getLatestPoint().value);
  			newRow.setInt("highBeta", channelsMindwave[8].getLatestPoint().value);
  			newRow.setInt("lowGamma", channelsMindwave[9].getLatestPoint().value);
  			newRow.setInt("highGamma", channelsMindwave[10].getLatestPoint().value);
  			newRow.setInt("timestamp", millis());
          	id =  table.getRowCount() -1;
          	// println("Packeg");
  		  	}

         mindWave.isDataToGraph = true; 
       	}
        
       	 packetCount++;
         for (int i = 0; i < 11; ++i) {
          channelsMindwave[i].graphMe = true; 
         }
       
  	  }
  	  
  	  catch (JSONException e) {
  	    // println ("There was an error parsing the JSONObject." + e);
  	  };
	}

}