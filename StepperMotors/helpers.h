#ifndef HELPERS_H
#define HELPERS_H


void setHigh(int pin);

void setLow(int pin);

void sendPulse(int pin);

void sendNegativePulse(int pin);

int convertToMilliseconds(int value, int minDegree, int maxDegree, int scaleBottom, int scaleTop); //Maps output to degree

#endif