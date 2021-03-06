function img_block = nmssDataCubeCreator( list_of_jobs, work_dir )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    img_block = [];

    % get all frames and put them into a data block
    job = list_of_jobs(1);
    [status img] = nmssOpenJobImage(job.filename, work_dir);
    img_block_z_size = length(list_of_jobs);
    try
        img_block = zeros(size(img,1), size(img,2), img_block_z_size , 'uint16');
    catch
        disp(lasterr);
        return;
    end
    waitbar_handle = waitbar(0,'Creating Spectral data cube','CreateCancelBtn','delete(gcf);');
    for k=1:img_block_z_size
        % refresh waitbar
        if (ishandle(waitbar_handle))
            waitbar(k/img_block_z_size);
        else
            % user canceled
            return;
        end
        job = list_of_jobs(k);
        [status img] = nmssOpenJobImage(job.filename, work_dir);
        % job couldn't be opened for whatever reason let's stop and
        % debug
        if(strcmp(status, 'ERROR'))
            disp(lasterr);
            keyboard;
        end
        img_block(:,:,k) = img;
    end
    
    
    delete(waitbar_handle);
