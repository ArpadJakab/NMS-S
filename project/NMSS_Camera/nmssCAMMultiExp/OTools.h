#pragma once

class OTools
{
public:
	OTools(void);
	~OTools(void);

	// sleeps for the given amount of milliseconds
	static void Sleep(unsigned int iSleepTime_ms,
					  bool bPrintElapsedSeconds = false); 
};
