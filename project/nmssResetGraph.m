function graph = nmssResetGraph()
% nmssResetGraph Summary of this function goes here
%  Detailed explanation goes here

    % initalize return variable
    graph.particle = [];
    graph.offset_x_px = 1;    
    graph.bg = [];
    graph.bg_valid = 0;
    graph.normalized = [];
    graph.smoothed = []; % stores the normalized spectrum with added smoothing
    graph.raw_bg_corr = []; % raw data minus backgorung
    graph.roi.particle = nmssResetROI();
    graph.roi.bg1 = nmssResetROI();
    graph.roi.bg2 = nmssResetROI();
    graph.axis.x = [];
    graph.axis.unit.x = [];

