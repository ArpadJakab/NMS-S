function roi_in_unit = nmssConvertROIPixel2Unit(roi_in_pixel, unit)
% converts roi uinits to pixels
    roi_in_unit = roi_in_pixel;

    if (~strcmp(unit.x,'pixel'))
        [roi_in_unit.x, roi_in_unit.y] = nmssPixel_2_Unit(roi_in_pixel.x, roi_in_pixel.y, unit);
        end_x = roi_in_pixel.x + roi_in_pixel.wx - 1;
        end_y = roi_in_pixel.y + roi_in_pixel.wy - 1;
        
        [xx_px, yy_px]  = nmssPixel_2_Unit(end_x, end_y, unit);
        
        % get the size of one pixel in unit
        [tmp_x, tmp_y] = nmssPixel_2_Unit(roi_in_pixel.x + 1, roi_in_pixel.y + 1, unit);
        one_x = abs(tmp_x - roi_in_unit.x);
        one_y = abs(tmp_y - roi_in_unit.y);
        
        roi_in_unit.wx = xx_px - roi_in_unit.x + one_x;
        roi_in_unit.wy = yy_px - roi_in_unit.y + one_y;
        
        roi_in_pixel.unit = unit;
    end
    
