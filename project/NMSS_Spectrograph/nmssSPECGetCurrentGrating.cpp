/*********************************************************************
** Custom MATLAB command to get current grating
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECGetCurrentGrating.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECGetCurrentGrating(<controller_handle>)
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  contains current grating index
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		Compile like this:
**				mex nmssSPECGetCurrentGrating.cpp SpectraPro.cpp
***********************************************/

#include "mex.h"
#include "SpectraPro.h"
#include "nmssSPECGlobals.h"


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

	// Usage:
    if (nrhs != 1)
    {
		mexPrintf("\nUsage: >> [status val] = nmssSPECGetCurrentGrating(controller_handle)");
		mexPrintf("\nwhere:  - controller_handle: the handle of the spectrometer controller which was");
		mexPrintf("\n		   returned by nmssSPECConnect()");
		mexPrintf("\n");
        return;
    }

	// connect Spectrometer and initialize
	int nHSpect =(int) mxGetScalar(prhs[0]);
	long lCurGrating = -1; // will be returned
	try
	{
		nHSpect = CSpectraPro::InitSpectrograph();
		lCurGrating = CSpectraPro::getCurrentGrating(nHSpect);
		CSpectraPro::shutdown(nHSpect);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double)lCurGrating;

	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

