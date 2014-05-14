#ifndef RSERVO_H
#define RSERVO_H
#include <Arduino.h>
#include <CubicEase.h>
#include "helpers.h"


class ChangePosition_Class {

	public:

		ChangePosition_Class(int minMillisCC, int maxMillisCW);
		void setPosition(long nextPosition);
		long nextEasedStep();
		int easing_resolution;
		int direction;
		bool reachedTarget;
		long _currentPosition;

	private:
		long _totalChangeInPosition;
		long _targetPosition;
		double _easedPosition;

		long _easingValue;
		long _minMillisCC;
		long _maxMillisCW;
		long _startPosition;


		CubicEase _cubic;
		

};

#endif