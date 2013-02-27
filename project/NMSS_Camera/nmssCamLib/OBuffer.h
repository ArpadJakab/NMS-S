#pragma once

#include "..\master.h"
#include <string>

class __declspec( dllexport ) OBuffer
{
public:
	OBuffer(void);
	~OBuffer(void);
	void Test(char* sTestText, int iLengthOfStringBuffer);
	
	uns16** CreateFrameBuffer(unsigned int nNumOfFrames, unsigned int nNumOfBytesInImage) 
		throw(std::string);
	// returns the size of the buffer
	unsigned int GetSize();

private:
	uns16** m_poImagesBuffer;
	unsigned int m_nNumOfFrames;
	unsigned int m_nNumOfBytesInImage;

	void DeleteFrameBuffer(uns16** poImagesBuffer, unsigned int nNumOfFrames);
};
