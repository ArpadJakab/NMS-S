/*********************************************************************
** Main class module to control PI piezo scanning table
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	nmssPSConnect.cpp
** Author:		Arpad Jakab
** 
** Usage: see usage section below
** Compile: mex nmssPSConnect.cpp .\E710_GCS_DLL\E7XX_GCS_DLL.lib
***********************************************/

#include "nmssPSGlobals.h"
#include "nmssPSConnect.h"
#include "nmssPSError.h"
#include ".\E710_GCS_DLL\E7XX_GCS_DLL.H"
//#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	bool bVerbose = false;
	// usage
	if (nrhs < 1 || nrhs > 2)
    {
		mexPrintf("\nUsage: [status val] = nmssPSConnect(<gui_display>, <verbose>), where ");
		mexPrintf("\n    gui_display : ");
		mexPrintf("\n            0 - no GUI to set connection details, connection is done on COM1 at 9600 baud");
		mexPrintf("\n            1 - displays GUI to set connection details");
		mexPrintf("\n    verbose (optional) :");
		mexPrintf("\n            0 - no status mesasges printed in command shell");
		mexPrintf("\n            1 - status mesasges printed in command shell");
		mexPrintf("\nReturns a vector:");
		mexPrintf("\nstatus - \"OK\" if connction was successful, \"ERROR\" otherwise");
		mexPrintf("\nval - the controller handle (an integer number), or errormessage in case of error");
        return;
    }

    bool bGUI = ((unsigned int) mxGetScalar(prhs[0]) == 1); // if argument == 1 gui initialization is switched on
	if (nrhs == 2)
		bVerbose = ((unsigned int) mxGetScalar(prhs[1]) == 1);

	// connect via RS232 to COM1 with baud rate of 9600
	int nHController = -1;
	try
	{
		if (bVerbose) mexPrintf("\nConnecting to piezo stage");
		if (bGUI)
			nHController = E7XX_InterfaceSetupDlg(NULL);
		else
			nHController = E7XX_ConnectRS232(1, 9600);
		
		if (bVerbose) mexPrintf("\nPiezo Stage controller handle: %d", nHController);
		
		if (nHController < 0) 
			throw "Piezo Stage : Failed to connect to controller!"; 
		
		// init all axes otherwise nothing seems to be working
		if(!E7XX_INI(nHController, ""))
			throw true;

		// valid handle to controller object
		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double) nHController;

	}
	catch(bool bError)
	{
		// something went wrong, oh my god!
		nmssPSError(nHController, nlhs, plhs);
	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

