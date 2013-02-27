function [ roi_unit] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, unit )
%nmssConvertROIStartEnd converts roi data into start-end coordinates. That 
%   are the upper left coordinates and the bottom right coordinates
%
%  IN: 
%       start_x, start_y -  the coordinates of the upper left corner
%       end_x, end_y -  the coordinates of the bottom right corner
%       unit - the unit of the roi
%  OUT:
%      roi - the ROI (region of interest)

    roi = nmssResetROI();
    roi.x = start_x;
    roi.y = start_y;
    roi.wx = end_x - start_x;
    roi.wy = end_y - start_y;

    roi_px = nmssConvertROIUnit2Pixel(roi, unit);
    roi_px.wx = roi_px.wx+1;
    roi_px.wy = roi_px.wy+1;
    
    roi_unit = nmssConvertROIPixel2Unit(roi_px, unit);
