function [axis_x, unit_x] = nmssGetXAxis()
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    % now create the x-axis of the graph
    global doc;
    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    axis_x = full_lim.x(1,1): (full_lim.x(1,2) - full_lim.x(1,1)) / size(doc.img,2) : full_lim.x(1,2);
    
    unit_x = doc.figure_axis.unit.x;