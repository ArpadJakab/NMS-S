#include "StdAfx.h"
#include ".\obuffer.h"
#include ".\..\pvcam.h"
#include "stdio.h"

OBuffer::OBuffer(void)
{
	m_poImagesBuffer = 0;
	m_nNumOfFrames = 1;
	m_nNumOfBytesInImage = 0;

}

OBuffer::~OBuffer(void)
{
	DeleteFrameBuffer(m_poImagesBuffer, m_nNumOfFrames);
}

uns16** OBuffer::CreateFrameBuffer(unsigned int nNumOfFrames, unsigned int nNumOfBytesInImage) 
throw(std::string) 
{
		// here we store the poiters to the image-frames
		uns16* poImageBuffer = 0;
		uns16** poImagesBuffer = new uns16*[nNumOfFrames];

		unsigned int nBufferSize = 0;
		if (nNumOfBytesInImage % sizeof(uns16) == 0)
			nBufferSize = nNumOfBytesInImage / sizeof(uns16);
		else
			nBufferSize = nNumOfBytesInImage / sizeof(uns16) + 1;

		// throw error? number of byte should be an even number as the data is stored in unsigned shorts (uns16)
		// which contain only 2 bytes
		for (unsigned int k = 0; k < nNumOfFrames; k++) {
			poImageBuffer = new uns16[nBufferSize];
			if (poImageBuffer == NULL) {
				std::string sErrMsg("Insufficient amount of memory for ");
				sErrMsg += nNumOfFrames;
				sErrMsg += " frames! Try a lower number of frames!";
				throw sErrMsg;
			}
			poImagesBuffer[k] = poImageBuffer;
		}

		m_poImagesBuffer = poImagesBuffer;
		m_nNumOfFrames = nNumOfFrames;
		return poImagesBuffer;
}

void OBuffer::DeleteFrameBuffer(uns16** poImagesBuffer, unsigned int nNumOfFrames)
{
	if (poImagesBuffer != 0) {
		for (unsigned int k = 0; k < nNumOfFrames;	 k++) {
			delete[] poImagesBuffer[k];
		}
		delete[] poImagesBuffer;
	}
}

void OBuffer::Test(char* sTestText, int iLengthOfStringBuffer)
{
	char* sFormat = "OBuffer is externally linked to the calling function";
	_snprintf(sTestText, iLengthOfStringBuffer, sFormat);
}

unsigned int OBuffer::GetSize()
{
	return m_nNumOfBytesInImage * m_nNumOfFrames;
}


