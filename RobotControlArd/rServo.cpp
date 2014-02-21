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
  _currentPosition = CENTER_MILLIS;
  _targetPosition = CENTER_MILLIS;
	_minMillisCC = minMillisCC;
	_maxMillisCW = maxMillisCW;
  _cubic.setDuration(EASING_RESOLUTION);
  _easingValue = 0;
  Serial.println(_currentPosition);

  reachedTarget = false;
}


// I need a function that returns a DOUBLE 

void ChangePosition_Class::setPosition(int nextPosition){
  _easingValue = 0;
  _startPosition = _currentPosition;
  reachedTarget = false;

  Serial.print("Start Position:");
  Serial.println(_startPosition);
    

  if (nextPosition < 90){
    _targetPosition = convertToMilliseconds(nextPosition, 0, 90, _minMillisCC, CENTER_MILLIS);
    Serial.print("_targetPosition:");
    Serial.println(_targetPosition);
  }
  else if (nextPosition > 90){
    _targetPosition = convertToMilliseconds(nextPosition, 90, 180, CENTER_MILLIS, _maxMillisCW);
    Serial.print("_targetPosition:");
    Serial.println(_targetPosition);
    }
  else if ( nextPosition == 90){
    Serial.println(_targetPosition);
    Serial.print("_targetPosition:");
    _targetPosition = CENTER_MILLIS; //Make it a constant
  } 

  if (_startPosition < _targetPosition){
    _direction = 1;
  }else{
    _direction = -1;
  }

  _totalChangeInPosition = (abs(_startPosition - _targetPosition));
  _cubic.setTotalChangeInPosition(_totalChangeInPosition);
  Serial.println(_currentPosition);
}


int ChangePosition_Class::nextEasedStep(){
      // this value must macht the resolution in e.g. a 'for' loop
  _easedPosition = _cubic.easeInOut(_easingValue);
  if(_easingValue < EASING_RESOLUTION){
    _easingValue++;
  }else{
    reachedTarget = true;
  }
  _currentPosition = _startPosition + _direction * _easedPosition;
  return(_currentPosition);
 }