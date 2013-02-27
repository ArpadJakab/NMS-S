function [status list_of_executed_jobs] = nmssExecuteJobs(exp_time, num_of_exposures, selected_jobs)
% executes jobs listed in the "List of Jobs" listbox
%  Detailed explanation goes here
    global app;
    global doc;
    status = 'ERROR'; % this will be returned
    
    list_of_executed_jobs = selected_jobs;
    
    
    num_of_jobs = length(selected_jobs);
    
    
    % check if one of the target files exists
    for k = 1:num_of_jobs
        %job_num = selected_jobs(1,k);
        job = selected_jobs(k);
        
        dir = doc.workDir;
        filename = job.filename;
        filepath = fullfile(dir, filename);
        
        if (exist(filepath, 'file'))
            txt = {['File: ' filepath ' exits!'], '', 'Please choose a different working directory!' };
            errordlg(txt);
            return;
        end
    end
    
    dir = doc.workDir;
% % -- TAKE IMAGE IN THE DELAY TIME
% % don't forget to uncomment the additional part below
%     tempdir_for_long_exp = [dir, '\long exposure\'];
%     if (exist(tempdir_for_long_exp, 'dir') ~= 7)
%         [status,message,messageid] = mkdir(tempdir_for_long_exp);
%         if(~isempty(messageid))
%             txt = {['Error creating directory: ', tempdir_for_long_exp]; ''; message };
%             errordlg(txt);
%             return;
%         end
%     end

    % display progress bar with cancel (it destroys itself if cancel was
    % pressed or the progress indicator reached 100%
    global cancel_exposure; 
    cancel_exposure = 0;
    
%     h_waitbar = waitbar(0,'Executing Jobs','CreateCancelBtn', ...
%         ['btn = questdlg(''Do you really want to stop image acquisition?'',''Stop Image Acquisition'',''Yes'',''No'',''No'');', ...
%          'if (strcmp(btn, ''Yes'')) global cancel_exposure; cancel_exposure = 1; delete(gcf); drawnow; end;']);
    h_waitbar = waitbar(0,'Executing Jobs','CreateCancelBtn', @CancelExposure);
     

    %    exp_time = str2num(get(handles.edExpTime,'String'));
        
    for k = 1:num_of_jobs

        % job executeion starting time
        job_exec_start_time = clock;

        job = selected_jobs(k);
        filename = job.filename;

        % get current x-position
        [status val] = nmssPSGetPosX(app.hStage);
        if (strcmp(status, 'ERROR')) 
            errordlg(val);
            return;
        end
        xPos_Current = val;

        % get current y-position
        [status val] = nmssPSGetPosY(app.hStage);
        if (strcmp(status, 'ERROR')) 
            errordlg(val);
            return;
        end
        yPos_Current = val;


        % move translation stageonly if the new position is more than
        % 5nm away from the current position
        if (abs(xPos_Current - job.pos.x) > 0.005)
            % move stage along the X-Axis
            [hw_status val] = nmssPSSetPosX(app.hStage, job.pos.x);
            if (strcmp(hw_status, 'ERROR')) 
                errordlg(val);
                return;
            end
            % wait for 0.1 second to let the stage to finish the movement
            pause(0.1);
        end
        if (abs(yPos_Current - job.pos.y) > 0.005)
            % move stage along the Y-Axis
            [hw_status val] = nmssPSSetPosY(app.hStage, job.pos.y);
            if (strcmp(hw_status, 'ERROR')) 
                errordlg(val);
                return;
            end
            % wait for 0.1 second to let the stage to finish the movement
            pause(0.1);
        end

        % if waitbar exists acquire image
        if (ishandle(h_waitbar) && cancel_exposure == 0)

            % and NOW, get the image!
            [hw_status camera_image] = nmssTakeImage(app.hCamera, exp_time, num_of_exposures, -1);
            
            drawnow;

            if (strcmp(hw_status, 'ERROR'))
                return;
            end

            % check if correct image has been received
            if (size(camera_image,1) == 0)
                errordlg('No image received from the camera!');
                return;
            end

            % display image in the figure specified by the handle
            doc.img = camera_image';

            nmssDispImage();

            % get a file name indicating the stage position
            filepath = fullfile(dir, filename);

            % job succesfully executed
            job.status = 1;

            job.grating = doc.specinfo.CurrentGratingIndex;
            job.central_wavelength = doc.specinfo.CurrentWavelength;
            job.exp_time = exp_time;
            job.exp_time_unit = 'ms'; % milliseconds
            job.exec_time = clock; %current computer time in seconds!!!!

            nmssSaveJob(filepath, job, camera_image);

% % -- TAKE IMAGE IN THE DELAY TIME
% % don't forget to uncomment the corresponding initialization part above
%             if (isfield(job, 'delay_after_taking_image'))
%                     long_exp_time = 150;
%                     % and NOW, get the image!
%                     [hw_status long_exp_image] = nmssTakeImage(app.hCamera, long_exp_time, num_of_exposures, -1);
%                     if (strcmp(hw_status, 'ERROR'))
%                         return;
%                     end
% 
%                     % check if correct image has been received
%                     if (size(long_exp_image,1) == 0)
%                         errordlg('No image received from the camera!');
%                         return;
%                     end
% 
%                     % get a file name indicating the stage position
%                     long_exp_filepath = fullfile(tempdir_for_long_exp, filename);
% 
%                     % job succesfully executed
%                     long_exp_job = job;
%                     long_exp_job.status = 1;
% 
%                     long_exp_job.grating = doc.specinfo.CurrentGratingIndex;
%                     long_exp_job.central_wavelength = doc.specinfo.CurrentWavelength;
%                     long_exp_job.exp_time = long_exp_time;
%                     long_exp_job.exp_time_unit = 'ms'; % milliseconds
%                     long_exp_job.exec_time = clock; %current computer time in seconds!!!!
% 
%                     nmssSaveJob(long_exp_filepath, long_exp_job, long_exp_image);
%             end




            % delay after the exposure (used for time scans)
            if ( cancel_exposure == 0)
                if (isfield(job, 'delay_after_taking_image'))
                    if (strcmp(job.exp_time_unit,'ms'))
                        delay_sec = job.delay_after_taking_image / 1000;
                    else
                        delay_sec = job.delay_after_taking_image;
                    end

                    while(etime(clock(), job.exec_time) < delay_sec && cancel_exposure == 0)
                        % wait until delay time has been reached
                        drawnow;
                    end
                end
            end

            % update list of jobs (mark job as done and other stuff)
            list_of_executed_jobs(k) = job;
        end

        % job execution finish time
        job_exec_end_time = clock;
        elapsed_time = etime(job_exec_end_time, job_exec_start_time);

        % waitbar handling:
        % -----------------------------------------------------------
        % update waitbar progress indicator
        rem_time = elapsed_time * (num_of_jobs - k);   %remaining time in seconds
        separator = {':0', ':'};
        seconds = num2str(mod(rem_time, 60.0), '%2.0f');

        % if waitbar exists acquire image
        if (ishandle(h_waitbar) && cancel_exposure == 0)
            waitbar(k/num_of_jobs, h_waitbar, ['Executing Jobs: Estimated time to finish: ',...
                num2str(floor(rem_time / 60.0),'%4.0f'),...
                separator{length(seconds)}, ...
                seconds,' min']);
        else
            % after user pressed cancel the waitbar is deleted and we
            % break down the execution of the loop
            return;
        end

        % wait a little bit to leave to recover the hardware
        %pause(0.5);

    end
    
    % closes waitbar
    if (ishandle(h_waitbar))
        delete(h_waitbar);
    end

    status = 'OK'; % this will be returned
    


% creates a file name for the given scanning position
function file_name = nmssGetFilenameScanning(scan_pos)
    file_name = ['Scan_' num2str(scan_pos, '%3.1f') '.mat'];


function CancelExposure(varargin)
    global cancel_exposure;
    
    btn = questdlg('Do you really want to stop image acquisition?','Stop Image Acquisition','Yes','No','No');
    if (strcmp(btn, 'Yes'))
        cancel_exposure = 1; 
        delete(gcf); 
        drawnow; 
    end;
    


