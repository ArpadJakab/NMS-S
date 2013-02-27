function hCamera = nmssCAMInit()
% nmssCAMInit - initializes the camera (loads library, opens communication
% channels, prepares it to acquire an image)
%  Returns hCamera the camera handle
hCamera = -1;
[status val] = nmssCAMOpen();
if (strcmp(status,'ERROR'))
    errordlg(val);
    return;
else
    hCamera = val;
end

