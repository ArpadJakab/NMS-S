// PVCAMTESTDlg.h : header file
//

#if !defined(AFX_PVCAMTESTDLG_H__2668F3A8_F3DD_11D2_A7F7_0050041313BC__INCLUDED_)
#define AFX_PVCAMTESTDLG_H__2668F3A8_F3DD_11D2_A7F7_0050041313BC__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CPVCAMTESTDlg dialog

class CPVCAMTESTDlg : public CDialog
{
// Construction
public:
	CPVCAMTESTDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CPVCAMTESTDlg)
	enum { IDD = IDD_PVCAMTEST_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPVCAMTESTDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
    bool m_bUseCircBuf;

    CString GetFirstCamName();

    void Openlib();
    void Opencam();
    void Closelib();
    void Abort();

    // Generated message map functions
	//{{AFX_MSG(CPVCAMTESTDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnStart();
	afx_msg void OnStop();
	afx_msg void OnClose();
	afx_msg void OnDone();
	afx_msg void OnCollectImage();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PVCAMTESTDLG_H__2668F3A8_F3DD_11D2_A7F7_0050041313BC__INCLUDED_)
