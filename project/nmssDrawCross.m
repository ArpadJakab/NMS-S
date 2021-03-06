function hCross = nmssDrawCross(center_x, center_y, width, height)
% draws a cross centered around center_x, .._y
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    half_width = width / 2;
    half_height = height / 2;
    
    hLine1 = line([center_x-half_width; center_x+half_width], [center_y; center_y], 'Color','r','LineWidth',2);
    hLine2 = line([center_x; center_x], [center_y-half_height; center_y+half_height], 'Color','r','LineWidth',2);
    
    hCross = [hLine1, hLine2];
