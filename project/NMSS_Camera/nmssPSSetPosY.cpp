/*********************************************************************
** Set Y-position
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSSetPosY.cpp
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
		mexPrintf("\nUsage: nmssPSSetPosY(<controller_handle>,<y_pos>), where");
		mexPrintf("\n<controller_handle> - must be a valid controller handle.");
		mexPrintf("\n<y_pos> - must be a value between 0 and 200 (unit of distance is um).");
        return;
    }
	
	int iControllerHandle = mxGetScalar(prhs[0]);
	double dYpos[1];
	dYpos[0] = mxGetScalar(prhs[1]);

	try
	{
		// switch on servo
		int bServoState[1];
		bServoState[0] = true;
		if(!E7XX_SVO(iControllerHandle, "2", bServoState)) throw true;

		// high limit of the moving range
		if (!E7XX_MOV(iControllerHandle, "2", dYpos)) throw true;
		
		// create return structure consisting of a string (OK or ERROR) and the return value
		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = dYpos[0];
	}
	catch(bool bError) 
	{
		// something went wrong, oh my god!
		nmssPSError(iControllerHandle, nlhs, plhs);
	}

	return;
}

