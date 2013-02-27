/*********************************************************************
** Custom MATLAB command to get the line density or a specified grating
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECGetGratingDensity.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECGetGratingDensity(<controller_handle>, <grating_index>)
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  the line density of the grating (line / mm)
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		Compile like this:
**				mex nmssSPECGetGratingDensity.cpp SpectraPro.cpp
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
		mexPrintf("\nUsage: >> [status val] = nmssSPECGetGratingDensity(<controller_handle>, <grating_index>)");
		mexPrintf("\nwhere:  - controller_handle: the handle of the spectrometer controller which was");
		mexPrintf("\n		   returned by nmssSPECConnect()");
		mexPrintf("\n        - grating_index: the index of the grating for which the line density is queried");
		mexPrintf("\n		   enter a value >= 1 (usually there are no more gratings than 3 in the spectrograph.");
		mexPrintf("\n");
        return;
    }

	// connect Spectrometer and initialize
	int nHSpect =(int) mxGetScalar(prhs[0]);
	long lGratingIndex =(long) mxGetScalar(prhs[1]);
	long lGratingDensity = 0; // will be returned
	try
	{
		nHSpect = CSpectraPro::InitSpectrograph();
		lGratingDensity = CSpectraPro::GetGratingDensity(nHSpect, lGratingIndex);
		CSpectraPro::shutdown(nHSpect);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = (double)lGratingDensity; // lines per mm

	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

