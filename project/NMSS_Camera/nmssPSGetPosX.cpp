/*********************************************************************
** Returns the  X-position of the piezo stage
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSGetPosX.cpp
** Author:		Arpad Jakab
** 
** Usage: see usage section below
** Compile: mex nmssPSConnect.cpp .\E710_GCS_DLL\E7XX_GCS_DLL.lib
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
		mexPrintf("\nUsage: nmssPSGetPosX(<controller_handle>), where");
		mexPrintf("\n<controller_handle> - must be a valid controller handle.");
        return;
    }
	
	int iControllerHandle = mxGetScalar(prhs[0]);

	try
	{
		double dXpos[1];
		// get X-position
		if (!E7XX_qPOS (iControllerHandle, "1", dXpos)) throw true;
		
		// create return structure consisting of a string (OK or ERROR) and the return value
		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = dXpos[0];
	}
	catch(bool bError) 
	{
		// something went wrong, oh my god!
		nmssPSError(iControllerHandle, nlhs, plhs);
	}

	return;
}

