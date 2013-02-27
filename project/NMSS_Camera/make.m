e710_path = ['./E710_GCS_DLL/E7XX_GCS_DLL.lib'];

mex "nmssPSConnect.cpp" e710_path;
mex "nmssPSXAxisLowEnd.cpp";
mex nmssPSXAxisHighEnd.cpp ./E710_GCS_DLL/E7XX_GCS_DLL.lib;
