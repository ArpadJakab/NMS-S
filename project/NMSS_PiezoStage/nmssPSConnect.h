/*********************************************************************
** Main class module to control PI piezo scanning table
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSConnect.h
** Author:		Arpad Jakab
** 
***********************************************/
// symbol defiitions
#ifndef NMSSPSCONNECT_H
#define NMSSPSCONNECT_H

#ifndef WIN32
#define WIN32
#endif


// neccessary includes
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]);

#endif //NMSSPSCONNECT_H
