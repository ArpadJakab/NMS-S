/*********************************************************************
** Collection of global constants
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSGlobals.h
** Author:		Arpad Jakab
** 
***********************************************/
#ifndef NMSSGLOBALS_H
#define NMSSGLOBALS_H

#include <time.h>


const char* sOK = "OK";
const char* sERROR = "ERROR";

// just a custom sleep command
void nmssSleep(unsigned int iTime) {

	clock_t goal;
	clock_t wait = (clock_t)(iTime * 1e-3 * CLOCKS_PER_SEC); // ms
	
	goal = wait + clock();
	while( goal > clock() ); // loop for the given duration
};


#endif // NMSSGLOBALS_H