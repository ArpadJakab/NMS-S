/*********************************************************************
** Custom MATLAB command to iniialize the Spectrograph
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECConnect.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECInit()
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  contains the returned handle
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		to compile enter this in matlab (set the working dir to the dir where this file is):
**				mex nmssSPECConnect.cpp SpectraPro.cpp
***********************************************/

#include "mex.h"
#include "SpectraPro.h"
#include "nmssSPECGlobals.h"


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

	// connect Spectrometer and initialize
	int nHSpect = -1;
	try
	{
		mexPrintf("\nGet handle for spectrometer");
		nHSpect = CSpectraPro::InitSpectrograph();
		CSpectraPro::shutdown(nHSpect);

		mexPrintf("\nSpectrometer handle %d\n", nHSpect);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double) nHSpect;
	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

