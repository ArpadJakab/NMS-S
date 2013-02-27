function full_limits = nmssGetFullImageLimits(unit)
% INPUT:
% unit - the unit you want to have the figure axis limits being returned
% EXEPTION: if the 'unit' is 'nanometer' only the x-axis is returned in
% nanometers the y-axis will be returned in pixels
%
% RETURN: the full_limits structure, where
% full_limits.x - contains the x-axis limits of the FULL image (not the
% zoomed image!)
% full_limits.y - contains the y-axis limits of the FULL image (not the
% zoomed image!)

    figure_axis = nmssSetAxis(unit);
    
    global doc;
    
    full_limits.x = ([1, size(doc.img,2)] - size(doc.img,2) / 2.0) * figure_axis.scale.current.x + figure_axis.center.x;
    full_limits.y = ([1, size(doc.img,1)] - size(doc.img,1) / 2.0) * figure_axis.scale.current.y + figure_axis.center.y;
