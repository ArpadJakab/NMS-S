/*********************************************************************
** Collection of global constants for the camera controller
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssCAMGlobals.h
** Author:		Arpad Jakab
** 
***********************************************/
#ifndef NMSSCAMGLOBALS_H
#define NMSSCAMGLOBALS_H

#include ".\..\nmssGlobals.h"
#include "mex.h"
#include "pvcam.h"
#include <string>

void nmssCAMError(int nlhs, mxArray *plhs[]) {

    char msg[ERROR_MSG_LEN];
	int iErrCode = pl_error_code();
    pl_error_message(iErrCode,msg);
	plhs[0] = mxCreateString("ERROR");

	// we have some hints how to solve problems with error code 183 
	// !!! actually this may be not sufficient to solve the problem !!!
	char* sInfoOnError183 = "\nTry to disconnect and then reconnect the camera power supply!\n";
	std::string sErrMsg(msg);
	if (iErrCode == 183)
		sErrMsg.append(sInfoOnError183);

	plhs[1] = mxCreateString(sErrMsg.c_str());

};

#endif // NMSSCAMGLOBALS_H