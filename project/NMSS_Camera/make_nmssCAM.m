% copyfile('.\nmssCamLib\Debug\nmssCamLib.dll', '.\nmssCamLib.dll')
mex nmssCAMOpen.cpp Pvcam32.lib
mex nmssCAMClose.cpp Pvcam32.lib
mex nmssCAMGetImage.cpp Pvcam32.lib
%mex -v nmssCAMStartContExp.cpp Pvcam32.lib '.\nmssCamLib\Debug\nmssCamLib.lib'