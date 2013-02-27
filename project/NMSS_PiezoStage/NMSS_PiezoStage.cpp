// NMSS_PiezoStage.cpp : Defines the entry point for the console application.
//
#define WIN32

#include "stdafx.h"

#include "OPiezoStageController.h"
#include "ONMSIOHandler.h"

int _tmain(int argc, _TCHAR* argv[])
{
	//printf("\nPiezo Stage Controller v1.0 by Arpad Jakab, 2007\n");
	std::cout << "\nPiezo Stage Controller v1.0 by Arpad Jakab, 2007\n";


	try
	{
		bool bGUI = false;
		// parsing for command line arguments
		for(unsigned int i=0; i < argc; i++)
		{
			std::string sCMDLineArg(argv[i]);
			if(sCMDLineArg == "-gui") bGUI = true;
		}
		OPiezoStageController oPiezoStageController(bGUI);
		std::string sIDString = oPiezoStageController.GetIDString();
		std::cout << "\nConnected to: " << sIDString;
	}
	catch(std::string sErrorMsg)
	{
		std::cout << "\nError: " << sErrorMsg;
	}
	catch(...)
	{
		std::cout << "\nUnhandled Error, please contact Nano-Bio-Tech here: www.nano-bio-tech.de\n";
	}
	
	return 0;
}

