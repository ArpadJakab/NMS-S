/*********************************************************************
** Custom MATLAB command to set the central wavelength of the spectrometer
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECSetWavelength.cpp.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECSetWavelength.cpp(<controller_handle>, <wavelength>)
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  contains the target wavelength
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		Compile like this:
**				mex nmssSPECSetWavelength.cpp SpectraPro.cpp
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
		mexPrintf("\nUsage: >> [status val] = nmssSPECSetWavelength(controller_handle, wavelength)");
		mexPrintf("\nwhere:  - controller_handle : the handle of the spectrometer controller which was");
		mexPrintf("\n		   returned by nmssSPECConnect()");
		mexPrintf("\n		 - wavelength : the target wavelength in nanometer (nm)");
		mexPrintf("\n");
        return;
    }

	// connect Spectrometer and initialize
	int nHSpect =(int) mxGetScalar(prhs[0]);
	double dWavelength = mxGetScalar(prhs[1]); // will be returned
	try
	{
		nHSpect = CSpectraPro::InitSpectrograph();
		CSpectraPro::setWavelength(nHSpect, dWavelength);
		CSpectraPro::shutdown(nHSpect);

		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		*pdRet = dWavelength;

	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

