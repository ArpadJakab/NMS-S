#pragma once
#include ".\..\master.h"
#include ".\..\pvcam.h"

class OCamera
{
public:
	OCamera();
	~OCamera(void);

	// sets up the camera for sequential frame acquisition
	void SetupSeqExposure(unsigned long ulX1,
						  unsigned long ulY1,
						  unsigned long ulX2,
						  unsigned long ulY2,
						  unsigned long ulBx,
						  unsigned long ulBy,
						  unsigned long ulExpTime)  throw (bool);

	//bool GetTemp() throw (bool);
	bool IsCircBufferAvailable() throw (bool);
	static void PrintCAMError();
	void Open() throw (bool);
	void Close() throw (bool);




private:
	int m_hCam;  // member for the camera handle
	std::string m_sCameraName; // camera name


};
