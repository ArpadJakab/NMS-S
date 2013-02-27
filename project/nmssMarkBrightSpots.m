function [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y] = ...
    nmssMarkBrightSpots( img, analysis, real_image_figure_handle, x_offset, y_offset)
%  FindBrightSpots - finds the brigh spots in a 2d intensity image
%
% INPUT:
% img - the 2d intensity image
%
% OUTPUT:
% max_pos_x - the x-position of the maximum
% max_pos_y - the x-position of the maximum
% top_left_x - the x-position of the top left corner of the spot's bounding
% rectangle
% top_left_y - the y-position of the top left corner of the spot's bounding
% rectangle
% bottom_right_x - the x-position of the bottom right corner of the spot's bounding
% rectangle
% bottom_right_y - the x-position of the bottom right corner of the spot's bounding
% rectangle

    
    %
    peak_index_first = 1;
    peak_index_last = 1;
    max_pos_x = [];
    max_pos_y = [];
    top_left_y = [];
    bottom_right_y = [];
    top_left_x = [];
    bottom_right_x = [];
    
    max_pos_x_tmp = [];
    max_pos_y_tmp = [];
    top_left_y_tmp = [];
    bottom_right_y_tmp = [];
    top_left_x_tmp = [];
    bottom_right_x_tmp = [];
    
    marked_particle_index = 0;
    
    % activate figure
    figure(real_image_figure_handle);
    
    % loop over 1000 steps (to avoid infinite loops)
    max_num_of_user_interactions = 1000;
    for n=1:max_num_of_user_interactions
        % wait until user has pressed a (mouse) button 
        menutext{1} = 'Select a tight region where you see a particle';
        
        switch menu(menutext ,'Select', 'Undo Last Selection', 'Quit')
            case 1
                k = waitforbuttonpress;
                point1 = get(gca,'CurrentPoint');    % button down detected
                finalRect = rbbox;                   % return figure units
                point2 = get(gca,'CurrentPoint');    % button up detected

                point1 = point1(1,1:2);              % extract x and y
                point2 = point2(1,1:2);

                %nmssDrawRectBetween2Points(point1, point2, 1);

                start_x = point1(1,1);
                start_y = point1(1,2);
                end_x = point2(1,1);
                end_y = point2(1,2);

                % get the top left corner of the rectangle
                if (end_x < start_x)
                    temp = end_x;
                    end_x = start_x;
                    start_x = temp;
                end
                if (end_y < start_y)
                    temp = end_y;
                    end_y = start_y;
                    start_y = temp;
                end

                x_limits = xlim;
                y_limits = ylim;
                min_x = x_limits(1);
                max_x = x_limits(2);
                min_y = y_limits(1);
                max_y = y_limits(2);
                
                if (start_x < min_x) start_x = min_x; end
                if (start_y < min_y) start_y = min_y; end
                if (end_x > max_x) end_x = max_x; end
                if (end_y > max_y) end_y = max_y; end
                
                % snap rectangle's coordinates to the outer boundary of the pixels
                % contained within or which are on the rubber box line
                corner_x = floor(start_x + 0.5);
                end_x = ceil(end_x - 0.5);
                corner_y = floor(start_y + 0.5);
                end_y = ceil(end_y - 0.5);
                
                
                marked_particle_index = marked_particle_index + 1;
                
                hRectangleLine{marked_particle_index} = ...
                    nmssDrawRectBetween2Points([corner_x,corner_y], [end_x,end_y], 1, 'r');
                
                % switch from the job_no x pixel picture into the pixel x pixel picture 
                xIndexStart = corner_x - x_offset;
                xIndexEnd = end_x - x_offset;
                yIndexStart = corner_y - y_offset;
                yIndexEnd = end_y - y_offset;
                
                
                top_left_y_tmp(marked_particle_index) = yIndexStart;
                bottom_right_y_tmp(marked_particle_index) = yIndexEnd;
                top_left_x_tmp(marked_particle_index) = xIndexStart;
                bottom_right_x_tmp(marked_particle_index) = xIndexEnd;
                
                image_in_rect = img(yIndexStart:yIndexEnd, xIndexStart:xIndexEnd);
                
                [max_x, max_y] = nmssFindMaxPosIn_2D_Image(img, floor((xIndexStart + xIndexEnd)/2), ...
                                                                floor((yIndexStart + yIndexEnd)/2), 'max');
                
                
                max_pos_x_tmp(marked_particle_index) = max_x;
                max_pos_y_tmp(marked_particle_index) = max_y;
        
               
            % undo last selection (this can be repeated subsquently)
            case 2
                
                % delete connection line the last correlated particle group
                delete(hRectangleLine{marked_particle_index});
                marked_particle_index = marked_particle_index - 1;
                if (marked_particle_index < 0)
                    marked_particle_index = 0;
                end
                
            otherwise
                n = max_num_of_user_interactions; % loop exit condition
                break;
                
        end
    end
    
    max_pos_x = max_pos_x_tmp(1:marked_particle_index);
    max_pos_y = max_pos_y_tmp(1:marked_particle_index);
    
    top_left_y = top_left_y_tmp(1:marked_particle_index);
    bottom_right_y = bottom_right_y_tmp(1:marked_particle_index);
    
    top_left_x = top_left_x_tmp(1:marked_particle_index);
    bottom_right_x = bottom_right_x_tmp(1:marked_particle_index);

    
    