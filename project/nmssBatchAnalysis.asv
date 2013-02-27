function [results, particles_analized] = nmssBatchAnalysis(real_space_img, list_of_jobs, ...
                                     work_dir, analysis, ...
                                     white_light, measurement_info, roi_in_px, manual_particle_finding)

% INPUT:
% real_space_img - the real space image structure which contains the real
%                  space image and its x-axis information
% list_of_jobs - the list of jobs structure which is saved with the
%                spectral images during scanning
% work_dir - the directory where the spectral images are located
% analysis - the analysis structure containing the particle recognition
% parameters (see more in nmssResetAnalysisParam)
% white_light - the array containing the white light data corresponding
% to the central wavelength of the spectral images
% measurement_info - a struct containing the measurement info
% roi_in_px - the ROI which is used for spectral analysis of the spectral
% images

    [results, particles_analized] = nmssBatchAnalysisNew(real_space_img, list_of_jobs, ...
                                     work_dir, analysis, ...
                                     white_light, measurement_info, roi_in_px, manual_particle_finding);
    
%     %if (manual_particle_finding)
%     global doc;
%     [results, particles_analized] = OldBatchAnalysis(real_space_img, doc.img_block, list_of_jobs, ...
%                                      work_dir, analysis, ...
%                                      white_light, measurement_info, roi_in_px, manual_particle_finding);                                
    return;
    %end
    
    
    
    

function [results, particles_analized] = OldBatchAnalysis(real_space_img, img_block, list_of_jobs, ...
                                     work_dir, analysis, ...
                                     white_light, measurement_info, roi_in_px, manual_particle_finding)
% nmssBatchAnalysis - performs the spectral analysis of the scanned area
%
% INPUT:
% real_space_img - the real space image structure which contains the real
%                  space image and its x-axis information
% list_of_jobs - the list of jobs structure which is saved with the
%                spectral images during scanning
% work_dir - the directory where the spectral images are located
% analysis - the analysis structure containing the particle recognition
% parameters (see more in nmssResetAnalysisParam)
% white_light - the array containing the white light data corresponding
% to the central wavelength of the spectral images
% measurement_info - a struct containing the measurement info
% roi_in_px - the ROI which is used for spectral analysis of the spectral
% images


    num_of_peaks_found = 1;
    berg_plot = zeros(0,2);
    results = '';

    % get the real spece image. y-boundaries defined by the user,
    % x-boundaries are taken fully
    
    roi_real_space_img = real_space_img;
    %roi_real_space_img.img = real_space_img.img(roi_in_px.y:roi_in_px.y+roi_in_px.wy - 1, :);
    roi_real_space_img.img = real_space_img.img(1:roi_in_px.wy, :);
    
    % display real space image
    real_image_figure_handle = figure;
    colormap gray;
    brighten(0.6);
    
    % MARK or FIND PARTICLES on the real space image
    threshold = 0;
    if (manual_particle_finding)
        
        real_space_image_to_display = real_space_img.img;

        % display real space image scaled to its physical coordinates
        figure(real_image_figure_handle);
        imagesc(real_space_image_to_display);
        
%         [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y] = ...
%             nmssMarkBrightSpots( roi_real_space_img.img, analysis, real_image_figure_handle, real_space_img.x_min, roi_in_px.y);
        [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y] = ...
            nmssMarkBrightSpots( roi_real_space_img.img, analysis, real_image_figure_handle, 0, 0);
        
        figure(real_image_figure_handle);
        imagesc([real_space_img.x_min, real_space_img.x_max], [roi_in_px.y, roi_in_px.y + roi_in_px.wy - 1], real_space_image_to_display);
    else

        % select jobs, which contain maximum intensity of particle images
        [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
            nmssFindBrightSpots( roi_real_space_img.img, analysis);
        real_space_image_to_display = real_space_img.img;


        % display real space image scaled to its physical coordinates
        figure(real_image_figure_handle);
        imagesc([real_space_img.x_min, real_space_img.x_max], [roi_in_px.y, roi_in_px.y + roi_in_px.wy - 1], real_space_image_to_display);
    end
    % indicate the positions of potential particles
    hold on;
    max_pos_x_real_space = nmssPixel2RealSpace( max_pos_x, size(real_space_img.img,2), ...
                              real_space_img.x_min, real_space_img.x_max );

    % draw a rectangle around the spot. The size of the rectangle
    % corresponds to the threshold limit
    top_left_x_rs = nmssPixel2RealSpace( top_left_x, size(real_space_img.img,2), ...
                              real_space_img.x_min, real_space_img.x_max );
    bottom_right_x_rs = nmssPixel2RealSpace( bottom_right_x, size(real_space_img.img,2), ...
                              real_space_img.x_min, real_space_img.x_max );

%     nmssDrawRectBetween2Points([top_left_x_rs', top_left_y'], [bottom_right_x_rs', bottom_right_y'], ...
%                                1, 'r');
    nmssDrawRectBetween2Points([top_left_x_rs', top_left_y'+ roi_in_px.y ], [bottom_right_x_rs', bottom_right_y' + roi_in_px.y], ...
                               1, 'r');


    
    figure(real_image_figure_handle);
    title(['Real Space Image (', num2str(length(max_pos_x)), ' particles)']);

    % n x 2 matrix, containing the x-position (the job (or frame) index) and the
    % y-position (the real space y-position) of a particle
    pos = [max_pos_x', max_pos_y', top_left_x', top_left_y', bottom_right_x', bottom_right_y'];
    
    if (isempty(pos))
        errordlg('No particle found.');
        return;
    end
    
    % let's sort the matrix along the first column
    pos = sortrows(pos, [1 2]);

    % get jobs with particles
    index_jobs_with_particles = pos(:,1);
    try
        jobs_with_particles = list_of_jobs(index_jobs_with_particles);
    catch
        disp(lasterr);
        keyboard;
    end

    num_of_particles = length(jobs_with_particles);

    % the result structure contains all graphs and corresponding result data
    %result.particle = cell(num_of_particles,1);


    % check if one of the target files exists
    prev_job_index = 0;
    img = zeros(roi_in_px.wy, roi_in_px.wx);
    particles_analized = 0;
    
    % the real space image data
    global doc;
    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    axis.x = (full_lim.x(1,1): (full_lim.x(1,2) - full_lim.x(1,1)) / size(doc.img,2) : full_lim.x(1,2));
    axis.unit = doc.figure_axis.unit;
    
%     % get all frames and put them into a data block
%     job = list_of_jobs(1);
%     [status img] = nmssOpenJobImage(job.filename, work_dir);
%     img_block_z_size = length(list_of_jobs);
%     img_block = zeros(size(img,1), size(img,2), img_block_z_size , 'uint16');
%     waitbar_handle = waitbar(0,'Creating Spectral data cube','CreateCancelBtn','delete(gcf);');
%     for k=1:img_block_z_size
%         % refresh waitbar
%         if (ishandle(waitbar_handle))
%             waitbar(k/img_block_z_size);
%         else
%             % user canceled
%             return;
%         end
%         job = list_of_jobs(k);
%         [status img] = nmssOpenJobImage(job.filename, work_dir);
%         % job couldn't be opened for whatever reason let's stop and
%         % debug
%         if(strcmp(status, 'ERROR'))
%             disp(lasterr);
%             keyboard;
%         end
%         img_block(:,:,k) = img;
%     end
%     delete(waitbar_handle);

    %img_block = nmssDataCubeCreator( list_of_jobs );
    
    
    waitbar_handle = waitbar(0,'Processing Images (find peak maximum and FWHM)','CreateCancelBtn','delete(gcf);');
    job_filename = '';
    for k = 1:num_of_particles

        % refresh waitbar
        if (ishandle(waitbar_handle))
            waitbar(k/num_of_particles);
        else
            % user canceled
            break;
        end
        

        % the ROI of the particle under investigation plus background
        % above and below
        roi_of_particle = nmssResetROI();
        roi_of_particle.exists = 1;
        roi_of_particle.valid = 1;
        roi_of_particle.x = pos(k,3);
        roi_of_particle.y = pos(k,4);
%             roi_of_particle.wx = pos(k,5) - pos(k,3) + 1;
%             roi_of_particle.wy = pos(k,6) - pos(k,4) + 1;
        roi_of_particle.wx = pos(k,5) - pos(k,3);
        roi_of_particle.wy = pos(k,6) - pos(k,4);
        
        % position in the real space image (usually somewhere in the center
        % of the image)
        position.x = pos(k,1);
        position.y = pos(k,2);

        %analysis = nmssResetAnalysisParam('external_threshold');
        analysis.threshold = threshold;

        job_index = index_jobs_with_particles(k);

        % TEMPORARY code:
        % get also the jobs around the particle
        % we wanna know if and how the spectrum changes with the
        % particle located at different x-positions with respect to the
        % slit.
        % 
        %first_job_index = job_index - 1;
        first_job_index = roi_of_particle.x;

        if ( first_job_index < 1)
            first_job_index = 1;
        end
        last_job_index = roi_of_particle.x + roi_of_particle.wx - 1;
        if (last_job_index > length(list_of_jobs))
            last_job_index = length(list_of_jobs);
        end


        res_en_vs_pos = [];
        res_en_vs_pos_index = 1;

        images = {};
        % get all frames (image) that contain the particle spectrum
        for kkk = first_job_index:last_job_index

            job = list_of_jobs(kkk);

            silent = 1;
            % get image (or spectrum) frame
            if (isempty(img_block))
                [status img job] = nmssOpenJobImage(job.filename, work_dir);
                
                if (~strcmp(status,'OK'))
                    err_txt = img;
                    break;
                end
                
            else
                img = img_block(:,:,kkk);
            end
            
            images{res_en_vs_pos_index} = cast(img','uint32');
            particle = GetParticleData(job, images{res_en_vs_pos_index}, roi_of_particle, roi_in_px, pos(k,2), white_light, analysis, axis);

            res_en_vs_pos(res_en_vs_pos_index, :) = [job.pos.x, particle.res_energy, particle.graph.smoothed];

            res_en_vs_pos_index = res_en_vs_pos_index + 1;
        end

        % sum up all images to receive the full spectral image of the
        % particle
        img = cast(zeros(size(images{1})),'uint32');
        for kkk=1:res_en_vs_pos_index-1;
            img = img + images{kkk};
        end

        % store particle data and other interesting details about the
        % particle
        results.particle(k,1) = GetParticleData(job, img, roi_of_particle, roi_in_px, pos(k,2), white_light, analysis, axis);
        results.particle(k,1).position = position; % the position in the real space image
        results.particle(k,1).res_en_vs_pos = res_en_vs_pos;

        particles_analized = particles_analized + 1;

        % activate real space image
        figure(real_image_figure_handle);
        hold on;
        % draw a small line on the top rim of the real space image just to
        % indicate the position of the particles
        line([position.x, position.x], [1, 6], 'LineStyle', '-');
        % convert the x-position from micons into pixel
        x_pos = nmssPixel2RealSpace( position.x, size(real_space_img.img,2), real_space_img.x_min, real_space_img.x_max );

        % get particle RGB color code derived from the resonance energy
        % (more exactly: wavelength)
        if (results.particle(k,1).res_energy ~= 0)
            particle_color = nmssWavelength2RGB( 1240 / results.particle(k,1).res_energy);
        else
            particle_color = [0, 0, 0];
        end

        plot(x_pos , position.y, ...
           '.', 'Color', particle_color);
%         plot(x_pos , floor(results.particle(k,1).graph.roi.particle.y + results.particle(k,1).graph.roi.particle.wy * 0.5), ...
%            '.', 'Color', particle_color);
    end
    
    
    
    
    
    
    % FILL UP results STRUCTURE
    %results.scanning_imaging = doc.scanning_imaging; % info about the scanning parameters
    results.white_light = white_light; % the white light used (usually this vector 
    % is longer than the graph of the spectra, because the spectra is
    % gained from a smaller than full x-range of the ccd-image. The
    % graph.offset_x_px indicates the pixel from which the graph contains the
    % spectrum
    results.measurement_info = measurement_info; % entered by the user
    results.working_dir = work_dir; % may not be in sync if data is moved!!!
    results.date = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    %results.berg_plot = berg_plot; % FWHM [eV] vs peak maximum position [eV]
    results.analysis = analysis;
    % real space image
    results.real_space_image.data = real_space_img.img;
    results.real_space_image.x_min = real_space_img.x_min;
    results.real_space_image.x_max = real_space_img.x_max;
    results.real_space_image.y_min = roi_in_px.y;
    results.real_space_image.y_max = roi_in_px.y + roi_in_px.wy - 1;

    % clear waitbar
    if (ishandle(waitbar_handle))
        delete(waitbar_handle);
    end
    
function particle = GetParticleData(job, img, roi_of_particle, roi_of_spectrum, row_index_of_max, white_light, analysis, axis)
            particle = nmssResetParticle();

            % cut out Spectra-ROI from the full spectral image
            roi_img = img(roi_of_spectrum.y:roi_of_spectrum.y+roi_of_spectrum.wy - 1, ...
                          roi_of_spectrum.x:roi_of_spectrum.x+roi_of_spectrum.wx - 1);
            
            analysis.img_signature = sum(roi_img');

            % use the real space image and get the spectra
            graph =  nmssGetParticleSpectFromRealSpaceImage(roi_img, row_index_of_max, ...
                                            white_light, roi_of_spectrum, roi_of_particle, ...
                                            analysis, axis);

            % results structure
            particle.data = job;
            if (isempty(graph))
                disp(['no particle found in: ', num2str(job.number)]);
                particle.valid = 0;
                return;
            end
            particle.valid = 1;
            particle.graph = graph;


            % if graph is empty res_energy and FWHM may not be defined!
            [graph_berg_plot, fit_x, fit_y, warning_txt] = nmssCreateBergPlot(particle);
    %         if (~isempty(warning_txt))
    %             disp(['Berg plot analysis status report for particle #', num2str(k),]);
    %             disp(warning_txt);
    %             disp('');
    %         end

            particle.res_energy = graph_berg_plot(1);
            particle.FWHM = graph_berg_plot(2);
            particle.max_intensity = graph_berg_plot(3);
            particle.fit_x = fit_x;
            particle.fit_y = fit_y;
            disp(char(warning_txt));


