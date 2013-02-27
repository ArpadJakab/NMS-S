// PVCAMTESTDlg.cpp : implementation file
//


#include "stdafx.h"

#define C3_BUFFER_OVERRUN 3033
extern "C" 
{
#include "win.h"
#include "master.h"
#include "pvcam.h"
}

#include "PVCAMTEST.h"
#include "PVCAMTESTDlg.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/* Global Memory Pointers */
HGLOBAL buffer;
void *memory;
unsigned short *data;
unsigned short *user_data;

/* Display Window Handle */
HWND GlobalWindowHandle;
HANDLE GlobalThreadHandle;

/* Pvcam Camera Identifier */	
short hCam;	

/* Region Of Interest, Layout */
unsigned short S1 = 0;		// Serial Start
unsigned short S2 = 1295;		// Serial Stop
unsigned short SB = 1;		// Serial Binning
unsigned short P1 = 0;		// Parallel Start
unsigned short P2 = 1029;		// Parallel Stop
unsigned short PB = 1;		// Parallel Binning

DWORD Thread_ID = 0;

/* Thread Prototype for Focusing */
DWORD WINAPI FocusThread( PVOID bUsingCircBuf );

/* Global State Running or Not */
short running = false;


#define COMPLETE	1
#define INITIALIZED	2
#define ACQUIRED	3

short CurStatus = COMPLETE;


#define DATAOVERRUN   128   /* bit for "DMA data overrun"                */
#define VIOLATION     256   /* bit for "TAXI violation"                  */


void Init();
void Acquire();	
void Complete();

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPVCAMTESTDlg dialog

CPVCAMTESTDlg::CPVCAMTESTDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CPVCAMTESTDlg::IDD, pParent),
      m_bUseCircBuf( false )
{
	//{{AFX_DATA_INIT(CPVCAMTESTDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CPVCAMTESTDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPVCAMTESTDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}  

BEGIN_MESSAGE_MAP(CPVCAMTESTDlg, CDialog)
	//{{AFX_MSG_MAP(CPVCAMTESTDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_START, OnStart)
	ON_BN_CLICKED(IDC_STOP, OnStop)
	ON_BN_CLICKED(IDC_DONE, OnDone)
	ON_BN_CLICKED(IDC_COLLECT_IMAGE, OnCollectImage)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPVCAMTESTDlg message handlers

BOOL CPVCAMTESTDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

    GetDlgItem( IDC_STOP )->EnableWindow( false );
	
    Openlib();
    Opencam();

    // use circular buffers if they are supported
    bool bSupported = false;
    //pl_get_param( hCam, PARAM_CIRC_BUFFER, ATTR_AVAIL, &bSupported );
    m_bUseCircBuf = bSupported != 0;

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CPVCAMTESTDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CPVCAMTESTDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CPVCAMTESTDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CPVCAMTESTDlg::OnDone() 
{
    if( running )
        OnStop();

	pl_cam_close(hCam);
	pl_pvcam_uninit();
	GlobalUnlock( buffer );
	GlobalFree( buffer );	
	CDialog::OnOK();
}

void CPVCAMTESTDlg::OnCollectImage()
{
    Init();
    Acquire();
    Complete();
}

/*********************************************************************************
*
*		Focus the camera using the dma buffer allocated by the Princeton Instruments
*	device driver...
*
*********************************************************************************/
void CPVCAMTESTDlg::OnStart() 
{
	rgn_type region;
	long npixels;
	unsigned long stream_size;

	if ( CurStatus == COMPLETE )
	{
        GetDlgItem( IDC_COLLECT_IMAGE )->EnableWindow( false );
        GetDlgItem( IDC_START )->EnableWindow( false );
        GetDlgItem( IDC_STOP )->EnableWindow( true );

        if( !m_bUseCircBuf )
            Init();
        else
        {
    		unsigned short xdimension;
	    	unsigned short ydimension;
		
    		/* Setup a region of interest */
	    	pl_ccd_get_par_size(hCam, &ydimension);
		    pl_ccd_get_ser_size(hCam, &xdimension);
	
    		if ( xdimension >= 1024 )
	    	{
		    	SB = 2; PB = 2;
    		}
	    	while (((xdimension/PB) % 4) != 0)
		    	xdimension--;
		
    		region.s1   = S1 = 0;
	    	region.s2   = S2 = (unsigned short)(xdimension - 1);
		    region.sbin = SB;
    		region.p1	= P1 = 0;
	    	region.p2   = P2 = (unsigned short)(ydimension - 1);
		    region.pbin = PB;
    		npixels = ((S2-S1+1)/SB) * ((P2-P1+1)/PB);
		
	    	pl_exp_init_seq();

		    pl_exp_setup_cont(	hCam,
			    				1,						
				    			&region,
					    		TIMED_MODE,
						    	50,
							    &stream_size,
    							CIRC_OVERWRITE );

    		pl_exp_set_cont_mode(hCam, CIRC_OVERWRITE );

		    pl_exp_start_cont(hCam, buffer, npixels*12);
        }
	
		GlobalThreadHandle = CreateThread(0, 0x1000, FocusThread, (void*)m_bUseCircBuf, 0, &Thread_ID);	
		running = true;	
	}
	
}

/***********************************************************************
*
*	Stop the Camera in continuos acquisition mode....
*
*
**********************************************************************/
void CPVCAMTESTDlg::OnStop() 
{
    GetDlgItem( IDC_COLLECT_IMAGE )->EnableWindow( true );
    GetDlgItem( IDC_START )->EnableWindow( true );
    GetDlgItem( IDC_STOP )->EnableWindow( false );

	running = false;

    WaitForSingleObject( GlobalThreadHandle, 5000 );

    if( !m_bUseCircBuf )
        Complete();
    else
    {
    	Sleep(500);

	    pl_exp_finish_seq(	hCam,
		    				memory,
			    			0);
    	pl_exp_uninit_seq();

	    pl_exp_stop_cont(hCam,CCS_HALT);
    }

	CurStatus = COMPLETE;
}

CString CPVCAMTESTDlg::GetFirstCamName()
{
    // extract the camera name
    CString sName;
    const CString csDefaultValue = "xxxxx";
    const int cnMaxValueChars = 32;
    GetPrivateProfileString( "Camera_1", "Name", csDefaultValue,
      sName.GetBuffer( cnMaxValueChars ), cnMaxValueChars, "pvcam.ini" );
    sName.ReleaseBuffer();

    // check for valid name
    if( !sName.Compare( csDefaultValue ) )
        sName.Empty();

    return sName;
}

/*********************************************************************************
*
*	Open The PVCAM Library 
*
*
*********************************************************************************/
void CPVCAMTESTDlg::Openlib() 
{
	pl_pvcam_init();		
}

/*********************************************************************************
*
*	Open The PVCAM Camera: Note the name must be as it appears in the pvcam.ini 
* file...
*
*********************************************************************************/
void CPVCAMTESTDlg::Opencam() 
{	
	rgn_type region;
	long npixels;		
	char controllerstring[] = "Image Display Window";	
	char name[32];
	unsigned short xdimension = 0;
	unsigned short ydimension = 0;
	
    strcpy( name, GetFirstCamName() );

	/* Make sure ini exist */
	if ( !name[0] )
	{
		MessageBox( "No cameras found in pvcam.ini!", "Error", MB_OK);
        PostQuitMessage( 0 );
        return;
	}

	/* Open the camera */
	if( pl_cam_open(name, &hCam, OPEN_EXCLUSIVE) == FALSE )
    {
        char ErrMsg[600], PV_ErrMsg[512], PV_FullMsg[512];
    	int16 code;
    	code = pl_error_code();
    	if( code != 0 )
		{
            pl_error_message( code, PV_ErrMsg );
            sprintf( PV_FullMsg, "\n\n( %s )", PV_ErrMsg );
        }
        else
            PV_FullMsg[0] = 0;

        sprintf( ErrMsg, "Failure Opening Camera: '%s'%s", name, PV_FullMsg );
        MessageBox( ErrMsg, "Error", MB_OK );
        PostQuitMessage( 0 );
        return;
    }

	/* Setup a region of interest */
	pl_ccd_get_par_size(hCam, &ydimension);
	pl_ccd_get_ser_size(hCam, &xdimension);
	
	if ( xdimension >= 1024 )
	{
		SB = 2; PB = 2;
	}

	while(((xdimension/PB) % 4) != 0)
			xdimension--;
	
	region.s1   = S1 = 0;
	region.s2   = S2 = (unsigned short)(xdimension - 1);
	region.sbin = SB;
	region.p1	= P1 = 0;
	region.p2   = P2 = (unsigned short)(ydimension - 1);
	region.pbin = PB;
	npixels = ((S2-S1+1)/SB) * ((P2-P1+1)/PB);


	/* Allocate a frame buffer */
	buffer	 = GlobalAlloc( GMEM_ZEROINIT, npixels*12);
	memory   = GlobalLock( buffer );
	user_data	 = (unsigned short *)memory;		

	/* Set the temperature */
	pl_ccd_set_tmp_setpoint( hCam, -550 );
		
	/* Register and create a window */
	if (RegisterWindow( "Image", NULL ))
	{	
			
		GlobalWindowHandle = CreateWin( 0,
										0,
										((S2-S1+1)/SB),
						 				((P2-P1+1)/PB),
										"Image",
										&controllerstring[0],
										NULL );	
		
	}		
}

/*********************************************************************************
*
*	Close The PVCAM Library and free any allocated buffers...
*
*
*********************************************************************************/
void CPVCAMTESTDlg::Closelib() 
{
	pl_cam_close(hCam);
	pl_pvcam_uninit();
	GlobalUnlock( buffer );
	GlobalFree( buffer );
}

void Init() 
{
	rgn_type region;
	long npixels;
	unsigned long stream_size;
	unsigned short xdimension;
	unsigned short ydimension;
	
	/* Setup a region of interest */
	pl_ccd_get_par_size(hCam, &ydimension);
	pl_ccd_get_ser_size(hCam, &xdimension);
	
	if ( xdimension >= 1024 )
	{
			SB = 2; PB = 2;
	}

	while(((xdimension/PB) % 4) != 0)
			xdimension--;
	
	region.s1   = S1 = 0;
	region.s2   = S2 = (unsigned short)(xdimension - 1);
	region.sbin = SB;
	region.p1	= P1 = 0;
	region.p2   = P2 = (unsigned short)(ydimension - 1);
	region.pbin = PB;
	npixels = ((S2-S1+1)/SB) * ((P2-P1+1)/PB);

	if ( CurStatus == COMPLETE )
	{
		pl_exp_init_seq();

		pl_exp_setup_seq(	hCam,
							1,
							1,
							&region,
							TIMED_MODE,
							250,
							&stream_size);
		
		CurStatus = INITIALIZED;
	}
	
}

/*********************************************************************************
*
*	Acquire a frame into the user allocated buffer....
*
*
*********************************************************************************/
void Acquire() 
{		
	short status = 0;
	unsigned long bytes_xferd;	

	if (( CurStatus == INITIALIZED ) || ( CurStatus == ACQUIRED))
	{	
		pl_exp_start_seq(hCam, memory);
	
		while ( status != READOUT_COMPLETE )
		{		
			pl_exp_check_status( hCam, &status, &bytes_xferd );	
		}
	
		Update_Bitmap( GlobalWindowHandle, (unsigned short *)memory , TRUE );
		
		CurStatus = ACQUIRED;						
	}
}

void Complete() 
{
	if ( CurStatus == ACQUIRED )
	{
		pl_exp_finish_seq(	hCam,
							memory,
							0);

		pl_exp_uninit_seq();

		CurStatus = COMPLETE;
	}
}

/***********************************************************************
*
*		Get and Display the latest frame only, for high speed 
*	focusing...
*	Uses the Princeton Instruments Driver allocated buffer..
*
**********************************************************************/ 
DWORD WINAPI FocusThread(PVOID bUsingCircBuf )
{
	void *caddress = NULL;

    if( !bUsingCircBuf )
        while( running )
            Acquire();
    else
    {
    	while( running )
	    {	
            if( pl_exp_get_latest_frame( hCam, &caddress ) )
            {
                data = (unsigned short*)caddress;
                Update_Bitmap( GlobalWindowHandle, data, TRUE );
            }
	    }
    }
	
	return 0;
}

