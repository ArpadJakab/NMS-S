function [roi_bg1, roi_bg2] = nmssGetAutoBackground(roi_particle, image_signature, bg_threshold, bg_vert_dist )
%nmssGetAutoBackground - Summary of this function goes here
% roi_particle - the roi structure of the particle
% image_signature - the image signature which is used to identify particles
% bg_threshold - the threshold below which the image values are treated as
% background
% bg_vert_dist - the distance between the particle ROI and the background
% ROIs


 %nmssGetAutoBackground - Summary of this function goes here
% roi_particle - the roi structure of the particle
% image_signature - the image signature which is used to identify particles
% bg_threshold - the threshold below which the image values are treated as
% background
% bg_vert_dist - the distance between the particle ROI and the background
% ROIs



        roi_bg1 = nmssResetROI();
        roi_bg2 = nmssResetROI();
        

        % background above the spectrum:
        % 1st we have to analyze if we can take both the upper and the
        % lower side background ROIs. Ideally we'd need both and average
        % over them.
        roi_bg1.x = roi_particle.x;
        % we tak half particle roi widht above (and then below) the
        % particle
        roi_bg1.wy = ceil(roi_particle.wy / 2.0);
        roi_bg1.y = roi_particle.y - roi_bg1.wy - bg_vert_dist;
        roi_bg1.wx = roi_particle.wx;
        roi_bg1.valid = 1;
        if (roi_bg1.y < 1)
            roi_bg1.valid = 0;
        else
            % check if Background itself does not contain any other peaks
            bg1_values_above_th = find(image_signature(roi_bg1.y : roi_bg1.y+roi_bg1.wy - 1) > bg_threshold);
            if (length(bg1_values_above_th) > 0)
                roi_bg1.valid = 0;
            end
        end
        
        
        % background below the spectrum:
        % background:
        % 1st we have to analyze if we can take both the upper and the
        % lower side background ROIs. Ideally we'd need both and average
        % over them.
        roi_bg2.x = roi_particle.x;
        roi_bg2.wy = floor(roi_particle.wy / 2.0);
        roi_bg2.y = roi_particle.y + roi_particle.wy + bg_vert_dist;
        roi_bg2.wx = roi_particle.wx;
        roi_bg2.valid = 1;
        if (roi_bg2.y +  roi_bg2.wy > length(image_signature))
            roi_bg2.valid = 0;
        else
            % check if Background itself does not contain any other peaks
            bg2_values_above_th = find(image_signature(roi_bg2.y : roi_bg2.y+roi_bg2.wy - 1) > bg_threshold);
            if (length(bg2_values_above_th) > 0)
                roi_bg2.valid = 0;
            end
            
        end
