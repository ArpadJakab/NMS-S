function [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi, unit )
%nmssConvertROIStartEnd converts roi data into start-end coordinates. That 
%   are the upper left coordinates and the bottom right coordinates
%
%  IN: 
%      roi - the ROI (region of interest)
%      unit - the unit of the roi
%  OUT:
%       start_x, start_y -  the coordinates of the upper left corner
%       end_x, end_y -  the coordinates of the bottom right corner

    roi_px = nmssConvertROIUnit2Pixel(roi, unit);
    roi_px.wx = roi_px.wx-1;
    roi_px.wy = roi_px.wy-1;
    
    roi_unit = nmssConvertROIPixel2Unit(roi_px, unit);
    start_x = roi_unit.x;
    start_y = roi_unit.y;
    end_x = roi_unit.x + roi_unit.wx;
    end_y = roi_unit.y + roi_unit.wy;
    