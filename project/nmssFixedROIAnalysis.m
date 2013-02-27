function [ int_time_trace, x_axis_time_trace ] = nmssFixedROIAnalysis( handles, roi, img_block, list_of_jobs, curr_dir)
%nmssFixedROIAnalysis - analyses the intensity of the ROI in the selected
%frames 

% int_time_trace - a vector of intensity values with a length of the number
% of selected frames
    num_of_jobs = length(list_of_jobs);
    int_time_trace = zeros(num_of_jobs,1);
    x_axis_time_trace = zeros(num_of_jobs,1);
    waitbar_handle = waitbar(0,'Creating time trace of the selected area','CreateCancelBtn','delete(gcf);');
    status = 'OK';
    err_txt = '';
    start_time_ms = 0;
    
    for i=1:num_of_jobs

        % refresh waitbar
        if (ishandle(waitbar_handle))
            waitbar(i/num_of_jobs);
        else
            % user canceled
            status = 'ERROR';
            err_txt = 'User cancelled.';
            break;
        end
        
        
        job = list_of_jobs(i);


        % 1. Load image
        % ----------------------------------------
        % get image (or spectrum) frame

        if (isempty(img_block))
            [status camera_image job] = nmssOpenJobImage(job.filename, work_dir);

            if (~strcmp(status,'OK'))
                err_txt = camera_image;
                break;
            end

        else
            camera_image = img_block(:,:,job.number);
        end
        
        
        if (i==1)
            start_time_ms = job.exec_time;
        end

        img = camera_image';
        img_w = size(img,2); % image width
        img_h = size(img,1); % image height
        
        % 2. Cut out ROI
        if (roi.particle.exists)
            bg = [0];
            
            % background signal
            median_bg = 0;
            if (roi.bg1.exists == 1 || roi.bg2.exists == 1)
                if (roi.bg1.valid == 1)
                    bg = img(roi.bg1.y : roi.bg1.y+roi.bg1.wy - 1,...
                                roi.bg1.x : roi.bg1.x+roi.bg1.wx - 1);
                    median_bg = median(cast(median(bg), 'double'));
                    
                elseif (roi.bg2.valid == 1)
                    %bg = img(roi.bg2.y : roi.bg2.y+roi.bg2.wy - 1,...
                    %            roi.bg2.x : roi.bg2.x+roi.bg2.wx - 1);
                    
                    % we split the background roi (which contains also the
                    % particle roi) into four regions, illustrated like
                    % below (P = particle roi)
                    % 132
                    % 1P2
                    % 142
                                
                    real_bg_1 = img(roi.bg2.y : roi.bg2.y+roi.bg2.wy - 1, ...
                                    roi.bg2.x : roi.particle.x - 1);
                    real_bg_2 = img(roi.bg2.y : roi.bg2.y+roi.bg2.wy - 1, ...
                                    roi.particle.x+roi.particle.wx : roi.bg2.x+roi.bg2.wx - 1);
                    real_bg_3 = img(roi.bg2.y : roi.particle.y - 1, ...
                                    roi.particle.x : roi.particle.x+roi.particle.wx - 1);
                    real_bg_4 = img(roi.particle.y + roi.particle.wy : roi.bg2.y+roi.bg2.wy - 1, ...
                                    roi.particle.x : roi.particle.x+roi.particle.wx - 1);
                    
                    real_bg = [real_bg_1(:); real_bg_2(:); real_bg_3(:); real_bg_4(:)];
                    median_bg = cast(median(real_bg),'double');
                    
                end
            end
                            
            % particle signal area
            area = img(roi.particle.y : roi.particle.y+roi.particle.wy - 1,...
                                roi.particle.x : roi.particle.x+roi.particle.wx - 1);
                            
%             [intensities, row_indexes] = max(area);
%             [max_int, col_index] = max(intensities);
%             row_index = row_indexes(col_index);
%             area_sorted = sort(area(:));
%             % take the four brightest points
%             area_max_four = area_sorted(end-4:end);
%             
%             max_int = max(max(area));
%             print_this = {'max(area) =', num2str(max_int); ...
%                           'min(area) =', num2str(min(min(area))); ...
%                           'median(bg) =', num2str(median_bg)};
%             disp(print_this);
            
            corr_area = cast(area,'double') - median_bg;
            
            sum_int_particle = sum(sum(corr_area));
            %int_time_trace(i) = sum_int_particle - median_bg * area_surface;
            int_time_trace(i) = sum_int_particle;
            
            if (isscalar(start_time_ms))
                % old exposure time representation (is incorrect as it was
                % using the cputime - which is the time used by matlab!)
                x_axis_time_trace(i) = job.exec_time - start_time_ms; % in seconds
            else
                % the time elapsed between first job and the current job
                x_axis_time_trace(i) = etime(job.exec_time, start_time_ms); %elapsed time in seconds
            end
        end
    end

    % clear waitbar
    if (ishandle(waitbar_handle))
        delete(waitbar_handle);
    end

    if (strcmp(status,'OK'))
        figure;
        
        % sorting the int_time_trace and x_axis_time_trace according to the
        % acending order of x_axis_time_trace
        sorted_data_matrix = zeros(length(x_axis_time_trace), 2);
        sorted_data_matrix(:,1) = nmssColumnize(x_axis_time_trace);
        sorted_data_matrix(:,2) = nmssColumnize(int_time_trace);
        sorted_data_matrix = sortrows(sorted_data_matrix,1);
        x_axis_time_trace = sorted_data_matrix(:,1)';
        int_time_trace = sorted_data_matrix(:,2)';
        
        plot(x_axis_time_trace, int_time_trace, '.-');
        center_x = floor(roi.particle.x + roi.particle.wx / 2);
        center_y = floor(roi.particle.y + roi.particle.wy / 2);
        title(['ROI: X= ', num2str(roi.particle.x), ' Y= ', num2str(roi.particle.y), ...
                    ' WX = ', num2str(roi.particle.wx), ' WY = ', num2str(roi.particle.wy)]);
        xlabel('Elapsed time (s)');
        ylabel('Intensity');
        
        figure;
        hist(int_time_trace, 20);
    else
        errordlg(err_txt);
    end

