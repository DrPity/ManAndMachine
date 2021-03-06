#include <Arduino.h>
#include <Servo.h>
#include "rServo.h"
#include "helpers.h"
#include "MAPPINGS.H"
#include <CubicEase.h>
#define DEBUG
#include "debug.h"

//Constructor
int test = 11;
//CubicEase cubic;

ChangePosition_Class::ChangePosition_Class(int minMillisCC, int maxMillisCW){
  _currentPosition = 0;
  _targetPosition = 0;
	_minMillisCC = minMillisCC;
	_maxMillisCW = maxMillisCW;
  easing_resolution = 1;
  _easingValue = 0;

  reachedTarget = true;
}


// I need a function that returns a DOUBLE 

void ChangePosition_Class::setPosition(long nextPosition){
  _easingValue = 0;
  _startPosition = _currentPosition;
  reachedTarget = false;
  _targetPosition = nextPosition;
  Serial.println("easing_resolution: ");
  Serial.println(easing_resolution);
  _cubic.setDuration(easing_resolution);


  if (_startPosition < _targetPosition){
    direction = 1; // towards robert // away from audience
  }else{
    direction = -1; // away from robert // towards audience
  }

  _totalChangeInPosition = (abs(_startPosition - _targetPosition));
  _cubic.setTotalChangeInPosition(_totalChangeInPosition);
  // Serial.println(_currentPosition);
}


long ChangePosition_Class::nextEasedStep(){
      // this value must macht the resolution in e.g. a 'for' loop
  _easedPosition = _cubic.easeInOut(_easingValue);
  if(_easingValue < easing_resolution){
    _easingValue++;
  }else{
    reachedTarget = true;
  }
  _currentPosition = _startPosition + direction * _easedPosition;
   // Serial.println(_currentPosition);
  return(_currentPosition);
 }