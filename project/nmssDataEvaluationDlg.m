function varargout = nmssDataEvaluationDlg(varargin)
% NMSSDATAEVALUATIONDLG M-file for nmssDataEvaluationDlg.fig
%      NMSSDATAEVALUATIONDLG, by itself, creates a new NMSSDATAEVALUATIONDLG or raises the existing
%      singleton*.
%
%      H = NMSSDATAEVALUATIONDLG returns the handle to a new NMSSDATAEVALUATIONDLG or the handle to
%      the existing singleton*.
%
%      NMSSDATAEVALUATIONDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSDATAEVALUATIONDLG.M with the given input arguments.
%
%      NMSSDATAEVALUATIONDLG('Property','Value',...) creates a new NMSSDATAEVALUATIONDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssDataEvaluationDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssDataEvaluationDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssDataEvaluationDlg

% Last Modified by GUIDE v2.5 13-Jul-2010 20:34:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssDataEvaluationDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssDataEvaluationDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nmssDataEvaluationDlg is made visible.
function nmssDataEvaluationDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssDataEvaluationDlg (see VARARGIN)

% Choose default command line output for nmssDataEvaluationDlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssDataEvaluationDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssDataEvaluationDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssDataEvaluationDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function [status, white_light] = PrepareForSpecAnalysis()
    
    global doc;
    status = 'ERROR';
    white_light = [];
    
    % check if all necessary analysis parameters have been set
    try
        % check if the figure's x-axis is set to nanometers
        if (~strcmp(doc.figure_axis.unit.x,'nanometer'))
            errordlg('Please select ''nanometer'' units for the figure x-axis! Then run analysis again!');
            error('x-axis no nanometer');
        end

            % check if white light is loaded
            white_light = ones(size(doc.img,2),2);
            if (doc.white_light_corr.enable)
                white_light = doc.white_light_corr.data;
            else
                txt = {'No white light has been loaded or not enabled!'; ...
                        'Do you want to continue without white light normalization?'}; 
                button = questdlg(txt,'Analyze without white light normalization?','Yes','No','Yes');

                if (strcmp('No',button))
                    error('No white light has been loaded or not enabled');
                end
            end
%        end
        
        

        % defines the x-coordinates of the region of interest
        roi_in_px = doc.roi.particle;

        % check if ROI makes any sense
        if (roi_in_px.wx <= 1)
            txt = {['You have defined a region of interest (ROI) with a width of ', num2str(roi_in_px.wx), ' starting at ', num2str(roi_in_px.x)]; ...
                   'This ROI appears to be very small'; ''; ...
                    'Do you want to continue with this nonsense region of interest?'}; 
            button = questdlg(txt,'Malformed ROI','Yes','No','Yes');

            if (strcmp('No',button))
                error('ROI appears to be very small');
            end
        end
    catch
        
        % get last error
        if (strcmp(lasterr(),'x-axis no nanometer'))
            % open figure with the first selected job, so that the user has the
            % chance to set analysis parameter
            job_1 = doc.list_of_jobs(1);

            if (~isfield(job_1, 'grating'))
                job_1.grating = doc.specinfo.CurrentGratingIndex;
            end
            if (~isfield(job_1, 'central_wavelength'))
                job_1.central_wavelength = doc.specinfo.CurrentWavelength;
            end
            silent = 0;


            current_dir = doc.workDir;

            [status camera_image job] = nmssOpenJobImage(job_1.filename, current_dir);

            if (strcmp(status, 'ERROR'))
                % job couldn't be opened
                errordlg(camera_image);
                return;
            else
                camera_image = camera_image';
                img = zeros(size(camera_image));
                %smooth 2d image
                for k = 1:size(camera_image,1)
                    img(k,:) = smooth(cast(camera_image(k,:), 'single'));
                end
            end

            % keep current image 
            doc.img = img;
            % keep current job 
            doc.current_job = job_1;

            nmssFigure();
        end
        
        return;
    end
    
%     % ask user if he is content with the current sample description
%     txt = {'Here is the last chance to change or add something to the Sample Description!';...
%            ''; 'Do you want to continue with the current Sample Description?'}; 
%     button = questdlg(txt,'Sample Description','Yes','No','Yes');
%     if (strcmp('No',button))
%         return;
%     end

    
    % load real space image (but only the part which is selected by the
    % user)
    %if (isempty(doc.real_space_img.img))
        % load fron the hard disk
        [doc.real_space_img.img, doc.real_space_img.x_min, doc.real_space_img.x_max] = ...
        nmssGetRealSpaceImage( doc.list_of_jobs, doc.workDir);
        doc.real_space_img.y_min = roi_in_px.y;
        doc.real_space_img.y_max = roi_in_px.y + roi_in_px.wy - 1;
    %end
    
    % return status indicator
    status = 'OK';

    

function SpectralAnalysis(manual_particle_finding)
    
    global doc;
    global app;
    
    % assembles data cube, but only if it hasn't been assembled before
    if (~isfield(doc, 'img_block') || isempty(doc.img_block))
        doc.img_block = nmssDataCubeCreator( doc.list_of_jobs, doc.workDir );

    end

    % get the real space image
    [status, white_light] = PrepareForSpecAnalysis();
    if (strcmp(status,'ERROR'))
        return;
    end
    

    % defines the x-coordinates of the region of interest
    roi_in_px = doc.roi.particle;
    

    [results, particles_analized] = nmssBatchAnalysis( doc.real_space_img, doc.list_of_jobs, doc.workDir, ...
                                 doc.analysis, white_light, doc.measurement_info, roi_in_px, manual_particle_finding);
    if (isempty(results))
        errordlg('Invalid analysis mehtod');
        return;
    end
    
    if (~isfield(results, 'particle'))
        disp('No particles selected during manual particle selection! It''s OK, this is just a notification message.')
        return;
    end

    % create Berg plot
    berg_plot = zeros(0,3);
    for i=1:length(results.particle)
        if (~isempty(results.particle(i)))
            if ((results.particle(i).valid == 1) & (results.particle(i).res_energy ~= 0))
                berg_plot = [berg_plot; results.particle(i).res_energy, results.particle(i).FWHM, results.particle(i).max_intensity];
            end
        end
    end

%     % highlight or create figure for berg plot
%     app.berg_plot_fig(1) = figure();
%     
%     % display berg plot
%     plot(berg_plot(:,1), berg_plot(:,2),'.');
%     title(['Full Width at Half Maximum vs Resonance Energy (', num2str(particles_analized),...
%         ' particles analized)']);
%     xlabel('Resonance Peak Maximum [eV]');
%     ylabel('FWHM [eV]');
%     
%     figure;
%     hist(berg_plot(:,3), [100:100:2500]);
%     title(['Peak May Intensity Distribution (', num2str(particles_analized),...
%         ' particles analized)']);
%     xlabel('Max Peak Intensity (a.u.)');

    txt = {'Do you want to save results into the current working directory?'}; 
    button = questdlg(txt,'Save results?','Yes','No','Yes');

    % saving the results structure may take some time... switch on
    % waitbar
    waitbar_handle = waitbar(0,'Saving analysis results, please wait...');

    if (strcmp('Yes',button))

        % get old working directory
        old_current_dir = pwd;

        %change to nmss working directory (which is not the same as the
        %matlab working directory)
        cd(doc.workDir);

        [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save results', 'results.mat');
        cd(old_current_dir);

        if (filename ~= 0) % user pressed OK in file save dialog

            % save berg plot matrix
            filepath = fullfile(dirname, filename)
            try
                save(filepath, 'results', '-mat');
            catch
                errordlg(lasterr());
            end
        end
    end

    % open berg plot data viewer dialog (the user can mark data points and
    % view the corresponding graph)
    doc.results = results;
    
        % clear waitbar
    if (ishandle(waitbar_handle))
        delete(waitbar_handle);
    end
    
% --- Executes on button press in pbSpectralAnalysis.
function pbSpectralAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to pbSpectralAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    SpectralAnalysis(false);


    %nmssDataEvaluationDlg_CloseRequestFcn(handles.nmssDataEvaluationDlg, eventdata, handles);
    


% --- Executes on button press in pbTimeTrace.
function pbTimeTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pbTimeTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    % assembles data cube, but only if it hasn't been assembled before
    if (~isfield(doc, 'img_block') || isempty(doc.img_block))
        doc.img_block = nmssDataCubeCreator( doc.list_of_jobs, doc.workDir );
    end
    
    if (isempty(doc.img_block))
        errordlg('Out of memory - data cube can not be created!');
        return;
    end
    
    nmssFixedROIAnalysis(handles, doc.roi, doc.img_block, doc.current_job, doc.workDir);
    
    



% --- Executes on button press in pbClose.
function pbClose_Callback(hObject, eventdata, handles)
% hObject    handle to pbClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssDataEvaluationDlg_CloseRequestFcn(handles.nmssDataEvaluationDlg, eventdata, handles);


% --- Executes on button press in pbViewResults.
function pbViewResults_Callback(hObject, eventdata, handles)
% hObject    handle to pbViewResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

     global doc;
% %     global nmssDataEvaluationDlg_Data;
% %     global nmssResultsViewerDlg_Data;
% %     nmssResultsViewerDlg_Data = [];
%     
%     
%     
%     old_work_dir = pwd();
%     cd(doc.workDir);
%     
%     [filename, dirname] = uigetfile({'*.mat','Matlab data file (*.mat)'}, 'Load results - Select file');
%     
%     cd(old_work_dir);
%     
%     if (filename == 0) % user pressed cancel
%         return;
%     end
%     
%     results_file_path = fullfile(dirname, filename);
%     
%     load(results_file_path ); % load struct called: results
%     
%     % see if results or results selected has been loaded
%     if (exist('results'))
%         results = results;
%     elseif (exist('results_selected'))
%         results = results_selected;
%     else
%         errordlg('No results data structure found!');
%         return;
%     end
%     
%     % see if new or old style FWHM parameter was read
%     if(~isstruct(results.particle(1)))
%         l = length(results.particle);
%         particles = cell(l,1);
% 
%         for i=1:l
%             particles{i} = results.particle(i);
%             rmfield(particles{i},'FWHM');
% 
%             fwhm.full = results.particle(i).FWHM;
%             fwhm.leftside = NaN;
%             fwhm.rightside = NaN;
% 
%             particles{i}.FWHM = fwhm;
%         end
%         % now set up particle struct array again, but with the new FWHM struct
%         rmfield(results, 'particle');
%         for i=1:l
%             results.particle(i) = particles{i};
%         end
%     end

    [loadedFile, results] = nmssLoadResults(doc.workDir);
    
    if (isempty(loadedFile)) return; end;
    
    % OPEN DIALOG:
    hResultsViewerDlg = nmssResultsViewerDlg();
    
    user_data_ResultsViewerDlg = get(hResultsViewerDlg, 'UserData');
    
    % register export data function
    user_data_ResultsViewerDlg.hExportFcn = @nmssDataEvaluationDlg_SaveResults;
    user_data_ResultsViewerDlg.hOKFcn = @nmssDataEvaluationDlg_ResultsViewerOK;
    
    user_data_ResultsViewerDlg.results = results;
    %user_data_ResultsViewerDlg.work_results = user_data.results;

    set(hResultsViewerDlg, 'UserData', user_data_ResultsViewerDlg);
    
    user_data_ResultsViewerDlg.hFigInitFcn(hResultsViewerDlg);
    

    
%     % display the real space image of the scanned area
%     figure('Name', 'Real Space Image', 'Tag', 'nmssResultsViewerFigure_RealSpace');
%     imagesc([nmssDataEvaluationDlg_Data.results.real_space_image.x_min, nmssDataEvaluationDlg_Data.results.real_space_image.x_max], ...
%             [nmssDataEvaluationDlg_Data.results.real_space_image.y_min, nmssDataEvaluationDlg_Data.results.real_space_image.y_max], ...
%             nmssDataEvaluationDlg_Data.results.real_space_image.data);
%     nmssResultsViewerDlg_Data.real_space_image = nmssDataEvaluationDlg_Data.results.real_space_image;
% 
%     % register working directory
%     nmssResultsViewerDlg_Data.workDir = doc.workDir;
%     
%     % register file name
%     nmssResultsViewerDlg_Data.results_file_path = results_file_path;
%     
%     % register export data function
%     nmssResultsViewerDlg_Data.hExportFcn = @nmssDataEvaluationDlg_SaveResults;
%     
%     % OPEN DIALOG:
%     nmssResultsViewerDlg();
    

    %nmssDataEvaluationDlg_CloseRequestFcn(handles.nmssDataEvaluationDlg, eventdata, handles);
function user_canceled = nmssDataEvaluationDlg_ResultsViewerOK(hDlg)
% called if the user closed the dialog with OK
    dlg_user_data = get(hDlg, 'UserData');
    
    user_canceled = nmssDataEvaluationDlg_SaveResults(dlg_user_data.results);
    
    


function  user_canceled = nmssDataEvaluationDlg_SaveResults(results)

    user_canceled = nmssSaveResults(results);

    
    


% --- Executes when user attempts to close nmssDataEvaluationDlg.
function nmssDataEvaluationDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssDataEvaluationDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in pbImageOverlay.
function pbImageOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to pbImageOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    %nmssViewBergPlotGraphMenu('Results', doc.results);
    
    % call image overlay dialog where the user can correlate particles and
    % save the correlated data into a mat file
    nmssImageOverlay();



% --- Executes on button press in btnManualSpectrum.
function btnManualSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to btnManualSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    SpectralAnalysis(true);

    


% --- Executes on button press in btnExporDataCube.
function btnExporDataCube_Callback(hObject, eventdata, handles)
% hObject    handle to btnExporDataCube (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    % assembles data cube, but only if it hasn't been assembled before
    if (~isfield(doc, 'img_block') || isempty(doc.img_block))
        doc.img_block = nmssDataCubeCreator( doc.list_of_jobs, doc.workDir );
    end
    
    if (isempty(doc.img_block))
        errordlg('Out of memory - data cube can not be created!');
        return;
    end
    
    %data_cube = doc.img_block;
    
    
    % get x-axis (can be pixel, or nm - wavelength or um, when properly calibrated in imaging mode) 
    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    xaxis.data = (full_lim.x(1,1): (full_lim.x(1,2) - full_lim.x(1,1)) / size(doc.img,2) : full_lim.x(1,2));
    xaxis.unit = doc.figure_axis.unit;


    [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Save Data Cube as Mat-File...'}, 'Save results', 'data_cube.mat');
        
    % user hit cancel button
    if (filename == 0)
        return;
    end

    filepath = fullfile(dirname, filename);
    
    hW = waitbar(1, {'Please Wait, Data storage is under way!'; 'It can take some minutes...'});

    save(filepath, 'doc.img_block', 'xaxis');
    
    delete(hW);








% --- Executes on button press in pbViewCorrParticles.
function pbViewCorrParticles_Callback(hObject, eventdata, handles)
% hObject    handle to pbViewCorrParticles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    global doc;
    global nmssDataEvaluationDlg;
    global nmssResultsViewerDlg_Data;
    nmssResultsViewerDlg_Data = [];
    
    
    old_work_dir = pwd();
    cd(doc.workDir);
    
    [filename, dirname] = uigetfile({'*.mat','Matlab data file (*.mat)'}, 'Load correlated particles file - Select file');
    
    cd(old_work_dir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    corr_part_file_path = fullfile(dirname, filename);
    
    load(corr_part_file_path ); % load struct called: results
    
    % see if results or results selected has been loaded
    if (exist('corr_part'))
        nmssDataEvaluationDlg_Data.corr_part = corr_part;
        
        % transform struct array into a 2D array of particle structs
        ll = length(corr_part);
        for i=1:ll
            c = corr_part(i).pdata;
            particle(i,:) = cell2mat(c); 
        end
        
        nmssResultsViewerDlg_Data.particle = particle;
    else
        errordlg('No correlated particle data (corr_part) structure found!');
        return;
    end
    
    % register working directory
    nmssResultsViewerDlg_Data.workDir = doc.workDir;
    
    % register file name
    nmssResultsViewerDlg_Data.results_file_path = corr_part_file_path;
    
    % register export data function
    nmssResultsViewerDlg_Data.hExportFcn = @nmssDataEvaluationDlg_SaveCorrPart;
    
    % OPEN DIALOG:
    nmssResultsViewerDlg();
    

    %nmssDataEvaluationDlg_CloseRequestFcn(handles.nmssDataEvaluationDlg, eventdata, handles);
    
    
% -------------------------------------------------------------------------
% saves the correlated particle data structure
function nmssDataEvaluationDlg_SaveCorrPart(new_corr_part)

    global nmssDataEvaluationDlg_Data;
    global doc;
    
    % save results file
    
    % get old working directory
    old_current_dir = pwd;

    %change to nmss working directory (which is not the same as the
    %matlab working directory)
    cd(doc.workDir);

    [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save results', 'corr_part.mat');
    cd(old_current_dir);

    if (filename ~= 0) % user pressed OK in file save dialog
        
        nmssDataEvaluationDlg_Data.corr_part = new_corr_part;

        corr_part = nmssDataEvaluationDlg_Data.corr_part;
        
        % save berg plot matrix
        filepath = fullfile(dirname, filename)
        try
            save(filepath, 'corr_part', '-mat');
        catch
            errordlg(lasterr());
        end
    end
    

