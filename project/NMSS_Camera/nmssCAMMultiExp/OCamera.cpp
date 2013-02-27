#include "StdAfx.h"
#include ".\ocamera.h"

OCamera::OCamera()
{
	m_hCam = -1;
	m_sCameraName = "No Camera";

	try
	{
		Open(); // open camera
	}
	catch(bool)
	{
		OCamera::PrintCAMError();
		printf("\nNo camera present!\n");
	}

}

OCamera::~OCamera(void)
{
	try
	{
		Close();
	}
	catch(bool)
	{
		OCamera::PrintCAMError();
		printf("\nCamera couldn't be released!\n");
	}
}

void OCamera::SetupSeqExposure(unsigned long ulX1,
					unsigned long ulY1,
					unsigned long ulX2,
					unsigned long ulY2,
					unsigned long ulBx,
					unsigned long ulBy,
					unsigned long ulExpTime) throw (bool)
{
	rs_bool retCode;

    // region that defines the area which will be retrieved from the camera
	rgn_type reg[1];
	reg[0].s1 = ulX1-1;
	reg[0].s2 = ulX2-1;
	reg[0].sbin = ulBx;
	reg[0].p1 = ulY1-1;
	reg[0].p2 = ulY2-1;
	reg[0].pbin = ulBy;

	//if (bVerbose)
	//	mexPrintf("\nROI: (%d; %d) .. (%d; %d)", reg[0].s1,reg[0].s2, reg[0].p1, reg[0].p2);

    // Experimental: Display time resolution setting
    //nmssCAM_disp_time_resolution_setting(hCam);

    // number of images to take		
    uns16 expTotal = 1;	
    // total number of region definitions
    uns16 regTotal = 1;
    // exposure mode
    int16 mode = TIMED_MODE;
    // number of bytes in the "pixel stream" (used as return variable)
    uns32 nNumberOfBytes = 1;
    // status of exposure
    int16 status;

  //  if (bVerbose)
		//mexPrintf("\nInitializing exposure controller...");
    retCode = pl_exp_init_seq();
    if (retCode == 0) throw retCode;

  //  if (bVerbose)
		//mexPrintf("\nPreparing camera for readout...");
	retCode = pl_exp_setup_seq( m_hCam, expTotal, regTotal, reg, mode , (uns16)ulExpTime, &nNumberOfBytes);
    if (retCode == 0) throw retCode;

}



bool OCamera::IsCircBufferAvailable() throw (bool)
{
	// check for circular buffer... it will be useful for multiple frame detection
	rs_bool bCricBufferAvailable;
	if (pl_get_param(m_hCam, PARAM_CIRC_BUFFER, ATTR_AVAIL, &bCricBufferAvailable))
		return (bool)bCricBufferAvailable;
	else
		throw (false);

	return false;
}

void OCamera::PrintCAMError() 
{
    char msg[256];
	int iErrCode = pl_error_code();
    pl_error_message(iErrCode,msg);
	
	// we have some hints how to solve problems with error code 183 
	// !!! actually this may be not sufficient to solve the problem !!!
	char* sInfoOnError183 = "\nTry to disconnect and then reconnect the camera power supply!\n";
	std::string sErrMsg(msg);
	if (iErrCode == 183)
		sErrMsg.append(sInfoOnError183);

	printf("\n%s", sErrMsg.c_str());

}

void OCamera::Open() throw (bool)
{
	// init stuff
	// prepare variables
	char cam_name[CAM_NAME_LEN];
	int16 hCam = 0;
	rs_bool retCode = FALSE;
    
	pl_pvcam_init();
	
	// get cam-name of the 1st attached camera
	pl_cam_get_name(0, cam_name);
	m_sCameraName = cam_name;

    try {
        // open connection to camera
        retCode = pl_cam_open(cam_name, &hCam, OPEN_EXCLUSIVE);
        if (retCode == 0) throw retCode;

		m_hCam = hCam;
		printf("\nConnected to Camera: %s with handle %d\n", cam_name, m_hCam);

    }
    // camera hardware error message
	catch (rs_bool)
    {
		OCamera::PrintCAMError();
    }

	return;
}

void OCamera::Close() throw (bool)
{
	// init stuff
	// prepare variables
	uns16 hCam = 0;

    hCam = m_hCam;
    
    try
	{
		if (!pl_cam_check(hCam))
			throw false;

		
		if (!pl_cam_close(hCam))
			throw false;

		pl_pvcam_uninit();

		printf("\nCamera with handle %d closed.", hCam);
		


	}
	catch (bool)
    {
		OCamera::PrintCAMError();
    }
	return;
}


