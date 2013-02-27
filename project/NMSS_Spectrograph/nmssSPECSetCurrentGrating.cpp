/*********************************************************************
** Custom MATLAB command to get current grating
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECSetCurrentGrating.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECSetCurrentGrating(<controller_handle>, <grating_index>)
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  contains target grating index
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		Compile like this:
**				mex nmssSPECSetCurrentGrating.cpp SpectraPro.cpp
***********************************************/

#include "mex.h"
#include "SpectraPro.h"
#include "nmssSPECGlobals.h"


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

	// Usage:
    if (nrhs != 2)
    {
		mexPrintf("\nUsage: >> [status val] = nmssSPECSetCurrentGrating(controller_handle, grating_index)");
		mexPrintf("\nwhere:  - controller_handle: the handle of the spectrometer controller which was");
		mexPrintf("\n		   returned by nmssSPECConnect()");
		mexPrintf("\n		 - grating_index: the index of the target grating (as returned by nmssSPECGetListOfGratings)");
		mexPrintf("\n");
        return;
    }

	// connect Spectrometer and initialize
	int nHSpect =(int) mxGetScalar(prhs[0]);
	int iTargetGrating =(int) mxGetScalar(prhs[1]);
	long lCurGrating = -1; // will be returned
	try
	{
		nHSpect = CSpectraPro::InitSpectrograph();
		CSpectraPro::setCurrentGrating(nHSpect, iTargetGrating);
		CSpectraPro::shutdown(nHSpect);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double)iTargetGrating;

	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

