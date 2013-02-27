function [value_x,  value_y]= nmssPixel_2_Unit(pixel_x, pixel_y, unit)
% converts pixel coordinates into unit coordinates
% pixel_x - x-coordinate in pixel
% pixel_y - y-coordinate in pixel
% unit - unit structure containing the target unit
    px_unit.x = 'pixel';
    px_unit.y = 'pixel';
    
    figure_axis_px = nmssSetAxis(px_unit);
    figure_axis_unit = nmssSetAxis(unit);
    value_x = (pixel_x - figure_axis_px.center.x) * figure_axis_unit.scale.current.x + figure_axis_unit.center.x;
    value_y = (pixel_y - figure_axis_px.center.y) * figure_axis_unit.scale.current.y + figure_axis_unit.center.y;

