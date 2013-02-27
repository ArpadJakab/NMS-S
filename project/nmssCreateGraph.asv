% function return_graph = nmssCreateGraph(img, roi, white_light_normalized, bg_correction)
% % returns graph structure, where
% % graph.particle - is the graph of the particle
% % graph.bg - is the graph of the background
% % graph.bg_valid - is a flag indicating that a background could be
% %                  allocated for the particle
% % graph.normalized - is the background corrected and white light normalized
% %                    spectrum. In case no valid background is present the white light
% %                    normalization is omitted and this is equal to graph.particle
% % graph.axis.x - the values of the x-axis (can be pixel or nanometers)
% %
% 
%     % initialize helper variable
%     graph = nmssResetGraph();
%     % initalize return variable
%     return_graph = graph;
% 
%     % TEMPORARY CODE!!!
%         % white light normalization
%         norm_img = cast(img,'double') ./ (white_light_normalized + min(min(white_light_normalized)) + 0.001);
%     
%     % integrating 2d-roi area along the vertical direction
%     % the particle:
%     if (roi.particle.valid)
%         try
%         graph.particle = cast(sum(norm_img(roi.particle.y : roi.particle.y+roi.particle.wy - 1,...
%                                  roi.particle.x : roi.particle.x+roi.particle.wx - 1),1),'double');
%         catch
% 			disp('Error occured! switched into debug mode...');
%             keyboard;
%         end
%         graph.offset_x_px = roi.particle.x;
%         white_light = white_light_normalized;
%     else
%         graph.particle = zeros(1,size(norm_img,2));
%         graph.offset_x_px = 1;
%         white_light = ones(1,size(norm_img,2));
%     end
%     
%     bg_img = cast(zeros(1,roi.particle.wx),'uint32');
%     num_of_pixel_lines_in_bg_img = 1;
%     
%     % -----------------------------------------------
%     % Background correction
%     if (bg_correction == 1)
%     % do background correction
%         % first: determine how much room we have above and below the
%         % particle spectrum ROI
%         if (roi.particle.y - roi.particle.wy - 1 >= 1)
%             bg_y_above = roi.particle.wy;
%         else
%             bg_y_above = roi.particle.y - 1;
%         end
%         
%         if (roi.particle.y + 2 * roi.particle.wy - 1 <= size(norm_img,1))
%             bg_y_below = roi.particle.wy;
%         else
%             bg_y_below = size(norm_img,1) - (roi.particle.y + roi.particle.wy - 1);
%         end
%         
%         % get beckground only from a region which is not too far away from
%         % the particle spectrum
%         if (bg_y_above > 3)
%             bg_y_above = 3;
%         end
%         if (bg_y_below > 3)
%             bg_y_below = 3;
%         end
%         
%         % create bacground graph
%         bg_img = cast(sum(norm_img( roi.particle.y - bg_y_above : roi.particle.y - 1,...
%                       roi.particle.x : roi.particle.x + roi.particle.wx - 1),1),'uint32') + ...
%                  cast(sum(norm_img(roi.particle.y + roi.particle.wy : roi.particle.y + roi.particle.wy + bg_y_below - 1,...
%                       roi.particle.x : roi.particle.x + roi.particle.wx - 1),1),'uint32');
%         
%         num_of_pixel_lines_in_bg_img = bg_y_above + bg_y_below;
%         
%         graph.bg_valid = 1;
%     end
%     
%     
%     graph.bg = zeros(size(graph.particle));
%     % calculate the graph of the background. It has to be scaled with the
%     % relation of the vertical width of the background roi to the vertical
%     % width of the particle roi
%     bg_scaling_factor = roi.particle.wy / num_of_pixel_lines_in_bg_img;
%     graph.bg = cast(bg_img * bg_scaling_factor,'double');
%     
%     try
%         bg_subtracted = graph.particle - graph.bg;
%         %bg_subtracted = nmssSmoothGraph(graph.particle, 'arpad', 91) - nmssSmoothGraph(graph.bg, 'arpad', 91);
%     catch
%         disp('Error occured! switched into debug mode...');
%         keyboard;
%     end
%     
%     
%     % check the error condition: the background subtrackted particle
%     % spectrum vector has to have the same length as white light
%     if (length(bg_subtracted) ~= length(white_light))
%         return;
%     end
%     
%     % due to smooting artefacts we need to change the values at the
%     % beginning and the end of the spectra (otherwise the smoothing
%     % algorithm uses the first and the last values and smoothes inbetween
%     % which leads to artefacts because these values are usually
%     % very noisy)
%     bg_subtracted_smooth = nmssSmoothGraph(bg_subtracted);
%     bg_subtracted_smooth(1:2) = bg_subtracted_smooth(3:4);
%     bg_subtracted_smooth(end-1:end) = bg_subtracted_smooth(end-3:end-2);
% 
%     % white light normalization
%     if (graph.bg_valid)
%         %graph.normalized = smooth(bg_subtracted ./ white_light, 31, 'rloess')';
% %         graph.normalized = bg_subtracted ./ white_light;
% %         graph_smoothed = bg_subtracted_smooth ./ white_light;
%         graph.normalized = bg_subtracted;
%         graph_smoothed = bg_subtracted_smooth;
%         
%     else
%         % no normalization if the background hasn't been subtracted
%         %graph.normalized = smooth(bg_subtracted, 50)';
%         graph.normalized = bg_subtracted;
%         graph_smoothed  = bg_subtracted_smooth;
%     end
%     
%     
%     % store smoothed version, we may need it!
%     graph.smoothed = nmssSmoothGraph(graph_smoothed);
%     
%     
%     % the ROI around the particle, the particle center loacation is at:
%     % y + floor(wy / 2)
%     graph.roi = roi;
% 
%     % now create the x-axis of the graph
%     global doc;
%     full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
%     axis_x = (full_lim.x(1,1): (full_lim.x(1,2) - full_lim.x(1,1)) / size(doc.img,2) : full_lim.x(1,2));
%     
%     % the x-axis of the graph
%     graph.axis.x = axis_x(1, floor(graph.offset_x_px) : floor(graph.offset_x_px + size(graph.particle,2) - 1));
%     % the unit of the x-axis (maybe we'll need it
%     graph.axis.unit.x = doc.figure_axis.unit.x;
%     
%     % set returned variable
%     return_graph = graph;
    
    
function return_graph = nmssCreateGraph(img, roi, white_light_normalized, bg_correction)
% returns graph structure, where
% graph.particle - is the graph of the particle
% graph.bg - is the graph of the background
% graph.bg_valid - is a flag indicating that a background could be
%                  allocated for the particle
% graph.normalized - is the background corrected and white light normalized
%                    spectrum. In case no valid background is present the white light
%                    normalization is omitted and this is equal to graph.particle
% graph.axis.x - the values of the x-axis (can be pixel or nanometers)
%

    % initialize helper variable
    graph = nmssResetGraph();
    % initalize return variable
    return_graph = graph;
    
    % integrating 2d-roi area along the vertical direction
    % the particle:
    if (roi.particle.valid)
        try
        graph.particle = cast(sum(img(roi.particle.y : roi.particle.y+roi.particle.wy - 1,...
                                 roi.particle.x : roi.particle.x+roi.particle.wx - 1),1),'double');
        catch
			disp('Error occured! switched into debug mode...');
            keyboard;
        end
        graph.offset_x_px = roi.particle.x;
        white_light = white_light_normalized;
    else
        graph.particle = zeros(1,size(img,2));
        graph.offset_x_px = 1;
        white_light = ones(1,size(img,2));
    end
    
    bg_img = cast(zeros(1,roi.particle.wx),'uint32');
    num_of_pixel_lines_in_bg_img = 1;
    
    % -----------------------------------------------
    % Background correction
    if (bg_correction == 1)
    % do background correction
        % first: determine how much room we have above and below the
        % particle spectrum ROI
        if (roi.particle.y - roi.particle.wy - 1 >= 1)
            bg_y_above = roi.particle.wy;
        else
            bg_y_above = roi.particle.y - 1;
        end
        
        if (roi.particle.y + 2 * roi.particle.wy - 1 <= size(img,1))
            bg_y_below = roi.particle.wy;
        else
            bg_y_below = size(img,1) - (roi.particle.y + roi.particle.wy - 1);
        end
        
        % get beckground only from a region which is not too far away from
        % the particle spectrum
        if (bg_y_above > 3)
            bg_y_above = 3;
        end
        if (bg_y_below > 3)
            bg_y_below = 3;
        end
        
        % create bacground graph
        bg_img = cast(sum(img( roi.particle.y - bg_y_above : roi.particle.y - 1,...
                      roi.particle.x : roi.particle.x + roi.particle.wx - 1),1),'uint32') + ...
                 cast(sum(img(roi.particle.y + roi.particle.wy : roi.particle.y + roi.particle.wy + bg_y_below - 1,...
                      roi.particle.x : roi.particle.x + roi.particle.wx - 1),1),'uint32');
        
        num_of_pixel_lines_in_bg_img = bg_y_above + bg_y_below;
        
        graph.bg_valid = 1;
    end
    
    
    graph.bg = zeros(size(graph.particle));
    % calculate the graph of the background. It has to be scaled with the
    % relation of the vertical width of the background roi to the vertical
    % width of the particle roi
    bg_scaling_factor = roi.particle.wy / num_of_pixel_lines_in_bg_img;
    graph.bg = cast(bg_img * bg_scaling_factor,'double');
    
    try
        bg_subtracted = graph.particle - graph.bg;
        %bg_subtracted = nmssSmoothGraph(graph.particle, 'arpad', 91) - nmssSmoothGraph(graph.bg, 'arpad', 91);
    catch
        disp('Error occured! switched into debug mode...');
        keyboard;
    end
    
    
    % check the error condition: the background subtrackted particle
    % spectrum vector has to have the same length as white light
    if (length(bg_subtracted) ~= length(white_light))
        return;
    end
    
    % due to smooting artefacts we need to change the values at the
    % beginning and the end of the spectra (otherwise the smoothing
    % algorithm uses the first and the last values and smoothes inbetween
    % which leads to artefacts because these values are usually
    % very noisy)
    bg_subtracted_smooth = nmssSmoothGraph(bg_subtracted);
    bg_subtracted_smooth(1:2) = bg_subtracted_smooth(3:4);
    bg_subtracted_smooth(end-1:end) = bg_subtracted_smooth(end-3:end-2);

    % white light normalization
    if (graph.bg_valid)
        %graph.normalized = smooth(bg_subtracted ./ white_light, 31, 'rloess')';
        graph.normalized = bg_subtracted ./ white_light;
        graph_smoothed = bg_subtracted_smooth ./ white_light;
        
    else
        % no normalization if the background hasn't been subtracted
        %graph.normalized = smooth(bg_subtracted, 50)';
        graph.normalized = bg_subtracted;
        graph_smoothed  = bg_subtracted_smooth;
    end
    
    
    % store smoothed version, we may need it!
    graph.smoothed = nmssSmoothGraph(graph_smoothed);
    
    % the ROI around the particle, the particle center loacation is at:
    % y + floor(wy / 2)
    graph.roi = roi;

    % now create the x-axis of the graph
    global doc;
    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    axis_x = full_lim.x(1,1): (full_lim.x(1,2) - full_lim.x(1,1)) / size(doc.img,2) : full_lim.x(1,2);
    
    % the x-axis of the graph
    graph.axis.x = axis_x(1, floor(graph.offset_x_px) : floor(graph.offset_x_px + size(graph.particle,2) - 1));
    % the unit of the x-axis (maybe we'll need it
    graph.axis.unit.x = doc.figure_axis.unit.x;
    
    % store noise filtered graph
    [graph.noise_filtered, filter_th] = noisefilter(graph.axis.x, graph.normalized, 50); % max period of the filtered frequency components 50 nm
    
    
    % set returned variable
    return_graph = graph;
    
    
