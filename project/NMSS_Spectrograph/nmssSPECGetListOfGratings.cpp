/*********************************************************************
** Custom MATLAB command to get the number of gratings in the spectrometer
** NanoBioTech Group - Uni Mainz
** Filename:	nmssSPECGetListOfGratings.cpp
** History:		2007-08-16: Arpad Jakab - creation
** 
** Usage:		[status val] = nmssSPECGetListOfGratings(<controller_handle>)
** Returns:		['OK' ret_val] where OK is an indicator for success or the performed action, 
**				ret_val -  an array of the installed grating indices
**				or
**				['ERROR' err_msg] where ERROR indicates that the action failed,
**				err_msg - conatins the error maessage
** Remarks:		Compile like this:
**				mex nmssSPECGetListOfGratings.cpp SpectraPro.cpp
***********************************************/

#include "mex.h"
#include "SpectraPro.h"
#include "nmssSPECGlobals.h"
#include <vector>



void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

	// Usage:
    if (nrhs != 1)
    {
		mexPrintf("\nUsage: >> [status val] = nmssSPECGetListOfGratings(controller_handle)");
		mexPrintf("\nwhere:  - controller_handle: the handle of the spectrometer controller which was");
		mexPrintf("\n		   returned by nmssSPECConnect()");
		mexPrintf("\n");
        return;
    }

	// connect Spectrometer and initialize
	int nHSpect =(int) mxGetScalar(prhs[0]);
	long lNumOfGratings = 0; // will be returned
	try
	{
		std::vector < long > ListOfGratings;
		
		nHSpect = CSpectraPro::InitSpectrograph();
		ListOfGratings = CSpectraPro::GetListOfInstalledGratings(nHSpect);
		CSpectraPro::shutdown(nHSpect);


		double* pdRet;
		plhs[0] = mxCreateString(sOK);
		plhs[1] = mxCreateDoubleMatrix(ListOfGratings.size(), 1, mxREAL);
		pdRet = mxGetPr(plhs[1]);
		// fill array
		if (pdRet != 0)
		{
			for(long i=0; i < ListOfGratings.size(); i++)
				pdRet[i] = ListOfGratings.at(i);
		}

	}
	catch(char* sErrMsg)
	{
		plhs[0] = mxCreateString(sERROR);
		plhs[1] = mxCreateString(sErrMsg);
	}

	return;
}

