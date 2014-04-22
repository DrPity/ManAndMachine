class WatchDog extends Thread{

boolean running;           // Is the thread running?  Yes or no?
boolean deviceInstanciated;
boolean deviceLost;
String devicePort;
boolean buffer;
boolean isPort;
long    heartBeat;
int 	bautRate;
Serial 	port;
PApplet p;
int 	wait;                  // How many milliseconds should we wait in between executions?
String 	id;                 // Thread name
 
// ------------------------------------------------------------------------------------

  // Constructor, create the thread
  // It is not running by default
  WatchDog (int _w, String _id, String _devicePort, boolean _buffer, boolean _isPort, int _bautRate, PApplet _p) {
    wait = _w;
    p = _p;
    running = false;
    deviceInstanciated = false;
    deviceLost = false;
    devicePort = _devicePort;
    buffer = _buffer;
    isPort = _isPort;
    bautRate = _bautRate;
    id = _id;
  }

// ------------------------------------------------------------------------------------
 
  // Overriding "start()"
  void start () {
    running = true;
    println("Starting thread (will execute every " + wait + " milliseconds.)");
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    // sleep(2000);
    deviceInit();
    sleep(300);
    while (running) {
      check();
      checkHeartBeat();
      sleep(wait);
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------
 
  void check(){

  	if (!deviceInstanciated){
  		sleep(3000);
  		deviceInit();
      println("deviceInstanciated not true: " + id);
  	}else if(deviceInstanciated && deviceLost){
  		sleep(3000);
  		port.stop();
  		deviceInit();
      println("deviceLost and new Init: " + id);
  	}

  }

// ------------------------------------------------------------------------------------
 
  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }

// ------------------------------------------------------------------------------------

  void sleep(int sleepTime){
	try {
	    sleep((long)(sleepTime));
	  } catch (Exception e) {
	  }

  }

// ------------------------------------------------------------------------------------

  void checkHeartBeat(){
  	if(id.equals("PulseMeter")){
	  if(millis() -  heartBeat >= 5000 && deviceInstanciated){
	    println(id + " heartBeat lost");
	    deviceLost = true;
	  }
	}else if (id.equals("Arduino")){
		if (isFirstContact){
	    	if (millis() -  heartBeat >= 5000 && deviceInstanciated){
	      		isFirstContact = false;
	      		deviceLost = true;
	      		println(id + " heartBeat lost");
	      		robotConValue = 100;
	    	}
  		}
	}
  }

// ------------------------------------------------------------------------------------  

	void deviceInit() {

	  if(isPort){ 
	    try {
	      port = new Serial(p, devicePort, bautRate);
	      port.clear();
	      if(buffer){
			port.bufferUntil(end);
	      }
	      deviceInstanciated = true;
	      deviceLost = false;
        isFirstContact = false;
	    } 
	    catch (Exception e) {
	      // println(e);
	      deviceInstanciated = false;
	      deviceLost = true;
	      // println(id + " port received an exepction: " + e);
	    }
	  } 
	}

}