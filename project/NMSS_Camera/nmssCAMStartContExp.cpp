/*********************************************************************
** Matlab Control Software for the Pixis400-CCD (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 2009-04-28
** Filename: nmssCAMStartContExp.h
** Author: Arpad Jakab, arpad.jakab@yahoo.de
** 
** Starts continous image acquisition (using PVCAM)

** This file is a MEX-file. Compile with:
mex nmssCAMStartContExp.cpp Pvcam32.lib
**
** Usage: see usage section in source code below
***********************************************/
#include "nmssCAMStartContExp.h"
#include ".\nmssCamLib\OCircularBuffer.h"

#define MAX_STRING_BUFFER_LENGTH 256

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// Testing of external linking of classes defined in other dll-s
	// don't forget to copy the current version of the externally linked dll into the same directory where
	// the this file is located
	OBuffer oCircularBuffer;
	char sTest[MAX_STRING_BUFFER_LENGTH];
	oCircularBuffer.Test(sTest, MAX_STRING_BUFFER_LENGTH);

	mexPrintf("Start continous exposure");

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
	uns16** poImagesBuffer[2];
	OCircularBuffer oImageBuffer1, oImageBuffer2;

    
	// Usage:
	// read command-line arguments
    // correct number of parameters?
    if (nrhs != 11 )
    {
		mexPrintf("\nUsage: >> nmssCAMGetImage(hCam, x,y,w,h,bx,by,expTime)");
		mexPrintf("\nwhere: "); 
		mexPrintf("\n        - hCam: the camera handle (integer number)");
		mexPrintf("\n        - x,y: upper left corner of used rectangle on the CCD-chip");
		mexPrintf("\n        - w,h: width and height of that rectangle");
		mexPrintf("\n        - bx,by: binning factors in x- and y-direction");
		mexPrintf("\n        - expTime: exposure time in milliseconds");
		mexPrintf("\n        - lNonexposureTime: time in milliseconds until a new exposure is being taken");
		mexPrintf("\n        - lNumOfFrames: the number of frames to be taken");
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
	lNonexposureTime = (unsigned int) mxGetScalar(prhs[8]);
	lNumOfFrames = (unsigned int) mxGetScalar(prhs[9]);
	// exit, if number of frames is smaller than 1 - no frame - no image
	if (lNumOfFrames < 1)
		throw "Number of frames should be >= 1!";
	if (lNumOfFrames > 1)
		throw "Acquisition of more than 1 frames is not implemented fully yet! :-(";

	bVerbose = ((unsigned int) mxGetScalar(prhs[10]) == 1);
	
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
		retCode = pl_exp_setup_cont( hCam, regTotal, reg, mode , expTime, 
								     &nNumberOfBytes, CIRC_OVERWRITE);
        if (retCode == 0) throw retCode;
        
		// allocate memory
        if (bVerbose)
		{
			mexPrintf("\nReceived %d bytes", nNumberOfBytes);
			mexPrintf("\nsizeof(uns16)=%d", sizeof(uns16));
		}
		poImagesBuffer = oImageBuffer.CreateFrameBuffer(lNumOfFrames, nNumberOfBytes);

		// ------------------------------------------------------------------------------
        // start image acquisition
		// ------------------------------------------------------------------------------
        if (bVerbose) mexPrintf("\nStarting readout...");

		// start continous acquisition of frames into the circular buffer
		pl_exp_start_cont(hCam, poImagesBuffer, oImageBuffer.GetSize());
		
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


	return;
};

