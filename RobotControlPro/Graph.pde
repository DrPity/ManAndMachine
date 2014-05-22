class Graph {
	int x, y, w, h, pixelsPerSecond, gridColor, gridX, originalW, originalX, timeScale;
	long leftTime, rightTime, gridTime;
	boolean scrollGrid;
	String renderMode;
	float gridSeconds;
	Slider pixelSecondsSlider;
	RadioButton renderModeRadio;
	RadioButton scaleRadio;
	Channel[] thisChannels;
	public boolean isDataToGraph;

// ------------------------------------------------------------------------------------

	Graph(int _x, int _y, int _w, int _h, Channel[] _thisChannels, int _timeScale, String _renderMode) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		timeScale = _timeScale;
		thisChannels =  _thisChannels;
		pixelsPerSecond = 10;
		gridColor = color(0);
		gridSeconds = 1; // seconds per grid line
		scrollGrid = false;
		isDataToGraph = false;
		renderMode = _renderMode;



		// temporary overdraw kludge to keep graph smooth
		originalW = w;
		originalX = x;
		
		w += (pixelsPerSecond * 2);
		x -= pixelsPerSecond;
		

		// pixelSecondsSlider = controlP5.addSlider("PIXELS PER SECOND",10,width,50,16,16,100,10);
		// pixelSecondsSlider.setColorForeground(color(180));
		// pixelSecondsSlider.setColorActive(color(180));

 	// 	renderModeRadio = controlP5.addRadioButton("RENDER MODE",16,36);
		// renderModeRadio.setSpacingColumn(40);
		
		// s
		// renderModeRadio.addItem("Curves",2);
		// renderModeRadio.addItem("Shaded",3);
		// renderModeRadio.addItem("Triangles",4);			
		// renderModeRadio.activate(0);
		// // triangles, too?
		
		// scaleRadio = controlP5.addRadioButton("SCALE MODE",104,36);
		// scaleRadio.setColorForeground(color(255));
		// scaleRadio.setColorActive(color(0));
		// scaleRadio.addItem("Local Maximum",1);
		// scaleRadio.addItem("Global Maximum",2);		
		// scaleRadio.activate(0);

	}

// ------------------------------------------------------------------------------------
	
	void update() {
	}

// ------------------------------------------------------------------------------------
	
	void draw() {
		
		

		
		//pixelsPerSecond = round(pixelSecondsSlider.value());
		

		w = originalW;
		x = originalX;

		w += (pixelsPerSecond * 2);
		x -= pixelsPerSecond;

		
		// Figure out the left and right time bounds of the graph, based on
		// the pixels per second value
		rightTime = System.currentTimeMillis();
		leftTime = rightTime - ((w / pixelsPerSecond) * timeScale);
		
		if(isDataToGraph){

			pushMatrix();
			translate(x, y);
			
		
			
			// Draw each channel (pass in as constructor arg?)

			noFill();				
			if(renderMode == "Shaded" || renderMode == "Triangles") noStroke();		
			if(renderMode == "Lines" || renderMode == "Curves") strokeWeight(1.5);
			// println("Before loop")
			for (int i = 0; i < thisChannels.length; i++) {
				if(thisChannels[i] != null){
					Channel thisChannel = thisChannels[i];
					// println("In for loop");
					// println("Drawing value:" + thisChannel.getLatestPoint().value + " " + i ) ;
					
					if(thisChannel.graphMe) {
					
						//Draw the line
						if(renderMode == "Lines" || renderMode == "Curves") stroke(thisChannel.drawColor);

						if(renderMode == "Shaded" || renderMode == "Triangles") {
							noStroke();
							fill(thisChannel.drawColor, 120);
						}
					
						if(renderMode == "Triangles") {
							beginShape(TRIANGLES);
						}
						else {
							beginShape();			
						}

						if(renderMode == "Curves") vertex(0, h);
					
					
						for (int j = 0; j < thisChannel.points.size(); j++) {
							Point thisPoint = (Point)thisChannel.points.get(j);
								
							// check bounds
							if((thisPoint.time >= leftTime) && (thisPoint.time <= rightTime)) {
						
								int pointX = (int)helpers.mapLong(thisPoint.time, leftTime, rightTime, 0L, (long)w);
							
								int pointY = 0;
								if((scaleMode == "Global") && (i > 2)) {					
									pointY = (int)map(thisPoint.value, 0, globalMax, h, 0);
								}
								else {
									// Local scale
									pointY = (int)map(thisPoint.value, thisChannel.minValue, thisChannel.maxValue, h, 0);
								}
						
								// ellipseMode(CENTER);
								// ellipse(pointX, pointY, 5, 5);
						
								if(renderMode == "Curves") {
									curveVertex(pointX, pointY);					
								}
								else {
									vertex(pointX, pointY);
								}				
							}
						}
					}

					
					if(renderMode == "Curves") vertex(w, h);
					if(renderMode == "Lines" || renderMode == "Curves" || renderMode == "Triangles") endShape();
					if(renderMode == "Shaded") endShape(CLOSE);
				}
			}	


			
			popMatrix();
			
			
			// gui matte
			noStroke();
			// fill(255, 150);
			// rect(10, 10, 195, 300);

		}


	}

// ------------------------------------------------------------------------------------

	void drawGrid(){

		pushMatrix();

		// Draw the background graph
		strokeWeight(0.6);
		stroke(127,80);

		if (scrollGrid) {
			// Start from the first whole second and work right			
			gridTime = (rightTime / (long)(1000 * gridSeconds)) * (long)(1000 * gridSeconds);
		}
		else {
			gridTime = rightTime;
		}

		if(!gridXisDrawn){
			// println("Drawing GridX");
			while (gridTime >= leftTime) {
				int gridX = (int)helpers.mapLong(gridTime, leftTime, rightTime, 0L, (long)w);
				line(gridX, 0, gridX, height);
				gridTime -= (long)(1000 * gridSeconds);
			}
		gridXisDrawn = true;
		}

		strokeWeight(0.6);
		stroke(127,80);
		//Draw square horizontal grid for now
		if(!gridYisDrawn){
			// println("Drawing GridY");
			int gridY = height;
			while (gridY >= 0) {
				gridY -= pixelsPerSecond * gridSeconds; 
				line(0, gridY, w, gridY);
			}
		gridYisDrawn = true;	
		}
		popMatrix();
	}


	
}
