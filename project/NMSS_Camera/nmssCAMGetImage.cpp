/*********************************************************************
** Matlab Control Software for the CoolSnapHQ2-CCD (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 13.04.2007
** Filename: nmssCAMGetImage.cpp
** History: 2007-07-11: Olaf Schubert, schubero@uni-mainz.de - created original version for the rainbow spectrometer
**			2007-08-15: Arpad Jakab - cahnged and added functionality for the NMSS project.
** 
** Acquires an image (using PVCAM)

** This file is a MEX-file. Compile with:
mex nmssCAMGetImage.cpp Pvcam32.lib
**
** Usage: see usage section in source code below
***********************************************/
#include "nmssCAMGetImage.h"
#include "nmssCAMGlobals.h"
#include <time.h>
#include <string>
#include "pvcam.h"
//#include ".\nmssCamLib\OBuffer.h"


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// init stuff
	// prepare variables
    bool bVerbose = false;
	unsigned int expTime, lNonexposureTime, lNumOfFrames;
    double *ptrImageArray=NULL; 
	char cam_name[CAM_NAME_LEN];
	int16 hCam = 0;
	rs_bool avFlag;
	rs_bool retCode = FALSE;
	uns16* poImageBuffer = 0;
	uns16** poImagesBuffer = 0;
	//OBuffer oImageBuffer;

    
	// Usage:
	// read command-line arguments
    // correct number of parameters?
    if (nrhs != 9 )
    {
		mexPrintf("\nUsage: >> nmssCAMGetImage(hCam, x,y,w,h,bx,by, expTime, verbose)");
		mexPrintf("\nwhere: "); 
		mexPrintf("\n        - hCam: the camera handle (integer number)");
		mexPrintf("\n        - x,y: upper left corner of used rectangle on the CCD-chip");
		mexPrintf("\n        - w,h: width and height of that rectangle");
		mexPrintf("\n        - bx,by: binning factors in x- and y-direction");
		mexPrintf("\n        - expTime: exposure time in milliseconds");
		mexPrintf("\n        - verbose: if 0, no output, if 1 output generated and printed");
		mexPrintf("\n");
        return;
    }

    hCam = (uns16) mxGetScalar(prhs[0]);
	uns16 x1=(uns16) mxGetScalar(prhs[1]);
    uns16 y1=(uns16) mxGetScalar(prhs[2]);
    uns16 x2=(uns16) mxGetScalar(prhs[3]);
    uns16 y2=(uns16) mxGetScalar(prhs[4]);
    uns16 by=(uns16) mxGetScalar(prhs[5]);
    uns16 bx=(uns16) mxGetScalar(prhs[6]);
    // exposure time in the unit given by PARAM_EXP_RES (usually ms)
    expTime=(unsigned int) mxGetScalar(prhs[7]);
	lNumOfFrames = 1; // this function is designed and tested for taking only one image
	bVerbose = ((unsigned int) mxGetScalar(prhs[8]) == 1);
	
	// greeting to user
  	if (bVerbose)
	  	mexPrintf("\n nmssCAMGetImage();\n");
    
    try {
        
        // take picture
        // region of interest
        try {nmssCAM_CheckROIRange(hCam, x2, y2, x1, y1);} catch (...) {throw;};
        
        rgn_type reg[1];
		reg[0].s1 = x1-1;
		reg[0].s2 = x2-1;
		reg[0].sbin = bx;
		reg[0].p1 = y1-1;
		reg[0].p2 = y2-1;
		reg[0].pbin = by;

		if (bVerbose)
			mexPrintf("\nROI: (%d; %d) .. (%d; %d)", reg[0].s1,reg[0].s2, reg[0].p1, reg[0].p2);

        // Experimental: Display time resolution setting
        //nmssCAM_disp_time_resolution_setting(hCam);
        

        // number of images to take		
        uns16 expTotal = 1;	
        // total number of region definitions
        uns16 regTotal = 1;
        // exposure mode
        int16 mode = TIMED_MODE;
        // number of bytes in the "pixel stream"
        uns32 nNumberOfBytes = 1;
        // status of exposure
        int16 status;
        // 
        uns32 na = 0;

        if (bVerbose)
			mexPrintf("\nInitializing exposure controller...");
        retCode = pl_exp_init_seq();
        if (retCode == 0) throw retCode;

        if (bVerbose)
			mexPrintf("\nPreparing camera for readout...");
		retCode = pl_exp_setup_seq( hCam, expTotal, regTotal, reg, mode , expTime, &nNumberOfBytes);
        if (retCode == 0) throw retCode;
        
		// allocate memory
        if (bVerbose)
		{
			mexPrintf("\nReceived %d bytes", nNumberOfBytes);
			mexPrintf("\nsizeof(uns16)=%d", sizeof(uns16));
		}
		
		// here we store the poiters to the image-frames
		// poImagesBuffer = oImageBuffer.CreateFrameBuffer(lNumOfFrames, nNumberOfBytes);
		poImagesBuffer = nmssCAM_CreateFrameBuffer(lNumOfFrames, nNumberOfBytes);


		
		// ------------------------------------------------------------------------------
        // start image acquisition
		// ------------------------------------------------------------------------------
        if (bVerbose)
			mexPrintf("\nStarting readout...");
		
		unsigned int k = 0;
		while (k < lNumOfFrames) {

			retCode = pl_exp_start_seq(hCam, (void*)poImagesBuffer[k]);

			if (retCode>0)
			{
				k++;

				clock_t oStartTime = clock();
				clock_t oTimeOut = (expTime / 1000.0 + 60) * CLOCKS_PER_SEC; // timeout 60s

				if (bVerbose)
					mexPrintf("\nWait until camera is ready...");
				// wait for exposure to finish
				while( pl_exp_check_status(hCam, &status, &na) 
					&& (status!=READOUT_COMPLETE) 
					&& (status != READOUT_FAILED) )
				{
					if ((clock() - oStartTime) > oTimeOut)
						throw "Camera seems to be blocking!";
					nmssSleep(50);
				}
				plhs[0] = mxCreateString("OK");
			}
			else
				throw retCode;
		}
        
		// finish acq.
        if (bVerbose)
			mexPrintf("\nFinished readout...");
        
		if (bVerbose)
			mexPrintf("\nUninitializing exposure controller...it needs some rest, yeah");
        
		pl_exp_uninit_seq();

        uns16 nXSize = reg[0].s2 - reg[0].s1 + 1;
        uns16 nYSize = reg[0].p2 - reg[0].p1 + 1;
		if (bVerbose)
		{
			uns16 nYSize_chip;
			uns16 nXSize_chip;
			mexPrintf("\nGet YSize of the chip");
			pl_get_param(hCam, PARAM_PAR_SIZE, ATTR_CURRENT, &nYSize_chip);
			mexPrintf("\nGet XSize of the chip");
	        pl_get_param(hCam, PARAM_SER_SIZE, ATTR_CURRENT, &nXSize_chip);
			mexPrintf("\nChip size %d x %d", nXSize, nYSize);
		}
		
		//if (size != nXSize * nYSize)
		//{
		//	std::string sThrowThisError("Error while reading CCD\n");
		//	sThrowThisError += "Number of bytes readed is larger than X x Y!"
		//	throw(sThrowThisError);
		//}
		plhs[1] = mxCreateNumericMatrix(nXSize, nYSize,      // matrix dimensions
                                        mxUINT16_CLASS,      // the camera returns unsigned int
                                        mxREAL);             // no complex numbers       

		
		unsigned short * poImage = (unsigned short *)mxGetData(plhs[1]);
		size_t bytes_to_copy = nXSize * nYSize * mxGetElementSize(plhs[1]);
		if (bVerbose)
		{
			//mexPrintf("\nElement size of plhs[1]= %d", mxGetElementSize(plhs[1]));
			mexPrintf("\nNumber of bytes read from camera: %d", bytes_to_copy);
		}

		// works only for one frame
		memcpy(poImage, poImagesBuffer[0], bytes_to_copy);

		// clean up after multiple exposure
		if (lNumOfFrames >= 1)
			pl_exp_finish_seq(hCam, poImageBuffer,0);
    }
    // camera hardware error message
	catch (rs_bool retCode)
    {
		nmssCAMError(nlhs, plhs);
    }
    // nanobiotech error message
	catch (char* msg)
    {
        //mexPrintf(msg);
		plhs[0] = mxCreateString("ERROR");
		plhs[1] = mxCreateString(msg);
    }
	catch (std::string sErrorMsg)
	{
        //mexPrintf(msg);
		plhs[0] = mxCreateString("ERROR");
		plhs[1] = mxCreateString(sErrorMsg.c_str());
	}


    //nmssCAM_pl_cam_close(hCam, bVerbose);

	// FREE MEMORY
	nmssCAM_DeleteFrameBuffer(poImagesBuffer, lNumOfFrames);
	//delete[] poImageBuffer;
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


//------------------------------------------------------------------------------------------------
// Function:     nmssCAM_CreateFrameBuffer()
// Class:        
// Description:  Allocates memory for the frames
// Returns:      -
// Parameters:   unsigned int nNumOfFrames - number of frames
//			     unsigned int nNumOfBytesInImage - number of bytes in frame
//
// History:      2009-04-09: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
uns16** nmssCAM_CreateFrameBuffer(unsigned int nNumOfFrames, unsigned int nNumOfBytesInImage) 
throw(char*) 
{
		// here we store the poiters to the image-frames
		uns16* poImageBuffer = 0;
		uns16** poImagesBuffer = new uns16*[nNumOfFrames];

		unsigned int nBufferSize = 0;
		if (nNumOfBytesInImage % sizeof(uns16) == 0)
			nBufferSize = nNumOfBytesInImage / sizeof(uns16);
		else
			nBufferSize = nNumOfBytesInImage / sizeof(uns16) + 1;

		// throw error? number of byte should be an even number as the data is stored in unsigned shorts (uns16)
		// which contain only 2 bytes
		for (unsigned int k = 0; k < nNumOfFrames; k++) {
			poImageBuffer = new uns16[nBufferSize];
			if (poImageBuffer == NULL) {
				char msg[ERROR_MSG_LEN];
				sprintf(msg, "Insufficient amount of memory for %d frames! Try a lower number of frames!", nNumOfFrames);
				throw msg;
			}
			poImagesBuffer[k] = poImageBuffer;
		}

		return poImagesBuffer;
}

//------------------------------------------------------------------------------------------------
// Function:     nmssCAM_DeleteFrameBuffer()
// Class:        
// Description:  Allocates memory for the frames
// Returns:      -
// Parameters:   uns16** poImagesBuffer - the pointer to the frames buffer
//			     unsigned int nNumOfFrames - number of frames
//
// History:      2009-04-09: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
void nmssCAM_DeleteFrameBuffer(uns16** poImagesBuffer, unsigned int nNumOfFrames)
{
	if (poImagesBuffer != 0) {
		for (unsigned int k = 0; k < nNumOfFrames;	 k++) {
			delete[] poImagesBuffer[k];
		}
		delete[] poImagesBuffer;
	}
}

