%
function graph = nmssCreateGraphFromAutoROI(img, row_index_of_max, ...
                                            bg_threshold, image_signature, ...
                                            white_light, roi_x, roi_wx)
% determinates the optimum ROI
% index_of_maximum - the y-coordinate of the peak maximum (in pixels of the 2D-image)
% col_index - the x-coordinate of the maximum of each row of the 2D-image
% returns a cell of graph structures
    % transpose peaks vector if necessary
    if (size(image_signature,2) ~= 1)
        image_signature = image_signature';
    end
    graph = {};
    
    % check if peak maximum has bee n found
    if (isempty(row_index_of_max))
        return;
    end
    
    num_of_peaks = size(row_index_of_max,1);
    i = 1;
    for k= 1:num_of_peaks
        % take a vertical crosssection of the 2D image at the location of the
        % peak maximum
        spectrum_max_row = row_index_of_max(k,1);
        

        % we need to work on the y-crossection of the image at the peak
        % maximum to identify the y-size of the peak
        crosssec = image_signature;

        % determine the both ends of the y-crossection of the spectrum
        
        % step 1: we need a threshold: we take the average mean of mean and
        % median
        % step 2: subtracting the threshold
        crossec_minus_th = crosssec - bg_threshold;

        %crossec_minus_mean = crosssec - bg_threshold;
        % step 3: setting all negative value to zero
        indices_of_non_zero_values = find(crossec_minus_th > 0);
        crossec_minus_mean_positive = zeros(size(crossec_minus_th));
        crossec_minus_mean_positive(indices_of_non_zero_values) = crossec_minus_th(indices_of_non_zero_values);

        % separate the resulting graph in to halves:
        % left of the peak maximum and right of the maximum
        left_of_peak = crossec_minus_mean_positive(1:floor(spectrum_max_row),1);
        right_of_peak = crossec_minus_mean_positive(floor(spectrum_max_row)+1:size(crosssec,1),1);
        
        % find the first occurance of zero, this will be the
        % higher index end of the peak
        index_of_right_side_of_peak = find(right_of_peak == 0, 1,'first') + floor(spectrum_max_row);
        % lower index end of the peak
        index_of_left_side_of_peak = find(left_of_peak == 0, 1,'last');
        
        % store ROI-s
        % particle:
        roi.particle.x = roi_x;
        roi.particle.wx = roi_wx;
        roi.particle.valid = 0;
        % check if index_of_right_side_of_peak or
        % index_of_left_side_of_peak are empty matrices
        if (~isempty(index_of_right_side_of_peak) & ~isempty(index_of_left_side_of_peak))
            roi.particle.y = index_of_left_side_of_peak;
            roi.particle.wy = index_of_right_side_of_peak - index_of_left_side_of_peak + 1; % + 1, because we wanna include the upper boundary
        else
            continue; % roi is invalid skip this step
        end
            
        if (roi.particle.y < 1)
            continue; % roi is invalid skip this step
        elseif (roi.particle.y +  roi.particle.wy > size(img,1))
            continue; % roi is invalid skip this step
        end
        
        roi.particle.valid = 1;
        
        [roi.bg1, roi.bg2] = nmssGetAutoBackground(roi.particle, image_signature, bg_threshold);
        
        graph{i,1} = nmssCreateGraph(img, roi, white_light, 1);
        i = i+1;
        
%         % draws a yellow rectangle around the roi used for background (works only if the figure is displayed with axes set to pixel unit!)
%         fig = app.nmssFigure;
%             figure(fig);
%             nmssDrawRectBetween2Points([roi.particle.x, roi.particle.y], ...
%                 [roi.particle.x+roi.particle.wx, roi.particle.y+roi.particle.wy], 1, 'b');
%             if (roi.bg1.valid)
%                 nmssDrawRectBetween2Points([roi.bg1.x, roi.bg1.y], ...
%                     [roi.bg1.x+roi.bg1.wx, roi.bg1.y+roi.bg1.wy], 1, 'y');
%             end
%             if (roi.bg2.valid)
%                 nmssDrawRectBetween2Points([roi.bg2.x, roi.bg2.y], ...
%                     [roi.bg2.x+roi.bg2.wx, roi.bg2.y+roi.bg2.wy], 1, 'y');
%             end
%         end
        
    end
