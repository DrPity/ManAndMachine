#ifndef WRAPPER_H
#define WRAPPER_H
#include <Arduino.h>
#include <Adafruit_NeoPixel.h>

class Wrapper_class{

private:
	int _numberOfPixels;
	int _stripPin;
	Adafruit_NeoPixel* _strip;

public:
	uint8_t targetColorR;
	uint8_t targetColorG;
	uint8_t targetColorB;


	void setStripColor();

	Wrapper_class(int numberOfPixels, int stripPin): _numberOfPixels(numberOfPixels), _stripPin(stripPin){
		_strip = new Adafruit_NeoPixel(_numberOfPixels, _stripPin, NEO_GRB + NEO_KHZ800);
		targetColorR, targetColorG, targetColorB = 0;
	}
	

	void init(){
	_strip->show();
	_strip->begin();
	_strip->setBrightness(255);
		
	}

	void setStripColor(uint8_t r, uint8_t g, uint8_t b){
		for(int i = 0; i<_numberOfPixels; i++){
			_strip->setPixelColor(i, r, g, b);
		}
		// _strip->show();
	}

	void setBrightness(uint8_t brightness){
		_strip->setBrightness(brightness);
		// _strip->show();
	}

	int getNumPixels(){
		return _strip->numPixels();
	}

	uint32_t getPixelColor(int i){
		return _strip->getPixelColor(i);
	}

	void setPixelColor(int i, uint8_t r, uint8_t g, uint8_t b){
		_strip->setPixelColor(i, r, g, b);
		// _strip->show();
	}

	void setPixelColor(int i, uint32_t color){
		_strip->setPixelColor(i, color);
		// _strip->show();
	}

	void show(){
		_strip->show();
	}

};
#endif