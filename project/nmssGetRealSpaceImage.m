function [real_space_img x_min x_max] = nmssGetRealSpaceImage(list_of_jobs, workDir)
% nmssGetRealSpaceImage
%
% returns the real space image of the scanned area by summing up each frame
% (job) along the horizontal axis (wavelength axis). This creates an intensity vector
% which represents the intensity distribution along the narrow slit of the spectrometer
% at a particular position. Then a matrix is created with the 
% size: <number of scans> x <vertical size of spectroscopic image>
% and each column is being filled with the intensity vector corresponding to the
% frame. Thus reproducing the original,
% real space image of the scanned area with the slit-width as the
% x-resolution and pixel height as the y-resolution
%
% INPUT:
% list_of_jobs - all available jobs
% workDir - the directory where the jobs (frames) are stored
%
% OUTPUT:
% real_space_img - the real-space image of the scanned area
% x_min - the x-axis lower boundary of the image
% x_max - the x-axis upper boundary of the image
%
% You can visualize the image with this:
% colormap gray; imagesc(img)
    global doc;
    
    % init return variable
    x_min = NaN;
    x_max = NaN;
    
    status = 'OK';
    
    num_of_jobs = length(list_of_jobs);
    
    % each cell of this array contains the sum of the spectrographic image
    % along the horizontal axis (the wavelength axis)
    imgs = {};

    global waitbarCanceled;
    waitbarCanceled = 0;
    waitbar_handle = waitbar(0,['Creating real space image of the scanned area']);
    
    x_min = list_of_jobs(1).pos.x;
    x_max = list_of_jobs(end).pos.x;
    
    ct = clock;
    disp(['Reading CCD image files from the directory: ', workDir]);
    for k = 1:num_of_jobs
        waitbar(k/(num_of_jobs * 2));
        
        job = list_of_jobs(k);
        if (job.pos.x > x_max)
            x_max = job.pos.x;
        end
        if (job.pos.x < x_min)
            x_min = job.pos.x;
        end
        
        if (job.status == 1)
            
            % [status camera_image] = nmssOpenJobImage(job.filename, workDir);
            % camera_image = doc.img_block(:,:,job.number);
            if (isempty(doc.img_block))
                [status camera_image job] = nmssOpenJobImage(job.filename, workDir);

                if (~strcmp(status,'OK'))
                    err_txt = doc.camera_image;
                    break;
                end

            else
                if (isfield(job, 'number'))
                    camera_image = doc.img_block(:,:,job.number);
                else
                    camera_image = doc.img_block(:,:,k);
                end
            end
        else
            % job not executed, let's take the next job (the image will
            % look strange..)
            errordlg('Can not create real space image. job #', num2str(k), ' has not been executed!');
            return
        end
        if (strcmp(status, 'ERROR'))
            % job couldn't be opened for whatever reason let's take the next
            % one
            error(camera_image);
            break;
        else
            % create real space image using the spectrtal region of
            % interest which is set by the user in the analysis dialog
%             imgs{k} = sum(camera_image(roi_in_px.x:roi_in_px.x+roi_in_px.wx - 1, ...
%                                        roi_in_px.y:roi_in_px.y+roi_in_px.wy - 1));
            imgs{k} = sum(camera_image);
        end
    end
    
    % calculate elapsed time
    et = etime(clock,ct);
    disp(['Elapsed time reading CCD image files:', num2str(et)]);
    
    real_space_img = zeros(length(imgs{1}), num_of_jobs);
    % fit together each frame
%     for k=1:num_of_jobs
%         waitbar((k / (num_of_jobs * 2) + 0.5));
%         if (isempty(imgs{k}))
%             continue;
%         end
%         real_space_img(:,k) = imgs{k};
%     end
%     keyboard;
% 
    for k=2:num_of_jobs-1
        waitbar((k / (num_of_jobs * 2) + 0.5));
        if (isempty(imgs{k}))
            continue;
        end
        real_space_img(:,k) = (2 * imgs{k} + imgs{k-1} + imgs{k+1}) / 4;
    end
    real_space_img(:,1) = imgs{1};
    real_space_img(:,num_of_jobs) = imgs{num_of_jobs};
    
    delete(waitbar_handle);
