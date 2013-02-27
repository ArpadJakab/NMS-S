function graphs = nmssSpecAnalysis(img, white_light, ...
                                  roi_in_pixel, ...
                                  analysis_setting)
% Analizes the spextrographic image and identifies the peaks
%
% INPUT:
% img - the image as acquired from the spectrometer
% white_light - a vector containing the white light (horizontal (x)-size of img and the length of white light vector have to be the same!)
% roi_in_pixel - the ROI where we wanna analize the spectrum
% analysis_setting - analysis settings structure (see more in file:
% nmssResetAnalysisParam.m and nmssSpecAnalysisSetup.m)
    
    % inititalize return variable
    graphs = {};
    
    % cut out ROI from the full image
    roi_img = img(roi_in_pixel.y:roi_in_pixel.y+roi_in_pixel.wy - 1, ...
                  roi_in_pixel.x:roi_in_pixel.x+roi_in_pixel.wx - 1);
    img_signature = sum(roi_img');
    
    % assert the correctness
    if (isempty(img_signature))
        return;
    end
    

    real_space_img = nmssResetRealSpaceImage();
    real_space_img.img = img_signature';
    real_space_img.x_min = 1;
    real_space_img.x_max = 2;
    
    analysis = analysis_setting;
    analysis.img_signature = img_signature;

    % automatic determination of the best threshold
%     if (strcmp(analysis_setting.method, 'automatic'))
%         analysis = nmssFindBestAnalysisParam( real_space_img, analysis );
%     end
    
    % select jobs, which contain maximum intensity of particle images
    [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, analysis.threshold] = ...
        nmssFindBrightSpots( real_space_img.img, analysis);
    
    % n x 2 matrix, containing the x-position (the job (or frame) index) and the
    % y-position (the real space y-position) of a particle
    pos = [max_pos_x', max_pos_y', top_left_x', top_left_y', bottom_right_x', bottom_right_y'];
        
    roi_of_particle = nmssResetROI();
    roi_of_particle.exists = 1;
    roi_of_particle.valid = 1;
    
    num_of_particles = length(max_pos_y); 
    disp(['Analysis - threshold:', num2str(analysis.threshold)]);
    
    global doc;
    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    axis.x = (full_lim.x(1,1): (full_lim.x(1,2) - full_lim.x(1,1)) / size(doc.img,2) : full_lim.x(1,2));
    axis.unit = doc.figure_axis.unit;
    
    for k = 1:num_of_particles

        roi_of_particle.x = pos(k,3);
        roi_of_particle.y = pos(k,4);
        roi_of_particle.wx = pos(k,5) - pos(k,3) + 1;
        roi_of_particle.wy = pos(k,6) - pos(k,4) + 1;

        graphs{k} = nmssGetParticleSpectFromRealSpaceImage(roi_img, max_pos_y, white_light, roi_in_pixel, roi_of_particle, analysis, axis);
        
%         % adapting particle and background rois to the full image so the
%         % graphs and also the particle and the background indicators can be
%         % displayed correctly
%         graphs{k}.roi.particle.x = graphs{k}.roi.particle.x + roi_in_pixel.x - 1;
%         graphs{k}.roi.bg1.x = graphs{k}.roi.bg1.x + roi_in_pixel.x - 1;
%         graphs{k}.roi.bg2.x = graphs{k}.roi.bg2.x + roi_in_pixel.x - 1;
%         
%         graphs{k}.roi.particle.y = graphs{k}.roi.particle.y + roi_in_pixel.y - 1;
%         graphs{k}.roi.bg1.y = graphs{k}.roi.bg1.y + roi_in_pixel.y - 1;
%         graphs{k}.roi.bg2.y = graphs{k}.roi.bg2.y + roi_in_pixel.y - 1;
%         
%     
%         % the x-axis of the graph
%         graphs{k}.axis.x = axis_x(1, roi_in_pixel.x : roi_in_pixel.x + roi_in_pixel.wx - 1);
%         % the unit of the x-axis (maybe we'll need it
%         graphs{k}.axis.unit.x = doc.figure_axis.unit.x;
        
        
    end
