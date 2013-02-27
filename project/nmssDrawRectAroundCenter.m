function hRectangle = nmssDrawRectAroundCenter(center_x, center_y, width, height, varargin)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    tag = 'nmss_rectangle';
    
    if (length(varargin) >= 1)
        tag = varargin{1};
    end

    half_width = width / 2;
    half_height = height / 2;
    
    line_coord_x = [center_x - half_width; center_x+half_width; center_x+half_width; center_x-half_width; center_x-half_width];
    line_coord_y = [center_y-half_height; center_y-half_height; center_y+half_height; center_y+half_height; center_y-half_height];
    
    hRectangle = line(line_coord_x,line_coord_y,'Color','r','LineWidth',2, 'Tag', tag);
