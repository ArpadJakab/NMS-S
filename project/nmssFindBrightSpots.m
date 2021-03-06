function [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
    nmssFindBrightSpots( img, analysis)
%  FindBrightSpots - finds the brigh spots in a 2d intensity image
%
% INPUT:
% img - the 2d intensity image
% analysis - the analysis struct to set up the criteria for identifying
% bright spots, for more informations see: nmssResetAnalysisParam.m
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
    max_pos_x = [];
    max_pos_y = [];
    top_left_y = [];
    bottom_right_y = [];
    top_left_x = [];
    bottom_right_x = [];


    if (strcmp(analysis.method,'0th_derivative'))
        [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            FindBrightSpots_0th_derivative( img, analysis);
    elseif (strcmp(analysis.method,'1st_derivative'))
        [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            FindBrightSpots_horizontal_1st_derivative( img, analysis);
            %FindBrightSpots_vertical_1st_derivative( img, analysis);
    else
        [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            FindBrightSpots_vertical_1st_derivative( img, analysis);
    end
    
    
            % minimum size of bright spot region of interest
            if (~analysis.bUseFixedROISize)
                % vertical size
                    min_size_y = analysis.minROISizeY;

                    ysize = bottom_right_y - top_left_y + 1;
                    y_diff = min_size_y - ysize + 1;

                    ysizesmall = find(y_diff > 0);
                    bottom_right_y(ysizesmall) = bottom_right_y(ysizesmall) + floor(y_diff(ysizesmall)/2);
                    top_left_y(ysizesmall) = top_left_y(ysizesmall) - ceil(y_diff(ysizesmall)/2);


                    % now check if the rectangle coordinates exceed over the
                    % limits of the image
                    y_size_img = size(img,1);

                    ytoosmall = find(top_left_y < 1);
                    top_left_y(ytoosmall) = 1;

                    ytoobig = find(bottom_right_y > y_size_img);
                    bottom_right_y(ytoobig) = y_size_img;
                
                % horizontal size of the bright spot
                    min_size_x = analysis.minROISizeX;

                    xsize = bottom_right_x - top_left_x + 1;
                    x_diff = min_size_x - xsize + 1;

                    xsizesmall = find(x_diff > 0);
                    bottom_right_x(xsizesmall) = bottom_right_x(xsizesmall) + floor(x_diff(xsizesmall)/2);
                    top_left_x(xsizesmall) = top_left_x(xsizesmall) - ceil(x_diff(xsizesmall)/2);


                    % now check if the rectangle coordinates exceed over the
                    % limits of the image
                    x_size_img = size(img,2);

                    xtoosmall = find(top_left_x < 1);
                    top_left_x(xtoosmall) = 1;

                    xtoobig = find(bottom_right_x > x_size_img);
                    bottom_right_x(xtoobig) = x_size_img;
                
                
            end
    
    
    
    

% --------------------------------------------------------------------------------------------------    
function [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            FindBrightSpots_0th_derivative( img, analysis)
% finds particles by using a threshold on the intensity image

    if (isvector(img) | isscalar(img))
        median_img = median(cast(img,'double'));
        std_img = std(cast(img,'double'));
    else
        median_img = median(median(cast(img,'double')));
        std_img = std(std(cast(img,'double')));
    end
    threshold = median_img + analysis.std_weighing * std_img;
    
    
    % zeros around the image (makes it simpler for search algorithms)
    working_img = zeros(size(img) + 2);
    working_img(2:end-1, 2:end-1) = img - threshold;
    working_img(find(working_img < 0)) = 0; % we set background to zero intensity
    
    x_size_img = size(working_img,2);
    y_size_img = size(working_img,1);
    
    %
    peak_index_first = 1;
    peak_index_last = 1;
    max_pos_x = [];
    max_pos_y = [];
    top_left_y = [];
    bottom_right_y = [];
    top_left_x = [];
    bottom_right_x = [];
    
    
    k =1;
    for y=2:y_size_img-1
        while (1)
            % find the first nonzero value in this row
            peak_index_first = find(working_img(y,:) > 0, 1, 'first');
            
            % if nothing found take the next line
            if (isempty(peak_index_first))
                break;
            end
            % if nonzero value found, then climb up the hill to the maximum
            % of the peak
            [hill_max_x, hill_max_y] = ClimbUpTheHill(working_img, peak_index_first, y);
            %[max_pos_x(k), max_pos_y(k)] = ClimbUpTheHill(working_img, peak_index_first, y);
            
            % find the boundaries of the peak
            [top_left_x(k), top_left_y(k), bottom_right_x(k), bottom_right_y(k)] = ...
                BoundingRect(working_img, hill_max_x, hill_max_y);
            
            % cut out the region of interest from the image
            try
                img_ROI = working_img(top_left_y(k):bottom_right_y(k),top_left_x(k):bottom_right_x(k));
            catch
                disp(lasterr());
                keyboard;
            end
        
            % find the maximum
            [max_values, max_y_ROI_vector] = max(img_ROI);
            [max_value, max_x_ROI] = max(max_values);

            % convert maximum indices into the full image coordinates
            max_pos_y(k) = top_left_y(k) + max_y_ROI_vector(max_x_ROI) - 1;
            max_pos_x(k) = top_left_x(k) + max_x_ROI - 1;
                
            
            peak_index_first = peak_index_first + bottom_right_x(k) + 1;
            
            % delete peak from the map
            working_img(top_left_y(k):bottom_right_y(k), top_left_x(k):bottom_right_x(k)) = 0;
            
            % coount of peak which have been found
            k=k+1;
        end
    end
    
    max_pos_x = max_pos_x - 1;
    max_pos_y = max_pos_y - 1;
    
    bottom_right_x = bottom_right_x - 1;
    bottom_right_y = bottom_right_y - 1;
        
% --------------------------------------------------------------------------------------------------    
function [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            FindBrightSpots_horizontal_1st_derivative( img, analysis)
        
    
                hdiffimg = cast(diff(img, 1, 2), 'double');
                %vdiffimg = cast(diff(img, 1, 1), 'double');
                % figure; imagesc(hdiffimg); title('Horiz. diff');
                % figure; imagesc(vdiffimg); title('Vert. diff');

    diffimg = hdiffimg;
    
    if (isvector(diffimg) | isscalar(diffimg))
        median_img = median(diffimg);
        std_img = std(diffimg);
    else
        median_img = median(median(diffimg));
        std_img = std(std(diffimg));
    end

    threshold = median_img + analysis.std_weighing * std_img;
    
    frame_of_zeros_size = 1; % this is the size of the frame around the image that contains zeros so that the search algorithm can work properly
                
                pmap = zeros(size(diffimg,1) + frame_of_zeros_size*2, size(diffimg,2) + frame_of_zeros_size*2);
                pmap(frame_of_zeros_size+1:end-1, frame_of_zeros_size+1:end-1) = diffimg;
                pmap(find(pmap < threshold)) = 0;
                y_size_pmap = size(pmap,1);
                %fpmap = figure; imagesc(pmap); title('Particle map');
                
%                pmap2 = pmap;
%                pmap2(find(pmap2 > threshold)) = 1;
%                figure; imagesc(pmap2); title('Normalized Particle map');
                
    % zeros around the image (makes it simpler for search algorithms)
    working_img = zeros(size(img) + frame_of_zeros_size*2);
    min_img = min(min(img));
    working_img(:,:) = min_img;
    working_img(frame_of_zeros_size+1:end-1, frame_of_zeros_size+1:end-1) = img;
    %working_img(find(working_img < 0)) = 0; % we set background to zero intensity
    
    x_size_img = size(working_img,2);
    y_size_img = size(working_img,1);
    
    
    %
    peak_index_first = 1;
    peak_index_last = x_size_img;
    diff_max_pos_x = [];
    diff_max_pos_y = [];
    diff_top_left_y = [];
    diff_bottom_right_y = [];
    diff_top_left_x = [];
    diff_bottom_right_x = [];
    
    max_pos_x = [];
    max_pos_y = [];
    top_left_y = [];
    bottom_right_y = [];
    top_left_x = [];
    bottom_right_x = [];
    
    
    k =1;
    
    for y=frame_of_zeros_size+1:y_size_pmap-frame_of_zeros_size
        % find the first nonzero value in this row
        %peak_index_first = find(working_img(y,:) > 0, 1, 'first');
        peak_index_first = find(pmap(y,:) > 0, 1, 'first');

        % if nothing found take the next line
        if (isempty(peak_index_first))
            continue;
        end
        % if nonzero value found, then climb up the hill to the maximum
        % of the peak
        [diff_max_pos_x(k), diff_max_pos_y(k)] = ClimbUpTheHill(pmap, peak_index_first, ...
                                            y);
                                        
        if (diff_max_pos_x(k) == 0)
            continue;
        end

        % find the boundaries of the peak
        [diff_top_left_x(k), diff_top_left_y(k), diff_bottom_right_x(k), diff_bottom_right_y(k)] = ...
            BoundingRect(pmap, diff_max_pos_x(k), diff_max_pos_y(k));
        

        peak_index_first = peak_index_first + diff_bottom_right_x + 1;

        % delete peak from the map
        try
            pmap(diff_top_left_y(k):diff_bottom_right_y(k), diff_top_left_x(k):diff_bottom_right_x(k)) = 0;
        catch
            disp(lasterr);
            keyboard;
        end
        
        %figure(fpmap); imagesc(pmap); title('Particle map');


        % count of peak which have been found
        k=k+1;
    end
    
    % now we loop over all particles and find the maximum and the bounding
    % rectangle
    j = 1;
    %hFig_img_ROI = figure;
    for i=1:k-1
        
        % get corner coordinates of the signal region of interest (this is the version that
        % creates a horizontally narrow rectangle around the particle)
        top_x = diff_max_pos_x(i);
        top_y = diff_top_left_y(i) + frame_of_zeros_size;
        bottom_x = top_x + (diff_bottom_right_x(i) - diff_max_pos_x(i)) * 2 - 1;
        bottom_y = diff_bottom_right_y(i) + frame_of_zeros_size;
%         % get corner coordinates of the signal region of interest (this is the version that
%         % creates a horizontally borad rectangle around the particle)
%         top_x = diff_top_left_x(i);
%         top_y = diff_top_left_y(i) + frame_of_zeros_size;
%         bottom_x = top_x + (diff_bottom_right_x(i) - diff_top_left_x(i)) * 2;
%         bottom_y = diff_bottom_right_y(i) + frame_of_zeros_size;
        if (bottom_x > x_size_img || bottom_y > y_size_img)
            continue;
        end
        
        % cut out the region of interest from the image
        try
            img_ROI = working_img(top_y:bottom_y,top_x:bottom_x);
        catch
            disp(lasterr());
            keyboard;
        end
        
        % find the maximum
        [max_values, max_y_ROI_vector] = max(img_ROI);
        [max_value, max_x_ROI] = max(max_values);
        
        % convert maximum indices into the full image coordinates
        max_y = top_y + max_y_ROI_vector(max_x_ROI) - 1;
        max_x = top_x + max_x_ROI - 1;
        
% DEBUG:
        %         figure(hFig_img_ROI); 
%         imagesc(img_ROI);
%         colormap gray;
%         nmssDrawRectBetween2Points([max_x_ROI,max_y_ROI_vector(max_x_ROI)], [max_x_ROI,max_y_ROI_vector(max_x_ROI)], 2, 'r');
%         menu('Continue', 'Yes');
        
        
        
%         [max_x, max_y] = ClimbUpTheHill(working_img, diff_max_pos_x(i), ...
%                                             diff_max_pos_y(i));
        
        % validity check of the coordinates
        if(max_x < 1)
            continue;
        end
        if(max_x > x_size_img)
            continue;
        end
        if(max_y < 1)
            continue;
        end
        if(max_y > y_size_img)
            continue;
        end
                                        
        
        max_pos_x(j) = max_x;
        max_pos_y(j) = max_y;
        top_left_x(j) = top_x;
        top_left_y(j) = top_y;
        bottom_right_x(j) = bottom_x;
        bottom_right_y(j) = bottom_y;
        
        
        
        
        j=j+1;
        
    end
    
    
    % adjust coordinates to the 0th derivate image (max and other stuff is
    % determined on the 1st derivative, but the bounding recangle exists on
    % the 0th derivative image)
      max_pos_x = max_pos_x - 1;
%      top_left_x = top_left_x - 1;
%      bottom_right_x = bottom_right_x - 1;
    

% --------------------------------------------------------------------------------------------------    
function [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            FindBrightSpots_vertical_1st_derivative( img, analysis)
        
    
                %hdiffimg = cast(diff(img, 1, 2), 'double');
                vdiffimg = cast(diff(img, 1, 1), 'double');
                % figure; imagesc(hdiffimg); title('Horiz. diff');
                % figure; imagesc(vdiffimg); title('Vert. diff');

    if (isvector(vdiffimg) | isscalar(vdiffimg))
        median_img = median(vdiffimg);
        std_img = std(vdiffimg);
    else
        median_img = median(median(vdiffimg));
        std_img = std(std(vdiffimg));
    end

    threshold = median_img + analysis.std_weighing * std_img;
                
                pmap = zeros(size(vdiffimg,1) + 3, size(vdiffimg,2) + 2);
                pmap(3:end-1, 2:end-1) = vdiffimg;
                pmap(find(pmap < threshold)) = 0;
                y_size_pmap = size(pmap,1);
                %fpmap = figure; imagesc(pmap); title('Particle map');
                
%                pmap2 = pmap;
%                pmap2(find(pmap2 > threshold)) = 1;
%                figure; imagesc(pmap2); title('Normalized Particle map');
                
    % zeros around the image (makes it simpler for search algorithms)
    working_img = zeros(size(img) + 2);
    min_img = min(min(img));
    working_img(:,:) = min_img;
    working_img(2:end-1, 2:end-1) = img;
    %working_img(find(working_img < 0)) = 0; % we set background to zero intensity
    
    x_size_img = size(working_img,2);
    y_size_img = size(working_img,1);
    
    
    %
    peak_index_first = 1;
    peak_index_last = x_size_img;
    vdiff_max_pos_x = [];
    vdiff_max_pos_y = [];
    vdiff_top_left_y = [];
    vdiff_bottom_right_y = [];
    vdiff_top_left_x = [];
    vdiff_bottom_right_x = [];
    
    max_pos_x = [];
    max_pos_y = [];
    top_left_y = [];
    bottom_right_y = [];
    top_left_x = [];
    bottom_right_x = [];
    
    
    k =1;
    
    for y=2:y_size_pmap-1
        % find the first nonzero value in this row
        %peak_index_first = find(working_img(y,:) > 0, 1, 'first');
        peak_index_first = find(pmap(y,:) > 0, 1, 'first');

        % if nothing found take the next line
        if (isempty(peak_index_first))
            continue;
        end
        % if nonzero value found, then climb up the hill to the maximum
        % of the peak
        [vdiff_max_pos_x(k), vdiff_max_pos_y(k)] = ClimbUpTheHill(pmap, peak_index_first, ...
                                            y);
                                        
        if (vdiff_max_pos_x(k) == 0)
            continue;
        end

        % find the boundaries of the peak
        [vdiff_top_left_x(k), vdiff_top_left_y(k), vdiff_bottom_right_x(k), vdiff_bottom_right_y(k)] = ...
            BoundingRect(pmap, vdiff_max_pos_x(k), vdiff_max_pos_y(k));
        

        peak_index_first = peak_index_first + vdiff_bottom_right_x + 1;

        % delete peak from the map
        try
            pmap(vdiff_top_left_y(k):vdiff_bottom_right_y(k), vdiff_top_left_x(k):vdiff_bottom_right_x(k)) = 0;
        catch
            disp(lasterr);
            keyboard;
        end
        
        %figure(fpmap); imagesc(pmap); title('Particle map');


        % coount of peak which have been found
        k=k+1;
    end
    
    % now we loop over all particles and find the maximum and the bounding
    % rectangle
    j = 1;
    for i=1:k-1
        [max_x, max_y] = ClimbUpTheHill(working_img, vdiff_max_pos_x(i), ...
                                            vdiff_max_pos_y(i));
        
        if(max_x < 1)
            continue;
        end
        if(max_x > x_size_img)
            continue;
        end
        if(max_y < 1)
            continue;
        end
        if(max_y > y_size_img)
            continue;
        end
                                        
        top_x = vdiff_top_left_x(i);
        top_y = vdiff_top_left_y(i);
        
%         background = (working_img(top_left_y(j), top_left_x(j)) + working_img(top_left_y(j) - 1, top_left_x(j))) / 2;
%         
%         [dummy_x, dummy_y, bottom_right_x(j), bottom_right_y(j)] = ...
%             BoundingRect(working_img, max_pos_x(j), max_pos_y(j), background);
        
        bottom_x = vdiff_bottom_right_x(i);
        % the vertical peak region is two times the vertical region of
        % the derivative of the peak, where the derivative is positive
        % (ascending side of the peak, looking from the lower index side)
        bottom_y = top_y + (vdiff_bottom_right_y(i) - vdiff_top_left_y(i)) * 2;
        if (bottom_y > y_size_img)
            continue;
        end
        
%         % minimum size of bright spot region of interest
%         if (~analysis.bUseFixedROISize)
% %            min_size_x = analysis.minROISizeX;
%             min_size_y = analysis.minROISizeY;
%             
% %             if (vdiff_bottom_right_x(k) - vdiff_top_left_x(k) < min_size_x)
% %             end
% %             
%             ysize = bottom_y - top_y;
%             
%             if (ysize < min_size_y)
%                 y_diff = min_size_y - ysize;
%                 bottom_y = bottom_y + floor(y_diff/2);
%                 top_y = top_y - ceil(y_diff/2);
%             end
%             
%         end
%         
%         
%         if(top_y < 2)
%             top_y = 2; % see the
%         end
%         if(bottom_y > y_size_img)
%             bottom_y = y_size_img;
%         end
        
        
        max_pos_x(j) = max_x;
        max_pos_y(j) = max_y;
        top_left_x(j) = top_x;
        top_left_y(j) = top_y;
        bottom_right_x(j) = bottom_x;
        bottom_right_y(j) = bottom_y;
        
        
        
        
        j=j+1;
        
    end
    
    
    % adjust coordinates to the 0th derivate image (max and other stuff is
    % determined on the 1st derivative, but the bounding recangle exists on
    % the 0th derivative image)
     max_pos_x = max_pos_x - 1;
     max_pos_y = max_pos_y - 1;
     top_left_x = top_left_x - 1;
     top_left_y = top_left_y - 1;
     bottom_right_x = bottom_right_x - 1;
     bottom_right_y = bottom_right_y - 1;
    
    
    
function [max_pos_x, max_pos_y] = ClimbUpTheHill(img, start_pos_x, start_pos_y)
    
    [max_pos_x, max_pos_y] = nmssFindMaxPosIn_2D_Image(img, start_pos_x, start_pos_y, 'max');

function [min_pos_x, min_pos_y] = ClimbToTheAbyss(img, start_pos_x, start_pos_y)
    
    [min_pos_x, min_pos_y] = nmssFindMaxPosIn_2D_Image(img, start_pos_x, start_pos_y, 'min');

    
%    
function [top_left_x, top_left_y, bottom_right_x, bottom_right_y] = BoundingRect(img, start_pos_x, start_pos_y, varargin)

    % k(1) distance above center and top side of boundary rectangle
    % k(2) distance right to the center and right side of boundary rectangle
    % k(3) distance below center and bottom side of boundary rectangle
    % k(4) distance left to the center and left side of boundary rectangle
    th = 0;
    if (length(varargin) == 1)
        th = varargin{1};
    end
    
    
    
    
    
    k = ones(1,4);
    while (1)
        % top row
        search_area{1} = img(start_pos_y - k(1), start_pos_x - k(4):start_pos_x + k(2));
        % right column
        search_area{2} = img(start_pos_y - k(1) + 1 : start_pos_y + k(3) - 1, start_pos_x + k(2));
        % bottom row
        search_area{3} = img(start_pos_y + k(3), start_pos_x - k(4) : start_pos_x + k(2));
        % left column
        search_area{4} = img(start_pos_y - k(1) + 1:start_pos_y + k(3) - 1, start_pos_x - k(4));
        
        all_empty = 1;
        % find regions which have exclusively values below th (that's where we assume
        % that the peak ends
        for i=1:4
            if (~isempty(find(search_area{i})))
                k(i) = k(i) + 1;
                all_empty = 0;
            end
        end
        if (all_empty == 1)
            break;
        end
        
    end
    
    top_left_x = start_pos_x - k(4);
    top_left_y = start_pos_y - k(1);
    bottom_right_x = start_pos_x + k(2);
    bottom_right_y = start_pos_y + k(3);
    
    
    



        
    