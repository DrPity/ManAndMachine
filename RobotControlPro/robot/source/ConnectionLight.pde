class ConnectionLight {
	int x, y;
	int currentColor = 0;
	int goodColor = color(0, 255, 0);
	int badColor = color(255, 255, 0);
	int noColor = color(255, 0, 0);
	int diameter;
	int latestConnectionValue;
	Textlabel mindWave;
	Textlabel pulseMeter;
	Textlabel robot;
	Textlabel travers;
	PShape circle;
	
// ------------------------------------------------------------------------------------
	
	ConnectionLight(int _x, int _y, int _diameter) {
		x = _x;
		y = _y;
		diameter = _diameter;
		circle = createShape(ELLIPSE, 5, 4, diameter, diameter);
		circle.setStrokeWeight(0);
		mindWave = new Textlabel(controlP5,"MindWave", x + 16, y + 4);
		mindWave.setColorValue(255);
		mindWave.setFont(createFont("Helvetica", 10));
		pulseMeter = new Textlabel(controlP5,"Pulse meter", x + 16, y + 4);
		pulseMeter.setFont(createFont("Helvetica", 10));
		pulseMeter.setColorValue(255);
		robot = new Textlabel(controlP5,"Robot", x + 16, y + 4);
		robot.setFont(createFont("Helvetica", 10));
		robot.setColorValue(255);
		travers = new Textlabel(controlP5,"Travers", x + 16, y + 4);
		travers.setFont(createFont("Helvetica", 10));
		travers.setColorValue(255);
	}
	
// ------------------------------------------------------------------------------------	
	void update( int value) {
		latestConnectionValue = value;
		if(latestConnectionValue == 200) currentColor = noColor;
		if(latestConnectionValue < 200) currentColor = badColor;
		if(latestConnectionValue == 00) currentColor = goodColor;
	}

// ------------------------------------------------------------------------------------	
	
	void draw() {
		
		
		pushMatrix();
		translate(x, y);
		
		// fill(255, 150);
		// rect(0, 0, 88, 28);
		
		
		// fill(currentColor);
		ellipseMode(CORNER);
		circle.setFill(currentColor);
		shape(circle);
		//ellipse(5, 4, diameter, diameter);
				
		popMatrix();

	}

}
