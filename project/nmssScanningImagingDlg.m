function varargout = nmssScanningImagingDlg(varargin)
% NMSSSCANNINGIMAGINGDLG M-file for nmssScanningImagingDlg.fig
%      NMSSSCANNINGIMAGINGDLG, by itself, creates a new NMSSSCANNINGIMAGINGDLG or raises the existing
%      singleton*.
%
%      H = NMSSSCANNINGIMAGINGDLG returns the handle to a new NMSSSCANNINGIMAGINGDLG or the handle to
%      the existing singleton*.
%
%      NMSSSCANNINGIMAGINGDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSSCANNINGIMAGINGDLG.M with the given input arguments.
%
%      NMSSSCANNINGIMAGINGDLG('Property','Value',...) creates a new NMSSSCANNINGIMAGINGDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssScanningImagingDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssScanningImagingDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssScanningImagingDlg

% Last Modified by GUIDE v2.5 15-Nov-2008 19:07:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssScanningImagingDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssScanningImagingDlg_OutputFcn, ...
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


% --- Executes just before nmssScanningImagingDlg is made visible.
function nmssScanningImagingDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to nmssScanningImagingDlg (see VARARGIN)

    % Choose default command line output for nmssScanningImagingDlg
    handles.output = hObject;
    
    global nmssScanningImagingDlg_Data;
    scan_data = nmssScanningImagingDlg_Data.scanning_imaging;

    % initialize GUI-elements
    set(handles.editScanningStartPos,'String', scan_data.start_pos);
    set(handles.editScanningEndPos,'String', scan_data.end_pos);
    set(handles.editScanningStepsize,'String', scan_data.stepsize_pos);
    set(handles.editDelayAfterExp,'String', scan_data.delay_after_taking_image);
    set(handles.editDuration,'String', scan_data.duration_of_measurement);
    set(handles.textDelayUnit,'String', ['(', scan_data.delay_unit, ')']);
    
    if (strcmp(scan_data.scan_type,'lateral'))
        set(handles.rbLateralScan, 'Value', 1);
        set(handles.rbTemporalScan, 'Value', 0);
        rbLateralScan_Callback(handles.rbLateralScan, eventdata, handles)
        
    else
        set(handles.rbLateralScan, 'Value', 0);
        set(handles.rbTemporalScan, 'Value', 1);
        rbTemporalScan_Callback(handles.rbTemporalScan, eventdata, handles)
    end

    


    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes nmssScanningImagingDlg wait for user response (see UIRESUME)
    % uiwait(handles.nmssScanningImagingDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssScanningImagingDlg_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;



function editScanningStartPos_Callback(hObject, eventdata, handles)
    % hObject    handle to editScanningStartPos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of editScanningStartPos as text
    %        str2double(get(hObject,'String')) returns contents of editScanningStartPos as a double


% --- Executes during object creation, after setting all properties.
function editScanningStartPos_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editScanningStartPos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end



function editScanningEndPos_Callback(hObject, eventdata, handles)
    % hObject    handle to editScanningEndPos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of editScanningEndPos as text
    %        str2double(get(hObject,'String')) returns contents of editScanningEndPos as a double


% --- Executes during object creation, after setting all properties.
function editScanningEndPos_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editScanningEndPos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end


% --- Executes during object creation, after setting all properties.
function editScanningStepsize_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editScanningStepsize (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end



% --- Executes on button press in btnScanningImagingDlgOK.
function btnScanningImagingDlgOK_Callback(hObject, eventdata, handles)
    % hObject    handle to btnScanningImagingDlgOK (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global app;
    global doc;
    
    parent_handle = app.nmssMainWindow;
    
    % Get scanning stage settings
    % -------------------------------------------------
    % get x-position of the stage
    pos_x = 0;
    [status val] = nmssPSGetPosX(app.hStage);
    if (strcmp(status, 'ERROR')) 
        errordlg(val);
        return;
    end
    pos_x = val;
        
    % get y-position of the stage
    pos_y = 0;
    [status val] = nmssPSGetPosY(app.hStage);
    if (strcmp(status, 'ERROR')) 
        errordlg(val);
        return;
    end
    pos_y = val;
        
    
    % get data from GUI elements
    global nmssScanningImagingDlg_Data;
    scan_data = nmssScanningImagingDlg_Data.scanning_imaging;
    
    % -- scan type 
    if (get(handles.rbLateralScan, 'Value') == 1)
        scan_data.scan_type = 'lateral';
    elseif (get(handles.rbTemporalScan, 'Value') == 1)
        scan_data.scan_type = 'temporal';
    end

    
    if (strcmp(scan_data.scan_type,'lateral'))
        % ---------------------------------------------------
        % Lateral scan (after each exposure the stage is moved)
        % ---------------------------------------------------
        
    
        start_pos = 0;
        end_pos = 200;
        stepsize = 200;


        % get start position
        if (nmssValidateNumericEdit(handles.editScanningStartPos, 'Start'))
            start_pos = str2double(get(handles.editScanningStartPos, 'String'));
            if (start_pos < 0 | start_pos > 200)
                errordlg('Start position must be in the range of 0..200!');
                return;
            end

            scan_data.start_pos = start_pos;

        end

        % get end position
        if (nmssValidateNumericEdit(handles.editScanningEndPos, 'End'))
            end_pos = str2double(get(handles.editScanningEndPos, 'String'));
            if (end_pos < 0 | end_pos > 200)
                errordlg('End position must be in the range of 0..200!');
                return;
            end
            if (end_pos < start_pos)
                errordlg('End position must be larger than start position!');
                return;
            end

            scan_data.end_pos = end_pos;

        end


        % get stepsize
        if (nmssValidateNumericEdit(handles.editScanningEndPos, 'Step size'))
            stepsize = str2double(get(handles.editScanningStepsize, 'String'));
            if (stepsize <= 0)
                errordlg('Step size must be larger than 0!');
                return;
            end

            scan_data.stepsize_pos = stepsize;

        end

        % stores the positions, where the nan-stage has to stop
        scan_pos_array = [start_pos:stepsize:end_pos];
        num_of_pos = size(scan_pos_array,2);
        list_box_entry = cell(num_of_pos,1);
        success_indicator = ['  ' 'OK'];

        % create list of jobs
        for k=1:num_of_pos
            % this stores the information needed to perform a measurement at a
            % given position
            job = nmssResetJob();

            job.number = k;
            job.status = 0;
            job.pos.x = scan_pos_array(k);
            job.pos.y = pos_y;
            job.filename = ['Scan_', num2str(scan_pos_array(k), '%3.3f'), '.mat'];

            new_list_of_jobs(k) = job;
        end

    elseif (strcmp(scan_data.scan_type,'temporal'))
        % ---------------------------------------------------
        % Temporal scan (after each exposure there is a  delay, stage doesn't move)
        % ---------------------------------------------------
        
        
        % get temporal delay after each exposure
        if (nmssValidateNumericEdit(handles.editDelayAfterExp, 'Start'))
            delay_after_taking_image = str2double(get(handles.editDelayAfterExp, 'String'));
            if (delay_after_taking_image < scan_data.min_delay_after_taking_image)
                errordlg(['Time delay must be greater than ', num2str(scan_data.min_delay_after_taking_image), ...
                    ' ', doc.scanning_imaging.delay_unit, ' !']);
                return;
            end
            
            scan_data.delay_after_taking_image = delay_after_taking_image;

        end
        
        % get temporal delay after each exposure
        if (nmssValidateNumericEdit(handles.editDuration, 'Start'))
            duration = str2double(get(handles.editDuration, 'String'));
            if (duration < 0)
                errordlg('Duration of the measurement (min) must be greater than 0!');
                return;
            end
            
            scan_data.duration_of_measurement = duration;

        end
        
        % determine the number of jobs under the conditions of exposure
        % time, duration of scan and delay after exposure
        delay = scan_data.delay_after_taking_image ;
        duration = scan_data.duration_of_measurement;
        exposure = doc.expTime;
        num_of_exp = doc.num_of_exposures;
        
        delay_unit_scaling_factor = 1000; % corresponds to milliseconds
        if (strcmp(scan_data.delay_unit,'sec') ...
                | strcmp(scan_data.delay_unit,'s') ...
                | strcmp(scan_data.delay_unit,'seconds'))
            delay_unit_scaling_factor = 1;
        end
            
        
        % number of scan jobs
        job_duration = exposure * num_of_exp + delay;
        num_of_pos = ceil(duration * 60 * delay_unit_scaling_factor / job_duration);
        rel_exp_times = [0:job_duration:num_of_pos * job_duration];
        
        % create list of jobs
        for k=1:num_of_pos
            % this stores the information needed to perform a measurement at a
            % given position
            job = nmssResetJob();

            job.number = k;
            job.status = 0;
            job.pos.x = pos_x;
            job.pos.y = pos_y;
            job.filename = ['Temporal_Scan_', num2str(rel_exp_times(k), '%3.2f'),'_ms',  '.mat'];
            job.delay_after_taking_image = scan_data.delay_after_taking_image;

            new_list_of_jobs(k) = job;
        end
        
        
        
    end
    
    
    doc.list_of_jobs = new_list_of_jobs;
    
    % this will be displayed in the list box
    parent_handles = guidata(parent_handle);
    nmssFillJobsListbox(parent_handles.listboxNMSSJobs, doc.list_of_jobs);
    
    % update application variables
    doc.scanning_imaging = scan_data;
    
    % save data to the parent's application data    
    %guidata(handles.parent.nmssMainWindow, handles.parent);
    
    
    nmssScanningImagingDlg_CloseRequestFcn(handles.nmssScanningImagingDlg, eventdata, handles);


% --- Executes on button press in btnScanningImagingDlgCancel.
function btnScanningImagingDlgCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnScanningImagingDlgCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    nmssScanningImagingDlg_CloseRequestFcn(handles.nmssScanningImagingDlg, eventdata, handles);


% --- Executes when user attempts to close nmssScanningImagingDlg.
function nmssScanningImagingDlg_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to nmssScanningImagingDlg (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    delete(hObject);




function editScanningStepsize_Callback(hObject, eventdata, handles)
% hObject    handle to editScanningStepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editScanningStepsize as text
%        str2double(get(hObject,'String')) returns contents of editScanningStepsize as a double





function editDelayAfterExp_Callback(hObject, eventdata, handles)
% hObject    handle to editDelayAfterExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDelayAfterExp as text
%        str2double(get(hObject,'String')) returns contents of editDelayAfterExp as a double


% --- Executes during object creation, after setting all properties.
function editDelayAfterExp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDelayAfterExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in rbLateralScan.
function rbLateralScan_Callback(hObject, eventdata, handles)
% hObject    handle to rbLateralScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbLateralScan

    if (get(hObject,'Value')==1)
        
        % disable temporal scan
        set(handles.editDelayAfterExp, 'Enable', 'off');
        set(handles.editDuration, 'Enable', 'off');
        set(handles.textDelayAfterExp, 'Enable', 'off');
        set(handles.textDuration, 'Enable', 'off');
        
        % enable lateral scan
        set(handles.editScanningStartPos, 'Enable', 'on');
        set(handles.editScanningEndPos, 'Enable', 'on');
        set(handles.editScanningStepsize, 'Enable', 'on');
        set(handles.textStartPos, 'Enable', 'on');
        set(handles.textEndPos, 'Enable', 'on');
        set(handles.textStepsize, 'Enable', 'on');
        
        
        
    else
        % there is an unwanted behavoir of the radiobuttons as they are
        % implemented in Matlab. If the user clicks it while it is on it goes
        % off. To circumwent this we set it to on in such situations
        % automatically
        set(hObject,'Value',1)
    end
       



% --- Executes on button press in rbTemporalScan.
function rbTemporalScan_Callback(hObject, eventdata, handles)
% hObject    handle to rbTemporalScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbTemporalScan
 
    if (get(hObject,'Value')==1)
        % disable temporal scan
        set(handles.editDelayAfterExp, 'Enable', 'on');
        set(handles.editDuration, 'Enable', 'on');
        set(handles.textDelayAfterExp, 'Enable', 'on');
        set(handles.textDuration, 'Enable', 'on');
        
        % enable lateral scan
        set(handles.editScanningStartPos, 'Enable', 'off');
        set(handles.editScanningEndPos, 'Enable', 'off');
        set(handles.editScanningStepsize, 'Enable', 'off');
        set(handles.textStartPos, 'Enable', 'off');
        set(handles.textEndPos, 'Enable', 'off');
        set(handles.textStepsize, 'Enable', 'off');
        
    else
        % there is an unwanted behavoir of the radiobuttons as they are
        % implemented in Matlab. If the user clicks it while it is on it goes
        % off. To circumwent this we set it to on in such situations
        % automatically
        set(hObject,'Value',1)
    end
       





function editDuration_Callback(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDuration as text
%        str2double(get(hObject,'String')) returns contents of editDuration as a double


% --- Executes during object creation, after setting all properties.
function editDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


