% nmss - Nano Multi Scan Spectrometer (NMSS)
%        Main software module and GUI
%
% history:
%           2007-08-17 - Arpad Jakab: creation
%
%


function varargout = nmss(varargin)
% NMSS M-file for nmss.fig
%      NMSS, by itself, creates a new NMSS or raises the existing
%      singleton*.
%
%      H = NMSS returns the handle to a new NMSS or the handle to
%      the existing singleton*.
%
%      NMSS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSS.M with the given input arguments.
%
%      NMSS('Property','Value',...) creates a new NMSS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmss_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmss_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmss

% Last Modified by GUIDE v2.5 18-Nov-2009 21:25:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmss_OpeningFcn, ...
                   'gui_OutputFcn',  @nmss_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
%               
    
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nmss is made visible.
function nmss_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmss (see VARARGIN)
    disp('------- PLASMOSCOPE --------');
    disp('by Arpad Jakab, 2007, 2008, 2009, 2010');
    disp('arpad.jakab@yahoo.de');
    disp('Nano-Bio-Technology Group            www.nano-bio-tech.de');
    disp('Johannes Gutenberg University, Mainz, Germany');

    % Choose default command line output for nmss
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    
    % check if toolboxes are present
    % smoothing
    if (~exist('smooth')) 
        uiwait(errordlg('Can''t find smoothing toolbox. This software can''t run without smoothing!'));
        close(hObject);
        return;
    end
    % fitting
    if (~exist('fit')) 
        uiwait(errordlg('Can''t find fitting toolbox. This software can''t run without fitting!'));
        close(hObject);
        return;
    end

    % prepare data
    global doc;
    global app;
    global use_hardware;
    use_hardware = 1;
    if (length(varargin) > 0 && ischar(varargin{1}))
        if (strcmp(varargin{1},'NO_HARDWARE'))
            disp('No hardware available! Only analysis features can be used.');
            use_hardware = 0; % don't use hardware
        end
    end
    
    % load application settings
    LoadApplicationSettings();

    % default working dir
    nmss_path = which('nmss'); % find path of this script (nmss.m)
    [app.defaultDir,name,ext,versn] = fileparts(nmss_path);
    if (isfield(app, 'last_woring_dir'))
        doc.workDir = app.last_woring_dir;
    else
        doc.workDir = tempdir;
    end
    

    % initialize variable which stores measurement information
    doc.measurement_info = nmssResetMeasurementInfo();
    
    % application document data (this should serve to store all user generated
    % data
    LoadListOfJobs(doc.workDir);

    doc.img = [];

    % default measurement information
    DisplayMeasurementInfo(handles);
    
    
    % real space image
    doc.real_space_img = nmssResetRealSpaceImage();
    
    % Initialize Piezo Stage data
    doc.hStagePosDlgData.step_size = 5.0;
    doc.hStagePosDlgData.live_modus = 1;

    % initialize Scanning Imaging Dialog data
    doc.scanning_imaging.start_pos = 0;
    doc.scanning_imaging.end_pos = 200;
    doc.scanning_imaging.stepsize_pos = 1;
    doc.scanning_imaging.delay_unit = 'ms'; % other option 's'
    if (strcmp(doc.scanning_imaging.delay_unit,'ms'))
        doc.scanning_imaging.min_delay_after_taking_image = 10; % ms - the shutter needs 10ms to close and open again
    else
        doc.scanning_imaging.min_delay_after_taking_image = 0.01; % s - the shutter needs 10ms to close and open again
    end
    doc.scanning_imaging.delay_after_taking_image = doc.scanning_imaging.min_delay_after_taking_image; % ms or second it depends on job.exp_time_unit
    doc.scanning_imaging.duration_of_measurement = 0; % this one is defined in minutes
    doc.scanning_imaging.scan_type = 'lateral'; % other option is 'temporal'


    % pixel to micrometer calibration data
    app.calidata.micron_per_px.x = 1;
    app.calidata.micron_per_px.y = 1;

    % figure axis units (scaling info)
    doc.figure_axis.unit.x = 'pixel'; % other choices: 'micron', 'nanometer'
    doc.figure_axis.unit.y = 'pixel'; % other choices: 'micron', 'nanometer'
    % these two variables first of all the first one will be very important if
    % the pixel coordinates have to be converted to nm in spectroscopy modus
    doc.figure_axis.center.x = 670;% center of the image (1340 / 2) this value is bound to CCD chip which is used currently
    doc.figure_axis.center.y = 200;% center of the image (400 / 2)

    doc.figure_axis.scale.current.x = 1;
    doc.figure_axis.scale.current.y = 1;

    % ROI data for analysis
    doc.roi.particle = nmssResetROI();
    doc.roi.bg1 = nmssResetROI();
    doc.roi.bg2 = nmssResetROI();
    doc.roi.autobgwidth.x = 4; % defines the x-width of the background frame in pixels 
    doc.roi.autobgwidth.y = 4; % defines the y-width of the background frame in pixels 

    % white light correction data
    doc.white_light_corr.enable = 0; % disabled
    doc.white_light_corr.data = ones(1,1); % data size is unknown here
    doc.white_light_corr.filepath = {'<Select File>'}; % empty file path
    
    % analysis method and parameters
    doc.analysis = nmssResetAnalysisParam('0th_derivative');
    %doc.analysis = nmssResetAnalysisParam('absolute_maximum');
    
    % init exposure time settings
    doc.num_of_exposures = 1;
    doc.expTime = 100; % unit = ms
    
    
    
    % init nano stage
    % ---------------
    % connect with nano stage
    app.hStage = -1;
    set(handles.btnStagePosDlg,'Enable','off');
    set(handles.btnScanningImaging, 'Enable','off');
    set(handles.btnExecuteJobs, 'Enable','off');
    set(handles.btnOpenSPECControlDlg, 'Enable', 'off');
    
    % usability improvement: if the user runs 'nmss' instead of
    % 'nmss_no_hardware' he may encounter an error message. This check
    % chould avoid the error message and run nmss without hardware support
    if (exist('nmssPSConnect') == 0)
        use_hardware = 0;
        uiwait(msgbox('No Hardware found, Plasmoscope is running without hardware support!','No hardware','warn'));
    end
    if (use_hardware == 1)
        [status nanostage] = nmssPSConnect(0,1);
        if (strcmp(status, 'ERROR')) 
            errordlg(nanostage);
        else
            app.hStage = nanostage;
            set(handles.btnStagePosDlg,'Enable','on');
            set(handles.btnScanningImaging, 'Enable','on');
            set(handles.btnExecuteJobs, 'Enable','on');
            set(handles.btnOpenSPECControlDlg, 'Enable', 'on');
            
            % center nanostage
            [status val] = nmssPSSetPosX(app.hStage, 100);
            if (strcmp(status, 'ERROR')) 
                errordlg(val);
            else
                [status val] = nmssPSSetPosY(app.hStage, 100);
                if (strcmp(status, 'ERROR')) 
                    errordlg(val);
                end
            end
        end
    end
    

    % init spectrograph
    % -----------------
    doc.specinfo.Name = 'No spectrograph found';
    doc.specinfo.ListOfGratings = {1, 'No Grating'};
    doc.specinfo.CurrentGratingIndex = 1;
    doc.specinfo.CurrentWavelength = 0;
    if (use_hardware)
        [app.hSpectrograph, doc.specinfo] = nmssSPECInit();
    end

    set(handles.textSpectrograph, 'String', doc.specinfo.Name);
    set(handles.editCurrentGrating, 'String', doc.specinfo.ListOfGratings{doc.specinfo.CurrentGratingIndex,2});
    set(handles.editSpecGraphWavelength, 'String', num2str(doc.specinfo.CurrentWavelength , '%4.1f'));

    % wavelength calibration
    % create an array that contains the nm_per_pixel information (that is
    % used to properly assing pixel coordinate to wavelength coordinate)
    lll = length(app.wavelength_calibration.nm_per_pixel);
    if (iscell(app.wavelength_calibration.nm_per_pixel))
        app.wavelength_calibration.nm_per_pixel = cell2mat(app.wavelength_calibration.nm_per_pixel);
    end
    if (lll <= size(doc.specinfo.ListOfGratings,1))
        for i=lll+1:size(doc.specinfo.ListOfGratings,1)
            app.wavelength_calibration.nm_per_pixel(lll) = 1;
        end
    end
    app.wavelength_calibration.cur_grating_id = doc.specinfo.CurrentGratingIndex;


    % init camera
    % -----------------
    set(handles.btnTakeImage,'Enable','off');
    set(handles.btnScanningImaging, 'Enable','off');
    set(handles.btnExecuteJobs, 'Enable','off');
    if (use_hardware)
        app.hCamera = nmssCAMInit();
        if (app.hCamera ~= -1)
            set(handles.btnTakeImage,'Enable','on');
            set(handles.btnScanningImaging, 'Enable','on');
            set(handles.btnExecuteJobs, 'Enable','on');
        end
        % take an image. That halps the camera to put itself in a defined
        % state.
        [status camera_image] = nmssTakeImage(app.hCamera, 200, 1, -1); % par #4 waitbar handle. if -1, no waitbar needed
    end
    

    
    % initialize current job info
    doc.current_job = nmssResetJob();
    doc.previously_saved_job = doc.current_job.previously_saved_job;


    set(handles.editWorkingDir, 'String', doc.workDir);

    app.nmssMainWindow = handles.nmssMainWindow;

    % this will be displayed in the list box
    nmssFillJobsListbox(handles.listboxNMSSJobs, doc.list_of_jobs);
    
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
% -------------------------------------------------------------------------
function varargout = nmss_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;

% --- Executes on button press in btnTakeImage.
% -------------------------------------------------------------------------
function btnTakeImage_Callback(hObject, eventdata, handles)

    global doc;

    % proceed only if a valid numeric value has been entered
    if (~nmssValidateNumericEdit(handles.edExpTime, 'Exposure Time'))
        return;
    end
    % proceed only if a valid numeric value has been entered
    if (~nmssValidateNumericEdit(handles.editNumOfExps, 'Num of Exps'))
        return;
    end
    
    %expTime = str2double(get(handles.edExpTime,'String'));
    expTime = doc.expTime;
    num_of_exposures = doc.num_of_exposures;%
    

    set(handles.nmssMainWindow,'Pointer','watch');
    % display progress dialog (waitbar)
    hw = waitbar(0,'Acquiring image... Please wait...');
    global app;
    
    camera_image = [];
    
    [status camera_image] = nmssTakeImage(app.hCamera, expTime, num_of_exposures, hw);
        
    if (strcmp(status, 'ERROR'))
       % close progress bar "dialog"
        close(hw);
        return;
    end
        
    % check if correct image has been received
    if (size(camera_image,1) == 0)
        errordlg('No image received from the camera!');
        % close progress bar "dialog"
        close(hw);
        return;
    end
        
    % close progress bar "dialog"
    close(hw);

    set(handles.nmssMainWindow,'Pointer','arrow');
    
    
    global doc;
    
    job = nmssResetJob();
    job.grating = doc.specinfo.CurrentGratingIndex;
    job.central_wavelength = doc.specinfo.CurrentWavelength;
    job.status = 1;
    
    doc.img = camera_image';
    doc.current_job = job;    
    doc.sum_up_jobs = false; % default setting: if user selects more than one job
    % he gets the images in single images - otherwise (if true) the images
    % are summed up


    % activate figure to display the image
    if (isfield(app, 'nmssFigure'))
        if (ishandle(app.nmssFigure))
            figure_handles = guidata(app.nmssFigure);
        else
            nmssFigure();
        end
    else
        nmssFigure();
    end
    
    % get figure limits
    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    
    % get current figure limits (if zoomed, we have different limits than the original figure limits)
    figure(app.nmssFigure);
    figure_handles = guidata(app.nmssFigure);
    current_limits.x = xlim;
    current_limits.y = ylim;

    nmssPaintImage('refresh', doc.img, app.nmssFigure, figure_handles.canvasFigureAxes, full_lim, current_limits);

    % Update handles structure
    guidata(hObject, handles);



% --- Executes on button press in btnSelectDir.
% -------------------------------------------------------------------------
function btnSelectDir_Callback(hObject, eventdata, handles)
    global doc;
    dir = uigetdir(doc.workDir, 'Select working directory');

    
    % directory selected
    if (dir ~= 0)
        set(handles.editWorkingDir,'String',dir);
        LoadListOfJobs(dir);
        % this will be displayed in the list box
        nmssFillJobsListbox(handles.listboxNMSSJobs, doc.list_of_jobs);
        DisplayMeasurementInfo(handles);
        
        % reset the data cube
        doc.img_block = [];

    end
    
    
    % Update handles structure
    guidata(hObject, handles);


% DEPRECATED FUNCTION - but important code is contained herin, therfore do
% not delete it!
% --- Executes on button press in btnSave.
% -------------------------------------------------------------------------
function save_success = btnSave_Callback(hObject, eventdata, handles)
    % return value: 1 - if save was successful, 0 - otherwise
    save_success = 1;

    hw = waitbar(0,'Saving... Please wait...');
    file_write_status = 0;
    file_write_message = ' ';
    filename =   get(handles.editWorkingDir,'String');
      
    try

        
        disp ('Saving .xls file to:');
        disp (filename);
        
        titles = {'Laser 1','Laser 2','Whitelight','Background'};
        for j=1:size(handles.partSpect,2)
            titles{4+j} = ['Part.' num2str(j)];
        end
        [file_write_status, file_write_message] = xlswrite(filename, titles, 1, 'A1');
        waitbar(0.1);
        size(handles.greenLaser)
        [file_write_status, file_write_message] = xlswrite(filename, handles.greenLaser, 1, 'A2');
        waitbar(0.2);
        [file_write_status, file_write_message] = xlswrite(filename, handles.redLaser,1,'B2');
        waitbar(0.3);
        [file_write_status, file_write_message] = xlswrite(filename, handles.white,1,'C2');
        waitbar(0.4);
        [file_write_status, file_write_message] = xlswrite(filename, handles.back,1,'D2');
        waitbar(0.5);
        [file_write_status, file_write_message] = xlswrite(filename, handles.partSpect,1,'E2');
    catch
        warndlg(['There was an error while saving the data...\n\n',file_write_message ])
    end
    close(hw);

    disp (file_write_status);
    disp (file_write_message);
    
    if file_write_status ~= 1
        [errstring, errmsg] = sprintf('Can not write file:\n\n %s \n\nPlease check if file path is set correctly!', filename);
        warndlg(errstring);
        save_success = 0;
    end
    

% --- Executes on button press in btnStagePosDlg.
% -------------------------------------------------------------------------
function btnStagePosDlg_Callback(hObject, eventdata, handles)
% hObject    handle to btnStagePosDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % proceed only if a valid numeric value has been entered

    if (~nmssValidateNumericEdit(handles.edExpTime, 'Exposure Time'))
        return;
    end
    
    nmssStagePosDlg();

    % Update handles structure
    guidata(hObject, handles);




% --- Executes on selection change in listboxNMSSJobs.
% -------------------------------------------------------------------------
function listboxNMSSJobs_Callback(hObject, eventdata, handles)
% hObject    handle to listboxNMSSJobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxNMSSJobs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxNMSSJobs


% --- Executes during object creation, after setting all properties.
% -------------------------------------------------------------------------
function listboxNMSSJobs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxNMSSJobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in btnScanningImaging.
% -------------------------------------------------------------------------
function btnScanningImaging_Callback(hObject, eventdata, handles)
% hObject    handle to btnScanningImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    doc.workDir = get(handles.editWorkingDir, 'String');
    if (exist(doc.workDir,'dir') == 0)
        % no such directory
        errordlg({'Directory: '; ''; doc.workDir; '';'does not exist! Please create it!'});
        return;
    end

    if (nmssValidateNumericEdit(handles.edExpTime, 'Exposure Time'))
        
        global nmssScanningImagingDlg_Data;
        nmssScanningImagingDlg_Data.scanning_imaging = doc.scanning_imaging;
        
        nmssScanningImagingDlg();
    end




% --- Executes on button press in btnOpenSPECControlDlg_Callback.
% -------------------------------------------------------------------------
function btnOpenSPECControlDlg_Callback(hObject, eventdata, handles)
% hObject    handle to btnOpenSPECControlDlg_Callback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFigureWindow = findobj('Tag', 'nmssFigure');
    
    if (ishandle(hFigureWindow))
        txt = {['If you change the central wavelength of the spectrograph, ', ...
                'or if you change the grating the current image will no longer be valid ', ...
                'and the figure window must be closed'];'';'Do you want to close figure window?'}; 
        button = questdlg(txt,'Close figure window?','Yes','No','Yes');

        if (strcmp('Yes',button))
            delete(hFigureWindow);
        else
            return;
        end
    end
    
    nmssSPECControlDlg();



% -------------------------------------------------------------------------
function edExpTime_Callback(hObject, eventdata, handles)
% hObject    handle to edExpTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edExpTime as text
%        str2double(get(hObject,'String')) returns contents of edExpTime as a double
    global doc;
    
    % proceed only if a valid numeric value has been entered

    if (~nmssValidateNumericEdit(hObject, 'Exposure Time'))
        set(hObject,'String', num2str(doc.expTime))
        return;
    end
    
    expTime = str2double(get(hObject,'String'));
    doc.expTime = expTime;





% --- Executes during object creation, after setting all properties.
function editCurrentGrating_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCurrentGrating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes during object creation, after setting all properties.
function editSpecGraphWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpecGraphWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes on button press in btnExecuteJobs.
function btnExecuteJobs_Callback(hObject, eventdata, handles)
% hObject    handle to btnExecuteJobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    % ask user if he is happy with the current sample description
    txt = {'Are you happy with the content of Sample Description?'}; 
    button = questdlg(txt,'Sample Description','Yes','No','Yes');
    if (strcmp('No',button))
        return;
    end
    
    
    % check if directory exists where the images  will be saved to
    doc.defaultDir = get(handles.editWorkingDir, 'String');
    if (exist(doc.defaultDir,'dir') == 0)
        % no such directory
        errordlg({'Directory: '; ''; doc.defaultDir; '';'does not exist! Please create it!'});
        return;
    end
    
    % check if in this directory a list_of_jobs.mat exist
    list_of_job_filepath = fullfile(doc.workDir, 'list_of_jobs.mat');
    if (exist(list_of_job_filepath, 'file'))
        txt = {'It seems, that you have already executed jobs in this directory!'; ...
               'Please choose a different working directory or clean up this!' };
        errordlg(txt);
        return;
    end
    
    % disable some GUI elements during job execution
    %set(handles.btnAnalyze, 'Enable', 'off');
    set(handles.btnTakeImage, 'Enable', 'off');
    set(handles.btnOpenSPECControlDlg, 'Enable', 'off');
    set(handles.btnScanningImaging, 'Enable', 'off');
    set(handles.btnSelectDir, 'Enable', 'off');
    
    
    % loop over all piezo stage positions and take an image
    if (~nmssValidateNumericEdit(handles.edExpTime, 'Exposure time'))
        return;
    end
    exp_time = str2num(get(handles.edExpTime,'String'));
    
    
    % perform jobs:
    %   - take image
    %   - save image on hard disk
    [status list_of_executed_jobs] = nmssExecuteJobs(exp_time, doc.num_of_exposures, doc.list_of_jobs);
    
    if (strcmp(status, 'OK'))
        % JOB EXECUTION FINISHED -  let's save some data
        % ---------------------------------------------------------------------
        for k=1:length(list_of_executed_jobs)
            job_index = list_of_executed_jobs(k).number;
            doc.list_of_jobs(job_index) = list_of_executed_jobs(k);
        end


        % this will be displayed in the list box
        nmssFillJobsListbox(handles.listboxNMSSJobs, doc.list_of_jobs);

        % create real space image and save it together with otehr related
        % varibles
        
        % save list_of_jobs.mat
        filepath = fullfile(doc.workDir, 'list_of_jobs.mat');

        try
            list_of_jobs = doc.list_of_jobs;
            measurement_info = doc.measurement_info;
            % save list of jobs info, project description and real space image
            % onto the hard disk
            if (strcmp(doc.scanning_imaging.scan_type,'lateral'))
                %[real_space_img.img, real_space_img.x_min, real_space_img.x_max] = ...
                %    nmssGetRealSpaceImage(doc.list_of_jobs, doc.workDir);
                %doc.real_space_img = real_space_img;
                %save(filepath, 'list_of_jobs', 'measurement_info', 'real_space_img', '-mat');
                save(filepath, 'list_of_jobs', 'measurement_info', '-mat');
            else
                save(filepath, 'list_of_jobs', 'measurement_info', '-mat');
            end


        catch
            error_msg = ['Error saving file: ' lasterr()];
            disp(error_msg);
            errordlg(error_msg);
        end
    end
    
    % enable the disabled GUI elements during job execution
    %set(handles.btnAnalyze, 'Enable', 'on');
    set(handles.btnTakeImage, 'Enable', 'on');
    set(handles.btnOpenSPECControlDlg, 'Enable', 'on');
    set(handles.btnScanningImaging, 'Enable', 'on');
    set(handles.btnSelectDir, 'Enable', 'on');
    
    
    % Update handles structure
    guidata(hObject, handles);
    

function list_of_jobs = LoadListOfJobs(dir)
% handles    structure with handles and user data (see GUIDATA)
% loads list of jobs from the currently selected working directory
    global doc;
    doc.workDir = dir;
    
    old_measurement_info = doc.measurement_info;
    
    [doc.list_of_jobs, measurement_info, doc.real_space_img] = ...
        nmssLoadListOfJobs(doc.workDir);
    
    
%     % empty list of jobs? --> user sets up a new measurement
%     new_measurement = 0;
%     if ( isempty(doc.list_of_jobs))
%         new_measurement = 1;
%     elseif (isfield(doc.list_of_jobs(1), 'number'))
%         if (doc.list_of_jobs(1).number == 0)
%             new_measurement = 1;
%         end
%     end
%         
%     if (~(isempty(measurement_info.project) && ...
%           isempty(measurement_info.sample)))
%         if ( new_measurement == 1)
%             txt = [{'Do you want to keep the measurement info?'}];
%             btn = questdlg(txt, 'New measurement', 'Yes', 'No', 'Yes');
% 
%             if (strcmp(btn,'No'))
%                 doc.measurement_info = measurement_info;
%             end
%         end
%     else
%         doc.measurement_info = measurement_info;
%     end


    if (isempty(old_measurement_info.project) && ...
        isempty(old_measurement_info.sample))
        doc.measurement_info = measurement_info;
    elseif (isempty(measurement_info.project) && ...
            isempty(measurement_info.sample))
            txt = [{'Do you want to keep the measurement info?'}];
            btn = questdlg(txt, 'New measurement', 'Yes', 'No', 'Yes');

            if (strcmp(btn,'No'))
                doc.measurement_info = measurement_info;
            end
    else
        doc.measurement_info = measurement_info;
    end
    
    
% --- Executes on key press over listboxNMSSJobs with no controls selected.
function listboxNMSSJobs_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listboxNMSSJobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function [status img job] = OpenJob(filename, silent)
        global doc;
        status = 'OK';
        
        current_dir = doc.workDir;
%         if (job.status == 0)
%             if (~silent)
%                 errordlg('This job has not yet been executed, thus there is no image available!');
%             else
%                 img = ones(1,1);
%             end
%             status = 'ERROR';
%             return;
%         end
        
        [status camera_image job] = nmssOpenJobImage(filename, current_dir);
        if (strcmp(status, 'ERROR'))
            errordlg(camera_image);
        else
            camera_image = camera_image';
            img = zeros(size(camera_image));
            for k = 1:size(camera_image,1)
                img(k,:) = smooth(cast(camera_image(k,:), 'single'));
            end
            
            
            
        end



% --- Executes on button press in btnOpenFile.
function btnOpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnOpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    OpenMultipleFiles(hObject, eventdata, handles);
    return;

%     global doc;
% 
%     selected_jobs = get(handles.listboxNMSSJobs, 'Value');
%     
%     num_of_jobs = size(selected_jobs ,2);
%     
%     % no job selected ---> return
%     if (num_of_jobs < 1)
%         return;
%     end
%     
%     % check if more than 1 image have been opened, if yes bring a
%     % qustion dialog
%     if (num_of_jobs > 1)
%         txt = {['You have selected ', num2str(num_of_jobs), ' images to open.'];
%                ['NMSS will display the sum of all images in one figure window!'];
%                ['Do you want to open multiple images?']}; 
%         button = questdlg(txt,'Open multiple images?','Yes','No','Yes');
% 
%         if (strcmp('No',button))
%             return;
%         end
%     end
%     
%     % the user has the chance to open more than one image (they will be
%     % summed up)
%     all_imgs = cell(num_of_jobs,1); % init variable containing the summed images
%     for k = 1:num_of_jobs
%         job = doc.list_of_jobs(selected_jobs(k));
%     
%         if (~isfield(job, 'grating'))
%             job.grating = doc.specinfo.CurrentGratingIndex;
%         end
%         if (~isfield(job, 'central_wavelength'))
%             job.central_wavelength = doc.specinfo.CurrentWavelength;
%         end
%         silent = 0;
%         [status img] = OpenJob(job.filename, silent);
%         
%         % job couldn't be opened for whatever reason let's take the next
%         % one
%         if(strcmp(status, 'ERROR'))
%             continue;
%         end
%         
%         all_imgs{k,1} = img;
%     end
%     
%     summed_imgs = all_imgs{1,1};
%     job_1 = doc.list_of_jobs(selected_jobs(1));
%     for k = 2:num_of_jobs
%         job = doc.list_of_jobs(selected_jobs(k));
%         
%         % if spectrometer settings are different for the images do not sum
%         % them
%         if (job.grating ~= job_1.grating)
%             continue;
%         end
%         if (job.central_wavelength ~= job_1.central_wavelength)
%             continue;
%         end
%         summed_imgs = summed_imgs + all_imgs{k,1};
%         job_1.filename = [job_1.filename, ' + ', job.filename];
%     end
% 
%     doc.img = summed_imgs;
%     doc.current_job = job_1;
%     
%     nmssFigure();

%--------------------------------------------------------------
function OpenMultipleFiles(hObject, eventdata, handles)

    global doc;

    selected_job_indices = get(handles.listboxNMSSJobs, 'Value');
    
    num_of_jobs = size(selected_job_indices ,2);
    
    % no job selected ---> return
    if (num_of_jobs < 1)
        return;
    end
    
    doc.current_job = doc.list_of_jobs(selected_job_indices);
    doc.sum_up_jobs = false;
    doc.img = [];
    
    % reset the data cube
    doc.img_block = [];
    
    delete(findobj('Tag', 'nmssFigure'));
    
    nmssFigure();


    
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listboxNMSSJobs.
function listboxNMSSJobs_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listboxNMSSJobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







function editWorkingDir_Callback(hObject, eventdata, handles)
% hObject    handle to editWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWorkingDir as text
%        str2double(get(hObject,'String')) returns contents of editWorkingDir as a double

    new_dir = get(hObject,'String');
    
    global doc;
    doc.workDir = new_dir;
    
    % Update handles structure
    guidata(hObject, handles);
    

    
function handle = nmssGetHandle()
    handle = handles.nmssMainWindow;
    
    
%
function LoadApplicationSettings()

    global app;
    
    % init application settings
    % default working dir
    nmss_path = which('nmss');
    [app.defaultDir,name,ext,versn] = fileparts(nmss_path);

    % pixel to micrometer calibration data
    app.calidata.micron_per_px.x = 1;
    app.calidata.micron_per_px.y = 1;

    % init nano stage
    % ---------------
    app.hStage = -1;

    % init spectrograph
    % -----------------
    app.hSpectrograph = -1;

    % wavelength calibration
    app.wavelength_calibration.nm_per_pixel = 1
    app.wavelength_calibration.cur_grating_id = 1;

    % init camera
    % -----------------
    app.hCamera = -1;

    % handle of the main window (will be overwritten as soon the main
    % window has been created)
    app.nmssMainWindow = 0;
    
    
    filepath = fullfile(app.defaultDir, 'nmss.mat');
    % migration of saving applicatin data into a non-hidden file
    if (~exist(filepath, 'file'))
        filepath = fullfile(app.defaultDir, '.nmss.mat');
    end

    if (exist(filepath, 'file'))
        try
            load(filepath); % loads variable 'save_app'
            app = save_app;
            %nmssDisplayStruct(app);
            
        catch
            disp(lasterr());
        end
    end


% --- Executes when user attempts to close nmssMainWindow.
function nmssMainWindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssMainWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global app;
    global doc;

    global use_hardware;
    
    if (use_hardware)
        % disconnect hardware
        [status val] = nmssPSDisconnect(app.hStage);
        if (strcmp(status, 'OK')) 
            disp(['Nanostage disconnected successfully:' status ' ' int2str(val)]);
        else
            disp(val);
        end

        [status val] = nmssSPECDisconnect(app.hSpectrograph);
        if (strcmp(status, 'OK')) 
            disp(['Spectrograph disconnected successfully:' status ' ' int2str(val)]);
        else
            disp(val);
        end

        [status val] = nmssCAMClose(app.hCamera);
        if (strcmp(status, 'OK')) 
            disp(['Camera disconnected successfully:' status ' ' int2str(val)]);
        else
            disp(val);
        end
    end
    
    
    app.last_woring_dir = doc.workDir;
    
    % save application settings
    filepath = fullfile(app.defaultDir, 'nmss.mat');
    
    save_app = app;

    try
        save(filepath, 'save_app','-mat');
    catch
        error_msg = ['Error saving application data: ' lasterr()];
        disp(error_msg);
    end
    
    % close children windows
    if (ishandle(app.nmssSpecAnalysisDlg)) % spectrum analysis dialog box
        delete(app.nmssSpecAnalysisDlg);
    end
    if (ishandle(app.nmssFigure)) % figure display window
        delete(app.nmssFigure);
    end
    


% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in btnTestButton.
function btnTestButton_Callback(hObject, eventdata, handles)
% hObject    handle to btnTestButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global app;
    global doc;
    global use_hardware;
    
    if (~use_hardware)
        errordlg('No hardware present'); % the implemented routin needs hardware
        return;
    end
    
    % disconnect hardware
    [status val] = nmssCAMClose(app.hCamera);
    if (strcmp(status, 'OK')) 
        disp(['Camera disconnected successfully:' status ' ' int2str(val)]);
    else
        disp(val);
    end
    
    temp_dir = 'C:\temp';
    cmd_str = ['.\NMSS_Camera\nmssCAMMultiExp\Debug\nmssCAMMultiExp.exe ', ...
               ' 1 1 1340 400 1 1 ', ...
               num2str(doc.expTime), ' ', '100 3 ', ...
               '"',temp_dir, '" ', '1 ', ...
               ' &']; % we need & to start the external process in the background
                      % matlab returns immidiatelly so it can proceed with
                      % script execution (e.g. canceling the external
                      % process if the user wishes so)
    
    [status,result] = dos(cmd_str)
    
    uiwait(msgbox(['Press OK to kill the dos script!']));
    
    term_signal = 'terminator harr harr';
    save([temp_dir, 'termination.mat'], 'term_signal');
    
    time_out = 60; % 60 sec timoe out before performing external kill
    start_time = clock;
    elapsed_time = etime(job_exec_end_time, job_exec_start_time);
    
    % loop as long the termination file exists
    while(exist([temp_dir, 'termination.mat']))
        
        % check for time out
        if(time_out < etime(clock(), start_time))
            [status,result] = dos('taskkill /F /IM nmssCAMMultiExp.exe')
            % maybe calling pl_cam_uinit here would be good to free up all
            % resources
            nmssCAMUninit(1);
            break;
        end
    end
            
    % init camera
    % -----------------
    set(handles.btnTakeImage,'Enable','off');
    set(handles.btnScanningImaging, 'Enable','off');
    set(handles.btnExecuteJobs, 'Enable','off');
    if (use_hardware)
        app.hCamera = nmssCAMInit();
        if (app.hCamera ~= -1)
            set(handles.btnTakeImage,'Enable','on');
            set(handles.btnScanningImaging, 'Enable','on');
            set(handles.btnExecuteJobs, 'Enable','on');
        end
    end
    



function editWorkDescription_Callback(hObject, eventdata, handles)
% hObject    handle to editWorkDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWorkDescription as text
%        str2double(get(hObject,'String')) returns contents of editWorkDescription as a double


% --- Executes during object creation, after setting all properties.
function editWorkDescription_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWorkDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));




% --- Executes on button press in btnEditSampleDescr.
function btnEditSampleDescr_Callback(hObject, eventdata, handles)
% hObject    handle to btnEditSampleDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    uiwait(nmssMeasurementInfo()); % opens the mesurement info edit dialog
    
    DisplayMeasurementInfo(handles);


% --- Executes on button press in pbBergView.
function pbViewResults(hObject, eventdata, handles)
    pbBergView_Callback(hObject, eventdata, handles)

% --- Executes on button press in pbBergView.
function pbBergView_Callback(hObject, eventdata, handles)
% hObject    handle to pbBergView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    global doc;
    %nmssViewBergPlotGraphMenu('Results', doc.results);
    
    old_work_dir = pwd();
    cd(doc.workDir);
    
    [filename, dirname] = uigetfile({'*.mat','Matlab data file (*.mat)'}, 'Load results - Select file');
    
    cd(old_work_dir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    results_file_path = fullfile(dirname, filename);
    
    load(results_file_path ); % load struct called: results
    
    % Before opening the dialog fill dialog data
    global nmssResultsViewerDlg_Data;
    if (exist('results'))
        nmssResultsViewerDlg_Data.results = results;
    elseif (exist('results_selected'))
        nmssResultsViewerDlg_Data.results = results_selected;
    end
    nmssResultsViewerDlg_Data.workDir = doc.workDir;
    
    % CALL Results Viewer dialog
    nmssResultsViewerDlg();
    

function DisplayMeasurementInfo(handles)
% fills the measurement info edit box on the main window
    global doc;
    
    measurement_info = doc.measurement_info;
    
    set(handles.editProject, 'String', measurement_info.project);
    set(handles.editSample, 'String', measurement_info.sample);
    set(handles.editMedium, 'String', measurement_info.medium);
    set(handles.editRemarks, 'String', measurement_info.remarks);
    set(handles.cbIRFilter, 'Value', measurement_info.ir_filter_used);



% --- Executes on button press in cbIRFilter.
function cbIRFilter_Callback(hObject, eventdata, handles)
% hObject    handle to cbIRFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbIRFilter



function editProject_Callback(hObject, eventdata, handles)
% hObject    handle to editProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editProject as text
%        str2double(get(hObject,'String')) returns contents of editProject as a double


% --- Executes during object creation, after setting all properties.
function editProject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSample_Callback(hObject, eventdata, handles)
% hObject    handle to editSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSample as text
%        str2double(get(hObject,'String')) returns contents of editSample as a double


% --- Executes during object creation, after setting all properties.
function editSample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editMedium_Callback(hObject, eventdata, handles)
% hObject    handle to editMedium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMedium as text
%        str2double(get(hObject,'String')) returns contents of editMedium as a double


% --- Executes during object creation, after setting all properties.
function editMedium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMedium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editRemarks_Callback(hObject, eventdata, handles)
% hObject    handle to editRemarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRemarks as text
%        str2double(get(hObject,'String')) returns contents of editRemarks as a double


% --- Executes during object creation, after setting all properties.
function editRemarks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRemarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on selection change in popupNumOfExps.
function popupNumOfExps_Callback(hObject, eventdata, handles)
% hObject    handle to popupNumOfExps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupNumOfExps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupNumOfExps


% --- Executes during object creation, after setting all properties.
function popupNumOfExps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupNumOfExps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editNumOfExps_Callback(hObject, eventdata, handles)
% hObject    handle to editNumOfExps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumOfExps as text
%        str2double(get(hObject,'String')) returns contents of editNumOfExps as a double
    global doc;
    
    % proceed only if a valid numeric value has been entered

    if (~nmssValidateNumericEdit(hObject, 'Exposure Time'))
        set(hObject,'String', num2str(doc.num_of_exposures))
        return;
    end
    
    num_of_exposures = str2double(get(hObject,'String'));
    doc.num_of_exposures = num_of_exposures;



% --- Executes during object creation, after setting all properties.
function editNumOfExps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumOfExps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in pbDataEval.
function pbDataEval_Callback(hObject, eventdata, handles)
% hObject    handle to pbDataEval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    selected_job_indices = get(handles.listboxNMSSJobs, 'Value');
    doc.current_job = doc.list_of_jobs(selected_job_indices);



    nmssDataEvaluationDlg();


% --- Executes on button press in btnSetAcquisROI.
function btnSetAcquisROI_Callback(hObject, eventdata, handles)
% hObject    handle to btnSetAcquisROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssInputROIDlg_Data;
    
    nmssInputROIDlg_Data.ROI_x = 1;
    nmssInputROIDlg_Data.ROI_y = 1;
    nmssInputROIDlg_Data.ROI_wx = 1340;
    nmssInputROIDlg_Data.ROI_wy = 400;
    
    uiwait(nmssInputROIDlg);
    
    



% --- Executes on button press in pbOpenSum.
function pbOpenSum_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpenSum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


