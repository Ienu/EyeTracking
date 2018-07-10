@echo off
FOR /l %%i IN (1000, 1000, 14000) DO (
	MKDIR C:\Users\workspace\Lwy\Data9\r%%i
	C:\Users\workspace\Lwy\Openface\CLM-framework-master2\CLM-framework-master\Release\FeatureExtraction.exe -outroot C:\Users\workspace\Lwy\Data9\r%%i\ -oaus au.txt -ogaze gaze.txt -simaligndir . -oparams params.txt -op pose.txt -of landmark.txt -fdir C:\Users\workspace\Lwy\Data9\%%i
	MOVE landmark.txt C:\Users\workspace\Lwy\Data9\r%%i\
	MOVE pose.txt C:\Users\workspace\Lwy\Data9\r%%i\
)
pause
