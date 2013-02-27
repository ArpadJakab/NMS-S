function roi_in_pixel = nmssConvertROIUnit2Pixel(roi_in_unit, unit)
% converts roi units to pixels
    roi_in_pixel = roi_in_unit;
    
    if (~strcmp(unit.x,'pixel'))
        [r_x, r_y] = nmssUnit_2_Pixel(roi_in_unit.x, roi_in_unit.y, unit);
        roi_in_pixel.x = floor(r_x + 0.5); % round value to get integer values for pixels!
        roi_in_pixel.y = floor(r_y + 0.5);
        
        % get the size of one pixel in unit
        [tmp1_x, tmp1_y] = nmssPixel_2_Unit(roi_in_pixel.x, roi_in_pixel.y, unit);
        [tmp2_x, tmp2_y] = nmssPixel_2_Unit(roi_in_pixel.x + 1, roi_in_pixel.y + 1, unit);
        one_x = abs(tmp2_x - tmp1_x);
        one_y = abs(tmp2_y - tmp1_y);
        
        xx = roi_in_unit.x + roi_in_unit.wx - one_x; % upper limit of the roi in x
        yy = roi_in_unit.y + roi_in_unit.wy - one_y; % upper limit of the roi in y
        
        [xx_px, yy_px] = nmssUnit_2_Pixel(xx, yy, unit);
        
        roi_in_pixel.wx = floor(xx_px + 0.5) - roi_in_pixel.x + 1; % round value to get integer values for pixels!
        roi_in_pixel.wy = floor(yy_px + 0.5) - roi_in_pixel.y + 1;
        
    end
    
