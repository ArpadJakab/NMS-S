/*********************************************************************
** Matlab Control Software for the CoolSnapHQ2-CCD (via PVCAM)
** NanoBioTech Group - Uni Mainz
** Date: 13.04.2007
** Filename: nmssCAMGetImage.h
** Author: Olaf Schubert, schubero@uni-mainz.de
** 
** Acquires an image (using PVCAM)
***********************************************/
// symbol defiitions
#ifndef NMSSCAMGETIMAGE_H
#define NMSSCAMGETIMAGE_H

#ifndef WIN32
#define WIN32
#endif

// neccessary includes
#include "mex.h"
#include "master.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]);
void nmssCAM_disp_time_resolution_setting(int16 hCam);
void nmssCAM_pl_cam_close(int16 hCam, bool bVerbose = false);
void nmssCAM_CheckROIRange(int16 hCam, 
                                 unsigned int iWidth, unsigned int iHeight,
                                 unsigned int iXpos, unsigned int iYpos)
                                 throw(char*);
uns16** nmssCAM_CreateFrameBuffer(unsigned int nNumOfFrames, unsigned int nNumOfBytesInImage)
								 throw(char*);
void nmssCAM_DeleteFrameBuffer(uns16** poImagesBuffer, unsigned int nNumOfFrames);



#endif // NMSSCAMGETIMAGE_H