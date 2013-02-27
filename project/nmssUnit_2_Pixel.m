function [pixel_x, pixel_y] = nmssUnit_2_Pixel(value_x,  value_y, unit)
    px_unit.x = 'pixel';
    px_unit.y = 'pixel';
    figure_axis_px = nmssSetAxis(px_unit);
    figure_axis_unit = nmssSetAxis(unit);
    
    pixel_x = (value_x - figure_axis_unit.center.x) / figure_axis_unit.scale.current.x + figure_axis_px.center.x;
    pixel_y = (value_y - figure_axis_unit.center.y) / figure_axis_unit.scale.current.y + figure_axis_px.center.y;

