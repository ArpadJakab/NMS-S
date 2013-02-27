/*********************************************************************
** Returns the identification string of the controller
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-14
** Filename:	nmssPSGetIDString.cpp
** Author:		Arpad Jakab
** 
** Usage: see usage section below
***********************************************/

#include "nmssPSGlobals.h"
#include "nmssPSError.h"
#include ".\E710_GCS_DLL\E7XX_GCS_DLL.H"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// usage
	if (nrhs != 1)
    {
		mexPrintf("\nUsage: nmssPSGetIDString(<controller_handle>), where <controller_handle> must be a valid controller handle.");
		mexPrintf("\n");
        return;
    }
	
	int iControllerHandle = mxGetScalar(prhs[0]);

	try
	{
		char sIDString[1024];
		if(!E7XX_qIDN(iControllerHandle, sIDString, 1024)) throw true;
		
		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateString(sIDString);;
	}
	catch(bool bError) 
	{
		// something went wrong, oh my god!
		nmssPSError(iControllerHandle, nlhs, plhs);
	}

	return;
}

