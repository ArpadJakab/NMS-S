#include "StdAfx.h"
#include ".\otools.h"
#include <time.h>
#include "windows.h"


OTools::OTools(void)
{
}

OTools::~OTools(void)
{
}

// sleeps for the given amount of milliseconds 
void OTools::Sleep(unsigned int iSleepTime_ms,
					bool bPrintElapsedSeconds) 
{
	// loop performed for 10 seconds, printing the elapsed time in seconds at every second
	LARGE_INTEGER lWait, lStart, lSecondStart, lCounter, lFrequency;
	if (QueryPerformanceFrequency(&lFrequency)) // gets the clocks_per_second value for the system
	{
		// calculate the amount of counts corresponding to iSleepTime_ms milliseconds
		__int64 iWait = iSleepTime_ms / 1000 * lFrequency.QuadPart;
		// get the current counter value we use this as the start time
		QueryPerformanceCounter(&lStart);
		__int64 iGoal = iWait + lStart.QuadPart;
		lSecondStart = lStart;

		// start waiting loop 
		for(QueryPerformanceCounter(&lCounter); iGoal > lCounter.QuadPart; QueryPerformanceCounter(&lCounter)) 
		{
			if (bPrintElapsedSeconds) 
			{
				// the elapsed time in seconds
				__int64 iElapsed = lCounter.QuadPart - lSecondStart.QuadPart;
				
				// if 1 second has elapsed reset the second counter
				if ((double)iElapsed / (double)lFrequency.QuadPart >= 1)
				{
					// get new starting position for the new "second"
					QueryPerformanceCounter(&lSecondStart);
					// print the overall elapsed time since start time
					printf("\n%g seconds elapsed", 
						(double)(lSecondStart.QuadPart - lStart.QuadPart) / lFrequency.QuadPart);
				}
			}
		}
	}
	else
	{
		// No high resolution performance counter; 
		// use the c library for clock
		clock_t goal;
		clock_t wait = (clock_t)(iSleepTime_ms * 1e-3 * CLOCKS_PER_SEC); // ms
		
		goal = wait + clock();
		while( goal > clock() ); // loop for the given duration
	}

	printf("\nNow I have been waiting for %g seconds\n", (double) iSleepTime_ms * 1e-3 );
}



