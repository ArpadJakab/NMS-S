function [status img loaded_job] = nmssOpenJobImage(filename, curr_dir)
% loads the image and job parameters (if they exist) of a perfomed job    

    file_path = fullfile(curr_dir, filename);
    img = 0;
    loaded_job = '';
    
    status = 'OK';
    if (exist(file_path, 'file'))
        load(file_path); % loads variable 'camera_image'
        img = camera_image;
        
        if (exist('job'))
            loaded_job = job;
        end
        
    else
        status = 'ERROR';
        img = ['Could not open file: ', file_path];
    end
    

end