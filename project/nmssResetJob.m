function job = nmssResetJob()
% constructor for the job struct

    job.number = 0;
    job.status = 0;
    job.pos.x = 100;
    job.pos.y = 100; % center of the nanostage
    job.filename = '';
    job.grating = 1;
    job.central_wavelength = 0;
    job.exp_time = 0; % ms
    job.exp_time_unit = 'ms'; % milliseconds
    job.exec_time = 0;   %time of the begin of the frame-acquisiton
    job.scan_data.delay_after_taking_image = 0; % the time that must be spent after an exposure 
                                            % same units as for the exec time
    job.previously_saved_job = ''; % the path of the previously saved job
    job.delay_after_taking_image = 0; % the time taken after the exposure
