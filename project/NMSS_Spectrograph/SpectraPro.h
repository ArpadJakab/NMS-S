// SpectraPro.h: Schnittstelle für die Klasse CSpectraPro.
//
//////////////////////////////////////////////////////////////////////

//#ifndef SPECTRAPRO_H
//#define SPECTRAPRO_H

#if !defined(AFX_SPECTRAPRO_H__8464A9AD_5ADA_46E9_89B1_4AFEE69167DD__INCLUDED_)
#define AFX_SPECTRAPRO_H__8464A9AD_5ADA_46E9_89B1_4AFEE69167DD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>

//
// CSpectraPro
//
// class to control spectrograph SpectraPro
//
// (c) by Olaf Schubert 2005


class CSpectraPro  
{
public:
	// constr./destr.
	CSpectraPro();
	virtual ~CSpectraPro();

	// #### VARs ####
	// wavelength of center of spectr.
	int m_iMiddleWavelength;
	// spetrogrpah running?
	bool m_bSpectraProRunning;

	// #### FUNCTIONs ####
	// how many gratings are there?  (should be 2 for SpectraPro2156)
	int getMaxGrating();
	// get nr. of current grating
	int getCurrentGrating();
	static int getCurrentGrating(long lSpectraHandle);

	// choose grating...
	void setCurrentGrating(int grating);
	static void setCurrentGrating(long lSpectraHandle, int grating);
	// set center wavelength to <<wavelength>>
	void setWavelength(unsigned int wavelength);
	static void setWavelength(long lSpectraHandle, unsigned int wavelength);
	// get center wavelength...
	unsigned int  getWavelength();
	static unsigned int  getWavelength(long lSpectraHandle);
	// uninit
	void shutdown();
	static void shutdown(long lSpectraHandle);
	// init  (takes some time - the "COM"-LED should be on during this process)
	void Init();
	static long InitSpectrograph();
	static void LoadDLL();
	static bool LoadDLL(char* sDllPAth);

	static void UnLoadDLL();


	static std::string GetSerialNo(long lSpectraHandle);
	static std::vector< long > GetListOfInstalledGratings(long lSpectraHandle);
	static long GetGratingDensity(long lSpectraHandle, long lGrating);



private:
	// handle to spectrograph
	long m_lSpectraHandle;
};

//#endif // SPECTRAPRO_H
#endif // !defined(AFX_SPECTRAPRO_H__8464A9AD_5ADA_46E9_89B1_4AFEE69167DD__INCLUDED_)
