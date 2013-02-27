/*********************************************************************
** Set X-position
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSSetPosX.cpp
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
	if (nrhs != 2)
    {
		mexPrintf("\nUsage: nmssPSSetPosX(<controller_handle>,<x_pos>), where");
		mexPrintf("\n<controller_handle> - must be a valid controller handle.");
		mexPrintf("\n<x_pos> - must be a value between 0 and 200 (unit of distance is um).");
        return;
    }
	
	int iControllerHandle = mxGetScalar(prhs[0]);
	double dXpos[1];
	dXpos[0] = mxGetScalar(prhs[1]);

	try
	{
		// switch on servo
		int bServoState[1];
		bServoState[0] = true;
		if(!E7XX_SVO(iControllerHandle, "1", bServoState)) throw true;

		// high limit of the moving range
		if (!E7XX_MOV(iControllerHandle, "1", dXpos)) throw true;
		
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

