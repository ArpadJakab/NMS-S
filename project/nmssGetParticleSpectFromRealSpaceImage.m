
function graph = nmssGetParticleSpectFromRealSpaceImage(roi_img, row_index_of_max, white_light, roi_in_pixel, roi_of_particle, analysis, axis)

    % initalize return variable
    graph = [];
    
    
    % cut out the section of the white light which matches the area of
    % investigation roi
    white_light_roi = white_light(roi_in_pixel.x:roi_in_pixel.x+roi_in_pixel.wx - 1, 1)';
    
    % check if the ROI is smaller than the minimum ROI size 
%     if (roi_of_particle.wy < analysis.minROISizeY)
%         original_wy = roi_of_particle.wy;
%         original_y = roi_of_particle.y;
%         new_y = floor(original_y - (analysis.minROISizeY - original_wy) / 2);
%         new_wy = analysis.minROISizeY;
%         
%         % checking if the new values exceed the image limits
%         if ((new_y + analysis.minROISizeY - 1) > size(roi_img,1))
%             new_y = size(roi_img,1) - analysis.minROISizeY + 1;
%         end
%         if (new_y < 1)
%             new_y = 1;
%         end
%         if (new_wy > size(roi_img,1))
%             new_wy = size(roi_img,1);
%         end
%         
%         roi_of_particle.y = new_y; 
%         roi_of_particle.wy = new_wy;
%     end
    
    

    % get image signature and threshold (image signature is some measure
    % which is used to find peaks)
    [ img_signature, threshold ] = nmssSpecAnalysisSetup( roi_img, analysis );
    
    % if some error occured while setting the analysis settings
    if (isempty(find(img_signature > 0)))
        return;
    end
    
    % set up roi strucutre to store roi information of the graphs
    roi.particle = roi_of_particle;
    roi.particle.x = 1;
    roi.particle.wx = size(roi_img,2);
    
    graph = nmssCreateGraph(roi_img, roi, white_light_roi, 1);
    % adapting particle and background rois to the full image so the
    % graphs and also the particle and the background indicators can be
    % displayed correctly in reference to the full image
    graph.roi.particle.x = graph.roi.particle.x + roi_in_pixel.x - 1;
    graph.roi.bg1.x = graph.roi.particle.x + roi_in_pixel.x - 1;
    graph.roi.bg1.wx = graph.roi.particle.wx;
    graph.roi.bg2.x = graph.roi.particle.x + roi_in_pixel.x - 1;
    graph.roi.bg2.wx = graph.roi.particle.wx;

    graph.roi.particle.y = graph.roi.particle.y + roi_in_pixel.y - 1;
    graph.roi.bg1.y = graph.roi.particle.y + roi_in_pixel.y - 1;
    graph.roi.bg1.wy = 1;
    graph.roi.bg2.y = graph.roi.particle.y + roi_in_pixel.y - 1;
    graph.roi.bg2.wy = 1;


    % the x-axis of the graph in refernece to the full image
    graph.axis.x = axis.x(1, roi_in_pixel.x : roi_in_pixel.x + roi_in_pixel.wx - 1);
    % the unit of the x-axis (maybe we'll need it)
    graph.axis.unit = axis.unit;


