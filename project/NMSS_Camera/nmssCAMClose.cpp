/*********************************************************************
** Matlab Control Software for the CoolSnapHQ2-CCD (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 13.04.2007
** Filename: nmssCAMClose.cpp
** History: 2007-07-11: Olaf Schubert, schubero@uni-mainz.de - created original version for the rainbow spectrometer
**			2007-08-15: Arpad Jakab - cahnged and added functionality for the NMSS project.
** 
** This file is a MEX-file. Compile with:
  >> mex nmssCAMClose.cpp Pvcam32.lib
**
** Usage: see usage section in source code below
***********************************************/
#include "nmssCAMGetImage.h"
#include "nmssCAMGlobals.h"
#include <time.h>
#include <string>
#include "pvcam.h"


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// init stuff
	// prepare variables
	uns16 hCam = -1;
	bool bVerbose = false; 
    
	// Usage:
	// read command-line arguments
    // correct number of parameters?

	if (nrhs < 1 || nrhs > 2 )
    {
		mexPrintf("\nUsage: >> nmssCAMClose(<handle_camera>)");
		mexPrintf("\nwhere:  - handle_camera : the handle of the camera");
		mexPrintf("\n        - verbose: - optional - if 0, no output, if 1 output generated and printed");
		mexPrintf("\n");
        return;
    }

    hCam =(uns16) mxGetScalar(prhs[0]);
	if (nrhs == 2)
		bVerbose = ((unsigned int) mxGetScalar(prhs[1]) == 1);
    
    try
	{
		if (bVerbose) mexPrintf("\nDo we have a camera opened with handle %d?", hCam);
		if (!pl_cam_check(hCam))
		{
			if (bVerbose) mexPrintf(" No :((\n");
			throw false;
		}
		else
			if (bVerbose) mexPrintf(" Yes :)))\n");

		
		if (bVerbose) mexPrintf("\nCamera closing...");
		if (!pl_cam_close(hCam))
			throw;

		if (bVerbose) mexPrintf("\nUninit library...");
		pl_pvcam_uninit();

		if (bVerbose) mexPrintf("\nCamera closed and uninitalized.\n");

		plhs[0] = mxCreateString("OK");
		plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
		double* pdRet = mxGetPr(plhs[1]);
		*pdRet = (double)hCam;
	}
	catch (...)
    {
		nmssCAMError(nlhs, plhs);
    }


	return;
}

