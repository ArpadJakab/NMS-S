function roi_struct = nmssResetROI()
% handles  -  structure with handles and user data (see GUIDATA), among
% others it also contains the handles of the ROI variables
% reset ROI containing backgroud - this is called every time if the ROI size (though not the position) for
% the particle has changed

% returns the background structure
    roi_struct.exists = 0;
    roi_struct.valid = 0;
    roi_struct.x = 1;
    roi_struct.y = 1;
    roi_struct.wx = 1;
    roi_struct.wy = 1;
    