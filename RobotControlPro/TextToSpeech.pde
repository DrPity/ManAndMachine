class TextToSpeech extends Thread{

int AGNES = 0;
int KATHY = 1;
int PRINCESS = 2;
int VICKI = 3;
int VICTORIA = 4;
int BRUCE = 5;
int FRED = 6;
int JUNIOR = 7;
int RALPH = 8;
int ALBERT = 9;
int BAD_NEWS = 10;
int BAHH = 11;
int BELLS = 12;
int BOING = 13;
int BUBBLES = 14;
int CELLOS = 15;
int DERANGED = 16;
int GOOD_NEWS = 17;
int HYSTERICAL = 18;
int PIPE_ORGAN = 19;
int TRINOIDS = 20;
int WHISPER = 21;
int ZARVOX = 22;

// ------------------------------------------------------------------------------------
 
String[] voices = { 
  // female
  "Agnes","Kathy", "Princess", "Vicki", "Victoria",
  // male
  "Bruce", "Fred", "Junior", "Ralph",
  // novelty
  "Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Deranged", "Good News", "Hysterical", "Pipe Organ", "Trinoids", "Whisper", "Zarvox" 
};

Table tableSpeech;
boolean running;           // Is the thread running?  Yes or no?
int wait;
public int waitForSpeechReturn;

// ------------------------------------------------------------------------------------

	TextToSpeech(int _wait){

		wait = _wait;
	}

// ------------------------------------------------------------------------------------	
	
	void start () {
    running = true;
    waitForSpeechReturn = 0;
    println("Starting thread TextToSpeech (will execute every " + wait + " milliseconds.)");
    tableSpeech = loadTable("data/Strings.csv", "header");
    super.start();
  }
 
// ------------------------------------------------------------------------------------
 
  // We must implement run, this gets triggered by start()
  void run () {
    // sleep(2000);
    sleep(300);
    while (running) {
      if(nextStep){
        nextStepInTables();
      }
    	if(newSay && globalID <= (tableSpeech.getRowCount() -1) && globalID >= 0){
    		String textString = tableSpeech.getString(globalID, "STRING");
    		say(textString,voice);
    		newSay = false;
    	}
    	sleep(wait);   
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    quit();
  }

// ------------------------------------------------------------------------------------

	void say(String s, int voice) {
	  try {
	    Runtime rtime = Runtime.getRuntime();
	    Process child = rtime.exec("/usr/bin/say -v " + (voices[voice]) + " " + s);
	    waitForSpeechReturn = child.waitFor();
	  }
	  catch (Exception e) {
	    e.printStackTrace();
	  }
		
	}

// ------------------------------------------------------------------------------------

	 void sleep(int sleepTime){
	  try {
	      sleep((long)(sleepTime));
	  } catch (Exception e) {
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

  void checkTableConstrains(){

    if((textToSpeech.tableSpeech.getRowCount() -1) <= (tablePositions.getRowCount() -1)){
      if (globalID >= (tablePositions.getRowCount() -1))
        globalID = tablePositions.getRowCount() -1;
    }else if((textToSpeech.tableSpeech.getRowCount() -1) > (tablePositions.getRowCount() -1)){
      if (globalID >= (textToSpeech.tableSpeech.getRowCount() -1))
        globalID = textToSpeech.tableSpeech.getRowCount() -1;
    }
    if(globalID < 1){
          globalID = 0;
    }

  }

// ------------------------------------------------------------------------------------

  void nextStepInTables(){
    while(nextStep){
      if(waitForSpeechReturn == 0){
        newSay = true;
        newPosition = true;
        robot.readNextRobotPosition();
        if(stepForward){
          globalID ++;
          stepForward = false;
        }else if (stepBack){
          globalID--;
          stepBack = false;
        }  
        nextStep = false;
        checkTableConstrains();
      }
    }
  }



}