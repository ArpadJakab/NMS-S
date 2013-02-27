/*********************************************************************
** Custom MATLAB command to disconnect the spectrograph
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECDisconnect.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECDisconnect(<controller_handle>)
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  contains the handle of the disconnected controller instance
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		Compile like this:
**				mex nmssSPECDisconnect.cpp SpectraPro.cpp
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
		mexPrintf("\nUsage: >> [status val] = nmssSPECDisconnect(controller_handle)");
		mexPrintf("\nwhere:  - controller_handle: the handle of the spectrometer controller which was");
		mexPrintf("\n		   returned by nmssSPECConnect()");
		mexPrintf("\n");
        return;
    }

	// get handle which was passed to this function
	int nHSpect =(int) mxGetScalar(prhs[0]);
	try
	{
		CSpectraPro::LoadDLL();
		CSpectraPro::shutdown(nHSpect);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double)nHSpect;
	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

