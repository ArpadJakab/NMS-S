/*********************************************************************
** Disconnects controller
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSDisconnect.cpp
** Author:		Arpad Jakab
** 
** Usage: see usage section below
** Compile: mex nmssPSConnect.cpp .\E710_GCS_DLL\E7XX_GCS_DLL.lib
***********************************************/

#include "nmssPSGlobals.h"
#include "nmssPSDisconnect.h"
#include ".\E710_GCS_DLL\E7XX_GCS_DLL.H"
//#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// usage
	if (nrhs != 1)
    {
		mexPrintf("\nUsage: nmssPSDisconnect(<controller_handle>), where <controller_handle> is the integer number returned by nmssPSConnect.");
        return;
    }

    int iControllerHandle = mxGetScalar(prhs[0]);

	if (E7XX_IsConnected (iControllerHandle))
	{
		// close connection
		E7XX_CloseConnection(iControllerHandle);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double) iControllerHandle;
	}
	else
	{
		// no controller connected with this handle
		plhs[0] = mxCreateString(sERROR);
		int iErrorID = E7XX_GetError(iControllerHandle);
		char sError[1024];
		E7XX_TranslateError (iErrorID, sError, 1024);
		plhs[1] = mxCreateString(sError);
	}

	return;
}

