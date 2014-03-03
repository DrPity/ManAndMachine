class ConnectionStatus{
	int x, y;
	int currentColor 	= 0;
	int greenColor 		= color(0, 255, 0);
	int orangeColor 	= color(255, 255, 0);
	int redColor 		= color(255, 0, 0);
	int diameter;
	int latestConnectionValue;
	Textlabel label;

	ConnectionStatus(int _x, int _y, int _diameter) {
		x = _x;
		y = _y;
		diameter = _diameter;
		
 		label = new Textlabel(controlP5,"CONNECTION\nQUALITY", 32, 6);		
		label.setMultiline(true);
		label.setColorValue(color(0));
	}
	
	void update() {
		latestConnectionValue = channels[0].getLatestPoint().value;
		if(latestConnectionValue == 200) currentColor 	= redColor;
		if(latestConnectionValue < 200) currentColor 	= orangeColor;
		if(latestConnectionValue == 00) currentColor	= greenColor;
	}
	
	void draw() {
		
		
		pushMatrix();
		translate(x, y);
		
		noStroke();
		fill(255, 90);
		rect(0, 0, 108, 28);
		
		noStroke();
		fill(currentColor);
		ellipseMode(CORNER);
		ellipse(5, 4, diameter, diameter);
		
 		label.draw(); 		
		popMatrix();
	}

}