/*********************************************************************
** Matlab Control Software for the CoolSnapHQ2-CCD (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 13.04.2007
** Filename: getCamName.cpp
** Author: Olaf Schubert, schubero@uni-mainz.de
** 
** Returns the Name of the CCD
** (to test Matlab/DLL)

** This file is a MEX-file. Compile with:
  >> mex getCamName.cpp Pvcam32.lib
**
** Usage: name = getCamName()
***********************************************/

#include "mex.h"

#define WIN32

#include "master.h"
#include "pvcam.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    // prepare variables
	char cam_name[CAM_NAME_LEN];

	// init pvcam
	pl_pvcam_init();
    // get cam-name
    pl_cam_get_name(0, cam_name);
    // uninit pvcam
	pl_pvcam_uninit();

    plhs[0] = mxCreateString(cam_name);
}

