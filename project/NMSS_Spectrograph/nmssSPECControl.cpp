// nmssSPECControl.cpp : Defines the entry point for the console application.
// This is NOT a MATLAB APPLICATION!!
//

#include "stdafx.h"
#include "SpectraPro.h"

int _tmain(int argc, _TCHAR* argv[])
{
	try
	{
		std::cout << "\nInitializing Spectrograph";
		int nHandle = CSpectraPro::InitSpectrograph();
		std::cout << "\nSpectrograph handle: " << nHandle;
		std::string sSerNo;
		sSerNo = CSpectraPro::GetSerialNo(nHandle);
		std::cout << "\nSerial No.: " << sSerNo.c_str();
		double dWavelength = 500;
		CSpectraPro::setWavelength(nHandle, dWavelength);
		std::cout << "\nWavelength set to: " << dWavelength;
		dWavelength = CSpectraPro::getWavelength(nHandle);
		std::cout << "\ngetWavelength: " << dWavelength;
		std::cout << "\n";
		CSpectraPro::shutdown(nHandle);
	}
	catch (char* sErrMsg)
	{
		std::cout << "\nERROR:" << sErrMsg << "\n";
	}

	return 0;
}

