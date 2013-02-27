// nmssCAMMultiExp.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "windows.h"
#include "OTools.h"
#include "OCamera.h"

int _tmain(int argc, _TCHAR* argv[])
{
	// this is just a test
	OTools::Sleep(3000, true); // wait for 2000 ms

	printf("\nNum of input args: %d", argc);
	for (int i=0; i<argc; i++)
		printf("\n%d: %s", i, (const char*)argv[i]);

    if (argc != 12 ) // 0th argument ids the command itself
    {
		printf("\nUsage: >> nmssCAMMultiExp.exe hCam x y w h bx by expTime delay nframe \"tempdir\" verbose)");
		printf("\nwhere: "); 
		printf("\n        - hCam: the camera handle (integer number)");
		printf("\n        - x,y: upper left corner of used rectangle on the CCD-chip");
		printf("\n        - w,h: width and height of that rectangle");
		printf("\n        - bx,by: binning factors in x- and y-direction");
		printf("\n        - expTime: exposure time in milliseconds");
		printf("\n        - delay: delay after exposure in milliseconds (min 10ms)");
		printf("\n        - nframe: number of frames to be grabbed");
		printf("\n        - tempdir: temporary directory to store the grabbed frames");
		printf("\n        - verbose: if 0, no output, if 1 output generated and printed");
		printf("\n");
        return 1;
    }
	
	char* sStopString;
	int iBase = 10;
	i = 1;
	//unsigned long hCam = strtoul((const char*)argv[i++], &sStopString, iBase);
	//printf("\nCamera handle:           %d", hCam);
	unsigned long ulX1= strtoul((const char*)argv[i++], &sStopString, iBase);
    unsigned long ulY1= strtoul((const char*)argv[i++], &sStopString, iBase);
	printf("\nROI top left x,y:        %d, %d", ulX1, ulY1);
    unsigned long ulX2= strtoul((const char*)argv[i++], &sStopString, iBase);
    unsigned long ulY2= strtoul((const char*)argv[i++], &sStopString, iBase);
	printf("\nROI bottom right x,y:    %d, %d", ulX2, ulY2);
    unsigned long ulBx= strtoul((const char*)argv[i++], &sStopString, iBase);
    unsigned long ulBy= strtoul((const char*)argv[i++], &sStopString, iBase);
	printf("\nBinning factors x,y:     %d, %d", 	ulBx, ulBy);
    // exposure time in the unit given by PARAM_EXP_RES (usually ms)
    unsigned long ulExpTime= strtoul((const char*)argv[i++], &sStopString, iBase);
	printf("\nExposure time:           %d ms", ulExpTime);
	unsigned long ulDelay = strtoul((const char*)argv[i++], &sStopString, iBase); 
	printf("\nDelay time:              %d ms", ulDelay);
	unsigned long ulNumOfFrames = strtoul((const char*)argv[i++], &sStopString, iBase); 
	printf("\nNumber of frames:        %d", ulNumOfFrames);
	std::string sTempDir = argv[i++]; 
	printf("\nTemp dir:                %s", sTempDir.c_str());
	bool bVerbose = (bool)strtoul((const char*)argv[i++], &sStopString, iBase);
	if (bVerbose)
		printf("\nVerbose:                 yes");
	else
		printf("\nVerbose:                 no");

	OCamera oCamera;

	try
	{

		printf("\nChecking for circular buffer...");
		if (oCamera.IsCircBufferAvailable())
			printf("Circular buffer is available");
		else
			printf("Circular buffer is NOT available");
	}
	catch (bool retCode)
    {
		OCamera::PrintCAMError();
    }
	


	return 0;
}


