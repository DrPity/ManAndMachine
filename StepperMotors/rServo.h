#ifndef RSERVO_H
#define RSERVO_H
#include <Arduino.h>
#include <CubicEase.h>
#include "helpers.h"


class ChangePosition_Class {

	public:

		ChangePosition_Class(int minMillisCC, int maxMillisCW);
		void setPosition(long nextPosition);
		int nextEasedStep();
		int easing_resolution;
		int direction;
		bool reachedTarget;

	private:
		long _totalChangeInPosition;
		long _currentPosition;
		long _targetPosition;
		double _easedPosition;

		int _easingValue;
		int _minMillisCC;
		int _maxMillisCW;
		int _startPosition;


		CubicEase _cubic;
		

};

#endif