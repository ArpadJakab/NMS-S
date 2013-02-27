/*********************************************************************
** Main class module to control PI piezo scanning table
** NanoBioTech Group - Uni Mainz
** Date:		2007-08-13
** Filename:	OPiezoStageController.cpp
** Author:		Arpad Jakab
** 
***********************************************/



#include ".\E710_GCS_DLL\E7XX_GCS_DLL.H"
#include "OPiezoStageController.h"



OPiezoStageController::OPiezoStageController()
{
}

OPiezoStageController::OPiezoStageController(bool bGUI) throw(std::string)
{
	Connect(bGUI);
}

OPiezoStageController::~OPiezoStageController()
{
	E7XX_CloseConnection(m_nHController);
}

//------------------------------------------------------------------------------------------------
// Function:     Init()
// Class:        OPiezoStageController
// Description:  connects to the controller and and initializes it
// Returns:      -
// Parameters:   -
//
// History:      2007-08-13: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
void OPiezoStageController::Connect(bool bGUI) throw(std::string)
{
	if (bGUI)
		// open connection gui
		m_nHController = E7XX_InterfaceSetupDlg(NULL);
	else
		// connect via RS232 to COM1 with baud rate of 9600
		m_nHController = E7XX_ConnectRS232(1, 9600);

	//if (m_nHController < 0)
	//	throw(std::string("\nThe controller couldn't be found.\nPlease be sure, that the controller is connected to the selected port!"));
}	

//------------------------------------------------------------------------------------------------
// Function:     GetIDString()
// Class:        OPiezoStageController
// Description:  Returns controller ID-string
// Returns:      -
// Parameters:   -
//
// History:      2007-08-13: Created by Arpad Jakab
//------------------------------------------------------------------------------------------------
std::string OPiezoStageController::GetIDString() throw(std::string)
{
	char sIDCharString[255];

	bool bError = (bool)E7XX_qIDN(m_nHController, sIDCharString, 255);

	if (!bError)
		throw(GetErrorString());

	return std::string(sIDCharString);
}

int OPiezoStageController::GetErrorID()
{
	return E7XX_GetError(m_nHController);
}

std::string OPiezoStageController::GetErrorString()
{
	int iErrorID = GetErrorID();
	return GetErrorString(iErrorID);
}

std::string OPiezoStageController::GetErrorString(int iErrorID)
{
	const unsigned int iSTRING_BUFFER_LENGTH = 256;
	char* sErrorCharString = (char*) malloc(iSTRING_BUFFER_LENGTH * sizeof(char));
	if (sErrorCharString != 0)
	{
		unsigned int n = 1;
		while(!E7XX_TranslateError(iErrorID, sErrorCharString, n * iSTRING_BUFFER_LENGTH))
		{
			// char buffer is not big enough
			free(sErrorCharString);
			n++;
			char* sErrorCharString = (char*) malloc(n * iSTRING_BUFFER_LENGTH * sizeof(char));
			if(sErrorCharString == 0)
				return (std::string("\nOut of memory!"));
		}
	}

	return std::string(sErrorCharString);
}

