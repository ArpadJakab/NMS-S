/*********************************************************************
** Custom MATLAB command to iniialize the Spectrograph
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECGetInfo.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECGetInfo()
** Returns:		a vector with 
				['OK' serial_num_string cur_grating_index cur_wavelength grating_index_list grating_descriptions] where 
				where: OK is an indicator for success or the performed action, 
				serial_num_string - the string containing the name of the spectrometer (the name is the ser.no.)
				cur_grating_index - the currently active grating
				cur_wavelength - the currently set central wavelength
				grating_index_list  - a list of indices of the gratings (use these indices to refer on a particular grating)
				grating_descriptions - the grating description (grating denisty or other description)
		or
				['ERROR' err_msg ] where ERROR indicates that the action failed,
				err_msg - conatins the error maessage
** Remarks:		to compile enter this in matlab (set the working dir to the dir where this file is):
**				mex nmssSPECGetInfo.cpp SpectraPro.cpp
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
		mexPrintf("Get handle for spectrometer");
		nHSpect = CSpectraPro::InitSpectrograph();
		CSpectraPro::shutdown(nHSpect);

		mexPrintf("Spectrometer handle %d", nHSpect);

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

