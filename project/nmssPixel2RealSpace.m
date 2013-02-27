function x_pos  = nmssPixel2RealSpace( x_pixel, x_size_real_space_img, x_pos_min, x_pos_max )
%converts pixel coordinates to real space coordinates which depend on the
% scanning imaging setting (i.e the staring and end coordinates of the
% scanning table)
%  Detailed explanation goes here
    
    
    x_px_max = x_size_real_space_img;
    x_px_min = 1;
    
    x_pos = x_pos_min + (x_pixel - 1) * (x_pos_max - x_pos_min) / (x_px_max - x_px_min);
    
