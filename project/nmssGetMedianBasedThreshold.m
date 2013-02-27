function threshold = nmssGetMedianBasedThreshold(data)
% this function has been determined by experiment. The threshold given back
% is usually a good measure to distinguish between peaks and other
% insignificant structures in the image
% data - a 1-dimensional data containing peaks

    % 0.5 is a magic number
    threshold = median(data) + 0.5 * std(data);
    
