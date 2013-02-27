// nmssCamLib.h : main header file for the nmssCamLib DLL
//

#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols


// CnmssCamLibApp
// See nmssCamLib.cpp for the implementation of this class
//

class CnmssCamLibApp : public CWinApp
{
public:
	CnmssCamLibApp();

// Overrides
public:
	virtual BOOL InitInstance();

	DECLARE_MESSAGE_MAP()
};
