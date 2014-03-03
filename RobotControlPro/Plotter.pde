class Plotter {
	int x, y, w, h, currentValue, targetValue, backgroundColor;
	Channel sourceChannel;
	Textlabel label;	
	
	Plotter(Channel _sourceChannel, int _x, int _y, int _w, int _h) {
		sourceChannel = _sourceChannel;
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		currentValue = 0;
		backgroundColor = color(255);
		
 		label = new Textlabel(controlP5,sourceChannel.name, x + 16, y + 16);
		label.setColorValue(0);

	}
	
	void update() {

	}
	
	void draw() {
		pushMatrix();
		translate(x, y);		
		// Background
		noStroke();
		fill(backgroundColor);
		rect(0, 0, w, h);

		// border line
		strokeWeight(1);
		stroke(220);
		line(w - 1, 0, w - 1, h);

		
		if(sourceChannel.points.size() > 0) {
		
			Point targetPoint = (Point)sourceChannel.points.get(sourceChannel.points.size() - 1);
			targetValue = round(map(targetPoint.value, sourceChannel.minValue, sourceChannel.maxValue, 0, h));

			// if((scaleMode == "Global") && sourceChannel.allowGlobal) {					
			// 	targetValue = (int)map(targetPoint.value, 0, globalMax, 0, h);	
			// }	
							
			// Calculate the new position on the way to the target with easing
    	currentValue = currentValue + round(((float)(targetValue - currentValue) * .08));
			
			// Bar
			noStroke();
			fill(sourceChannel.drawColor);
			rect(0, h - currentValue, w, h);
		}

		// Draw the checkbox matte
		
		noStroke();
		fill(255, 150);		
		rect(10, 10, w - 20, 40);

			popMatrix();


 		label.draw();		
	}
	
	

}

