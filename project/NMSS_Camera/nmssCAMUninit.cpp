/*********************************************************************
** Matlab Control Software for the Pixis 400 (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 13.04.2007
** Filename: nmssCAMOpen.cpp
** History: 2009-05-08: Arpad Jakab - implenetation
** 
** uninitalizes the camera driver (closes camera, frees up all resources, etc)

** This file is a MEX-file. Compile with:
  >> mex nmssCAMUninit.cpp Pvcam32.lib
**
** Usage: see usage section in source code below
***********************************************/
#ifndef WIN32
#define WIN32
#endif

// neccessary includes
#include "mex.h"
#include "master.h"

#include "nmssCAMGlobals.h"
#include <time.h>
#include <string>
#include "pvcam.h"


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// init stuff
	// prepare variables
	bool bVerbose = false;

    
	// Usage:
	// read command-line arguments
    // correct number of parameters?
    if (nrhs > 1)
    {
		mexPrintf("\nUsage: >> nmssCAMUninit(<verbose>)");
		mexPrintf("\nwhere:  - verbose: if 0, no output, if 1 output generated and printed");
		mexPrintf("\n");
        return;
    }
	if (nrhs == 1)
		bVerbose = ((unsigned int) mxGetScalar(prhs[0]) == 1);
    
	// greeting to user
  	if (bVerbose)
	  	mexPrintf("\n nmssCAMUninit();\n");
	// init pvcam
  	if (bVerbose)
		mexPrintf("\n pl_pvcam_uninit();\n");

	try
	{
		rs_bool retCode = pl_pvcam_uninit();
        if (retCode == 0) throw retCode;
		
		plhs[0] = mxCreateString("OK");
		plhs[1] = mxCreateString("");
    }
    // camera hardware error message
	catch (rs_bool retCode)
    {
		nmssCAMError(nlhs, plhs);
    }

	return;
}

//------------------------------------------------------------------------------------------------
// Function:     nmssCAM_pl_cam_close()
// Class:        
// Description:  Releases the camera (so that everyone else can have access to it)
// Returns:      -
// Parameters:   int16 hCam - handle of the camera
//
// History:      2007-08-10: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
void nmssCAM_pl_cam_close(int16 hCam, bool bVerbose)
{
    pl_cam_close(hCam);
    pl_pvcam_uninit();
	if (bVerbose)
		mexPrintf("\nCamera closed and uninitalized.\n");

}


//------------------------------------------------------------------------------------------------
// Function:     nmssCAM_disp_time_resolution_setting()
// Class:        
// Description:  Displays the current time resolution setting
// Returns:      -
// Parameters:   int16 hCam - handle of the camera
//
// History:      2007-08-10: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
void nmssCAM_disp_time_resolution_setting(int16 hCam)
{
    int iTimeRes = 0;
    pl_get_param(hCam, PARAM_EXP_RES, ATTR_CURRENT, &iTimeRes);
    switch (iTimeRes)
    {
        case (int)EXP_RES_ONE_MILLISEC:
            mexPrintf("Time resolution is 1ms\n");
            break;
        case (int)EXP_RES_ONE_MICROSEC:
            mexPrintf("Time resolution is 1us\n"); // us stands for microseconds
            break;
        case (int)EXP_RES_ONE_SEC:
            mexPrintf("Time resolution is 1s\n");
            break;
        default:
            mexPrintf("Time resolution is %d\n", iTimeRes);
    }
}

//------------------------------------------------------------------------------------------------
// Function:     nmssCAM_disp_time_resolution_setting()
// Class:        
// Description:  Displays the current time resolution setting
// Returns:      -
// Parameters:   int16 hCam - handle of the camera
//
// History:      2007-08-10: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
void nmssCAM_CheckROIRange(int16 hCam, 
                                 unsigned int iWidth, unsigned int iHeight,
                                 unsigned int iXpos, unsigned int iYpos)
                                 throw(char*)
{
     // this will store custom messages
    char msg[ERROR_MSG_LEN];
   
    uns16 nXSize = 0;
    uns16 nYSize = 0;
    pl_get_param(hCam, PARAM_PAR_SIZE, ATTR_CURRENT, &nYSize);
    pl_get_param(hCam, PARAM_SER_SIZE, ATTR_CURRENT, &nXSize);

    if (iWidth > nXSize) {
        sprintf(msg, "Region of interest rectangle is out of CCD region!\n Max x-size is %d\n You entered: %d", nXSize - iXpos - 1, iWidth);
        throw msg;
    }
    if (iHeight > nYSize) {
        sprintf(msg, "Region of interest rectangle is out of CCD region!\n Max y-size is %d\n You entered: %d", nYSize - iYpos - 1, iHeight);
        throw msg;
    }
}