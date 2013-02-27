// nmssCAMControl.h : header file
//
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////

class OnmssCAMControl
{
// Construction
public:

// Implementation
protected:
    bool m_bUseCircBuf;

    CString GetFirstCamName();

    void Openlib();
    void Opencam();
    void Closelib();
    void Abort();
};

