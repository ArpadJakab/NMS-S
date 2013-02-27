/*********************************************************************
** Returns the high end of the travel range of the X-Axis (axis 1)
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSXAxisHighEnd.cpp
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
		mexPrintf("\nUsage: nmssPSXAxisHighEnd(<controller_handle>), where <controller_handle> must be a valid controller handle.");
        return;
    }
	
	int iControllerHandle = mxGetScalar(prhs[0]);

	try
	{
		// switch on servo
		int bServoState[1];
		bServoState[0] = true;
		if(!E7XX_SVO(iControllerHandle, "1", bServoState)) throw true;

		// high limit of the moving range
		double dRet[1];
		if (!E7XX_qTMX (iControllerHandle, "1", dRet)) throw true;
		
		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = dRet[0];
	}
	catch(bool bError) 
	{
		// something went wrong, oh my god!
		nmssPSError(iControllerHandle, nlhs, plhs);
	}

	return;
}

