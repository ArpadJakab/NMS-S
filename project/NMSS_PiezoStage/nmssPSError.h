/*********************************************************************
** Creates Error
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-14
** Filename:	nmssPSError.h
** Author:		Arpad Jakab
** 
***********************************************/
#ifndef NMSSPSERROR_H
#define NMSSPSERROR_H

#include "mex.h"
#include "nmssPSGlobals.h"
#include ".\E710_GCS_DLL\E7XX_GCS_DLL.H"

void nmssPSError(int iControllerHandle, int nlhs, mxArray *plhs[]) {
	plhs[0] = mxCreateString(sERROR);
	int iErrorID = E7XX_GetError(iControllerHandle);
	
	char sError[1024];
	E7XX_TranslateError (iErrorID, sError, 1024);

	char sErrMsg[1100];
	sprintf(sErrMsg, "Piezo Stage :%s", sError);
	
	// return error string
	plhs[1] = mxCreateString(sErrMsg);
};


#endif // NMSSPSERROR_H