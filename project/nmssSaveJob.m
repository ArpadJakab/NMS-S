function [status error_msg] = nmssSaveJob( filepath, job, camera_image )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    status = 'ERROR';
    error_msg = '';
    global doc;
    
    job.previously_saved_job = doc.previously_saved_job;
    
    axis_x = nmssGetXAxis();
    
    try
        %disp(['Saving: ',filepath]);
        save(filepath, 'camera_image', 'job', 'axis_x', '-mat');
        doc.previously_saved_job = job.previously_saved_job;
    catch
        error_msg = ['Error saving image: ' lasterr()];
        disp(error_msg);
        errordlg(error_msg);
        return;
    end
    
    status = 'OK';
