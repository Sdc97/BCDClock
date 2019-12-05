/*
Program: BCD Clock CPP File
Author: Steven Calvert and Subham Thakulla Kshetri
Date: 06/03/19
Class: CSCI 150
Description: Allows the user to input a time from
the keyboard or system and holds each digit in 
4 binary bits, and allows for increments of a user 
inputted number of seconds.

The following code is written by us.
*/

#define _CRT_SECURE_NO_WARNINGS
#include <algorithm>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <string>
#include <ctime>

extern "C" {
	void setClock(char clock[], const struct TimeInfo* tmPtr);
	void tickClock(char clock[]);
	unsigned char incrementClockValue(char BCDbits, const unsigned int maxValue);

}

using namespace std;

// Holds the information for the clock
struct TimeInfo {
	unsigned int hour, min, sec;
	char amPm;
};

// Declare all functions for the clock
unsigned int interpretTime(struct TimeInfo* tmPtr, const char* time);
void printClock(const char clock[]);
void debugInfo(const char clock[]);
string convertTime(const tm* mytime);
int validateInput(const char* time);
string getTime();


int main() {
	int advance;
	bool valid = true;
	string myTime;
	char clock[4]; // Primary clock container
	TimeInfo* timeContainer = new TimeInfo();
	cout << "This program converts a time from decimal to BCD." << endl;
	while (valid) { // Input validation loop
		myTime = getTime();
		if (validateInput(myTime.c_str()) == -1) {
			cout << "Invalid Input, please input again." << endl << endl;
		}
		else if (myTime.length() > 9) {
			
		}
		else {
			valid = false;
		}
	}
	interpretTime(timeContainer, myTime.c_str());
	setClock(clock, timeContainer);
	debugInfo(clock);
	printClock(clock);
	cout << "Enter seconds to advance: ";
	cin >> advance;
	for (int i = 0; i < advance; i++) {
		tickClock(clock);
	}
	printClock(clock);
}

// Allows the user to get the time from either input or
// from the system.
string getTime() {
	int response;
	string result;
	time_t  now;
	tm* dt;
	cout << "1. Input time manually" << endl;
	cout << "2. Get time from system" << endl;
	cout << "Please select an option: ";
	cin >> response;
	switch (response) {
	case 1:
		cout << "Enter the time: ";
		cin >> result;
		break;
	case 2:
		now = time(0);
		dt = localtime(&now);
		result = convertTime(dt);
		break;
	default:
		break;
	}
	return result;
}

// Transforms a user inputted string into a TimeInfo Struct
unsigned int interpretTime(TimeInfo* tmPtr, const char* time)
{
	tmPtr->hour = (time[0] - '0') * 10 + (time[1] - '0');
	tmPtr->min = (time[3] - '0') * 10 + (time[4] - '0');
	tmPtr->sec = (time[6] - '0') * 10 + (time[7] - '0');
	tmPtr->amPm = time[8];
	return 0;
}

// Prints the clock in HH:MM:SS(A/P) format in hex
void printClock(const char clock[])
{
	cout << "Current Time: ";
	for (int i = 0; i < 3; i++) {
		cout << hex << setw(2) << setfill('0') << (int)clock[i];
		if (i<2) cout << ":";
	}
	cout << clock[3] << endl;

}

//Shows the hex values for the clock
void debugInfo(const char clock[])
{
	cout << "Debug info: clock = {";
	for (int i = 0; i < 3; i++) {
		cout << "0x";
		cout << hex << setw(2) << setfill('0') << (int)clock[i];
		cout << ", ";
	}
	cout << "0x";
	cout << hex << setw(2) << setfill('0') << (int)clock[3];
	cout << "}" << endl;
	cout << endl;
}

//Converts a system time struct into a valid string.
string convertTime(const tm* mytime)
{
	string result = "";
	char AMPM;
	int hour = mytime->tm_hour, minute = mytime->tm_min, second = mytime->tm_sec;
	if (hour > 12) {
		AMPM = 'P';
	}
	else {
		AMPM = 'A';
	}
	hour = hour % 12;
	if (hour < 10) {
		result += '0';
	}
	result += to_string(hour) + ":";
	if (minute < 10) {
		result += '0';
	}
	result += to_string(minute) + ":";

	if (second < 10) {
		result += '0';
	}
	result += to_string(second);

	result += AMPM;

	return result;
}

// Ensures that user inputted times are in a valid format.
int validateInput(const char* time)
{
	int hour, min, sec;
	char AMPM;
	hour = (time[0] - '0') * 10 + (time[1] - '0');
	min = (time[3] - '0') * 10 + (time[4] - '0');
	sec = (time[6] - '0') * 10 + (time[7] - '0');
	AMPM = time[8];

	if (hour > 12 || hour < 1) {
		return -1;
	}
	else if (min >= 60 || min < 0) {
		return -1;
	}
	else if (sec >= 60 || sec < 0) {
		return -1;
	}
	else if (AMPM == 'P' || AMPM == 'A') {
		return 0;
	}
	else {
		return -1;
	}
}
