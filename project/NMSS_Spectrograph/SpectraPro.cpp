// SpectraPro.cpp: Implementierung der Klasse CSpectraPro.
//
//////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "SpectraPro.h"
#include "ARC_SpectraPro_dll.h"
#include "math.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
//////////////////////////////////////////////////////////////////////
// Konstruktion/Destruktion
//////////////////////////////////////////////////////////////////////
CSpectraPro::CSpectraPro()
{
	m_bSpectraProRunning=false;
	m_iMiddleWavelength=0;
}
CSpectraPro::~CSpectraPro()
{
}
void CSpectraPro::Init()
{
	m_lSpectraHandle = CSpectraPro::InitSpectrograph();
	// change running state
	if (m_lSpectraHandle >= 0)
		m_bSpectraProRunning=true;
	else
		m_bSpectraProRunning=false;
}


long CSpectraPro::InitSpectrograph()
{
	// load DLL
	LoadDLL();

	long lSpectraHandle = -1;
	long myNrOfDevices;
	// search for device
	if (ARC_Search_For_Mono(myNrOfDevices))
		// Found devices...try to open device...assume there's only one device... 
		//(##2D##) ToDo: iterate through devices...
		ARC_Open_Mono(0,lSpectraHandle);
	else
		throw "Couldn't find any SpectraPro-devices.";

	return lSpectraHandle;
}

void CSpectraPro::LoadDLL()
{
	// load DLL
	if (!LoadDLL("ARC_SpectraPro.dll"))
		throw "Error while loading ARC_SpectraPro.dll, \nplease check if the DLL is in your current directory or in one of its sub-dircetories!";
}

bool CSpectraPro::LoadDLL(char* sDllPAth)
{
	// load DLL
	return Setup_ARC_SpectraPro_dll(sDllPAth);
}

void CSpectraPro::UnLoadDLL()
{
	// unload dll - prototype
	UnLoad_ARC_SpectraPro_dll();
}

void CSpectraPro::shutdown()
{
	CSpectraPro::shutdown(m_lSpectraHandle);
	m_bSpectraProRunning=false;

}

void CSpectraPro::shutdown(long lSpectraHandle)
{
	// close spectraPro
	ARC_Close_Mono(lSpectraHandle);
	// unload DLL
	UnLoad_ARC_SpectraPro_dll();
}

std::string CSpectraPro::GetSerialNo(long lSpectraHandle)
{
	// sSerialNo must have a minimum size of 128 or more!
	char sSerialNo[256];
	if (!ARC_get_Mono_preOpen_Model_CString(lSpectraHandle, *sSerialNo))
		throw "Coldn't get Serial number!";
	
	return std::string(sSerialNo);
}

unsigned int CSpectraPro::getWavelength(long lSpectraHandle)
{
	double myWavelength=0;
	if (!ARC_get_Mono_Wavelength_nm(lSpectraHandle, myWavelength))
		throw "Error while trying to get wavelength from SpectraPro in CSpectraPro::getWavelength()";
	
	return (int) floor(myWavelength + 0.5); // rounding
}

unsigned int CSpectraPro::getWavelength()
{
	if (true==m_bSpectraProRunning) 
	{
		// typedef unsigned _int16 (CALLBACK* LPFNDLL_get_Mono_Wavelength_nm) (long, double &);
		m_iMiddleWavelength = CSpectraPro::getWavelength(m_lSpectraHandle);
	}
	else
	{
		throw "Error in CSpectraPro::getWavelength(...) - SpectraPro not running!";
	}
	return m_iMiddleWavelength;
}

void CSpectraPro::setWavelength(unsigned int wavelength)
{
	if (true==m_bSpectraProRunning) 
	{
		//typedef unsigned _int16 (CALLBACK* LPFNDLL_set_Mono_Wavelength_nm) (long, double);
		CSpectraPro::setWavelength(m_lSpectraHandle, wavelength);
	}
	else
	{
		throw "Error in CSpectraPro::setWavelength(...) - SpectraPro not running!";
	}
}

void CSpectraPro::setWavelength(long lSpectraHandle, unsigned int wavelength)
{
	if (!ARC_set_Mono_Wavelength_nm(lSpectraHandle, (double)wavelength))
		throw "Error while trying to get wavelength from SpectraPro in CSpectraPro::getWavelength()";

	
	Sleep(1000);
}


int CSpectraPro::getCurrentGrating(long lSpectraHandle)
{
	// running... get grating...
	long myGrating=-1;
	if (!ARC_get_Mono_Grating(lSpectraHandle, myGrating) )
		throw "Error while trying to get current grating";

	return myGrating;
}

int CSpectraPro::getCurrentGrating()
{
	long myGrating=-1;
	if (true==m_bSpectraProRunning) 
		myGrating = getCurrentGrating(m_lSpectraHandle);
	else
		throw "Error in CSpectraPro::getCurrentGrating() - SpectraPro not running!";
	
	return myGrating;
}

void CSpectraPro::setCurrentGrating(long lSpectraHandle, int grating)
{
	if (!ARC_set_Mono_Grating(lSpectraHandle, (long) grating) )
		throw "Error while trying to set grating!";
}

void CSpectraPro::setCurrentGrating(int grating)
{
	if (true==m_bSpectraProRunning) 
	{
		// spectraPro running... try to set grating...
		setCurrentGrating(m_lSpectraHandle, grating);
	}
	else
	{
		throw "Error in CSpectraPro::getCurrentGrating() - SpectraPro not running!";
	}
}


int CSpectraPro::getMaxGrating()
{
	if (true==m_bSpectraProRunning) 
	{
		// running... get grating...
		long myGratingNr=0;
		// max 10 gratings (should be much lower (1-3))
		for (int i=0;i<10;i++)
		{
			//typedef unsigned _int16 (CALLBACK* LPFNDLL_get_Mono_Grating) (long, long &);
			if (ARC_get_Mono_Grating_Installed(m_lSpectraHandle, i) )
			{
				// everything should be ok...
				//(##2D##) ToDo: check to make sure
				myGratingNr++;
			}
			else
			{
				//throw "Error while trying to get max grating in CSpectraPro::getCurrentGrating()";
			}
		}
		return myGratingNr;
	}
	else
		throw "Error in CSpectraPro::getCurrentGrating() - SpectraPro not running!";
}

std::vector< long > CSpectraPro::GetListOfInstalledGratings(long lSpectraHandle)
{
	std::vector< long > oNumOfGratings;
	// max 10 gratings (should be much lower (1-3))
	for (long i=0;i<10;i++)
	{
		// create a vector containing the indices of the installed gratings
		if (ARC_get_Mono_Grating_Installed(lSpectraHandle, i) )
			oNumOfGratings.push_back(i);
	}
	return oNumOfGratings;
}

long CSpectraPro::GetGratingDensity(long lSpectraHandle, long lGrating)
{
	long lLinesPer_mm = 0;
	if(!ARC_get_Mono_Grating_Density(lSpectraHandle, lGrating, lLinesPer_mm))
		throw "Couldn't get Grating density information";

	return lLinesPer_mm;
}