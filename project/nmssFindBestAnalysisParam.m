function best_analysis = nmssFindBestAnalysisParam( real_space_img, analysis )
%nmssFindBestAnalysisParam - finds best analysis parameters to maximalize
%the number of particles found in the real space image

    best_analysis = analysis;
    best_weight = analysis.std_weighing;
    tmp_max_pos_x_length = 0;

    % check if image is a vector or a matrix
    if (isvector(real_space_img.img))
        max_img = max(real_space_img.img);
    else
        max_img = max(max(real_space_img.img));
    end

    waitbar_handle = waitbar(0,'Looking for the best threshold...','CreateCancelBtn','delete(gcf);');
    
    tmp_analysis = analysis;
    tmp_analysis.std_weighing = 0.1;
    threshold = 0;
    while (threshold < max_img) 
        if (ishandle(waitbar_handle))
            waitbar(threshold / max_img);
        else
            % user canceled
            break;
        end
        
        [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            nmssFindBrightSpots( real_space_img.img, tmp_analysis );

        max_pos_x_length = length(max_pos_x);

        if (max_pos_x_length > tmp_max_pos_x_length)
            tmp_max_pos_x_length = max_pos_x_length;
            best_weight = tmp_analysis.std_weighing;
        end
        tmp_analysis.std_weighing = tmp_analysis.std_weighing + 0.1;
    end
    
    % clear waitbar
    if (ishandle(waitbar_handle))
        delete(waitbar_handle);
    end
    
    disp(['Analysis - stdev best weight:', num2str(best_weight)]);
    best_analysis.std_weighing = best_weight;

