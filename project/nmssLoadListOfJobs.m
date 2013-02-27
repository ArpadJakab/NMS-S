function [list_of_jobs msr_info real_sp_img] = nmssLoadListOfJobs(input_dir)
% handles    structure with handles and user data (see GUIDATA)
% loads list of jobs from the currently selected working directory

    file_path = fullfile(input_dir, 'list_of_jobs.mat');
    list_of_jobs = nmssResetJob();
    msr_info = nmssResetMeasurementInfo();
    real_sp_img = nmssResetRealSpaceImage();

    if (exist(file_path, 'file'))
%        try
            load(file_path); % loads variable 'list_of_jobs', 'measurement_info' and more
            
            % convert old style list_of_jobs
            size_list_of_jobs = size(list_of_jobs);
            if (size_list_of_jobs(1,1) >= 1)
                
                if (iscell(list_of_jobs))
                    if (size(list_of_jobs{1},2) > 1)

                        new_list_of_jobs = cell(size_list_of_jobs(1,1));
                        for k =1:size_list_of_jobs(1,1) 
                            old_job = list_of_jobs{k};
                            new_job = nmssResetJob();

                            new_job.status = old_job{1};
                            new_job.pos.x = old_job{2};
                            new_job.pos.y = old_job{3};
                            new_job.filename = old_job{4};

                            new_list_of_jobs{k} = new_job;
                        end
                        list_of_jobs = new_list_of_jobs;
                    end
                end
            end
            
            % convert list_of_jobs from cell to struct array if necessary
            % (older versions of list_of_jobs  may be in cell array form)
            if (iscell(list_of_jobs))
                imax = length(list_of_jobs);
                
                for i=1:imax
                    new_list_of_jobs(i) = list_of_jobs{i};
                end
                list_of_jobs = new_list_of_jobs;
            end
            
            
            % load measurement info
            if (exist('measurement_info', 'var'))
                msr_info = measurement_info;
            elseif (exist('project_description', 'var')) 
                % load project description (if found in the file)
                % this is the old school measurement description
                msr_info.remarks =  cellstr(project_description);
                
                
                
                %txt = {'Loaded project description:'; ''; msr_info.remarks{:}; ''; ...
                txt = [{'Loaded project description:'; ''}; msr_info.remarks; {''; ...
                      'Did you use IR filter in the illumination during the measurement you were currently loading?'}];
                btn = questdlg(txt,'IR Filter','Yes','No','No');

                if (strcmp('No',btn))
                    msr_info.ir_filter_used = 0;
                else
                    msr_info.ir_filter_used = 1;
                end
                    
            end
            
            %
            
            % DON'T load real space image (if found in the file)
            % disabled as it made not too much sense to load the image file
            % because its creation depends on the spectral ROI
            %if (exist('real_space_img', 'var'))
            %    real_sp_img = real_space_img;
            %end
            
%         catch
%             error_msg = ['Error loading file! ' lasterr()];
%             disp(error_msg);
%             errordlg(error_msg);
%             return;
%         end
    else
        % get a list of files
        dir_info = dir(input_dir);
        
        try
            % load the first .mat file
            job_index = 1;
            for i=1:length(dir_info)
                current_dir_item = dir_info(i);
                
                if (current_dir_item.isdir)
                    continue;
                end
                
                [file.pathstr,file.name,file.ext] = fileparts(current_dir_item.name);
                
                if (~strcmp(lower(file.ext),'.mat'))
                    continue;
                end

                load(fullfile(input_dir, current_dir_item.name), 'job');
                % now we have loaded a job and a camera image the camera
                % image is not required, but we need the job info
                if (exist('job', 'var'))
                    list_of_jobs(job_index) = job;
                    job_index = job_index + 1;
                end
            end
        catch
            % clean up before throwing an error
            error(lasterr);
        end
        % set up the list of jobs data structure if possible
        % OR report an error
        
        
    end
