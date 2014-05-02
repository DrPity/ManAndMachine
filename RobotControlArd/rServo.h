#ifndef RSERVO_H
#define RSERVO_H
#include <Arduino.h>
#include <CubicEase.h>
#include "helpers.h"


class ChangePosition_Class {

	public:

		ChangePosition_Class(int minMillisCC, int maxMillisCW);
		void setPosition(int nextPosition);
		int nextEasedStep();
		int easing_resolution;
		int currentPosition;

		bool reachedTarget;

	private:
		int _totalChangeInPosition;
		int _currentPosition;
		int _targetPosition;
		double _easedPosition;

		int _easingValue;
		int _minMillisCC;
		int _maxMillisCW;
		int _direction;
		int _startPosition;


		CubicEase _cubic;
		

};

#endif