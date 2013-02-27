/*********************************************************************
** Matlab Control Software for the Pixis400-CCD (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 2009-04-28
** Filename: nmssCAMStartContExp.h
** Author: Arpad Jakab, arpad.jakab@yahoo.de
** 
** Starts continous image acquisition (using PVCAM)
***********************************************/
// symbol defiitions
#ifndef NMSSCAMSTARTCONTEXP_H
#define NMSSCAMSTARTCONTEXP_H

#ifndef WIN32
#define WIN32
#endif

// neccessary includes
#include "mex.h"
#include "master.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]);


#endif // NMSSCAMSTARTCONTEXP_H