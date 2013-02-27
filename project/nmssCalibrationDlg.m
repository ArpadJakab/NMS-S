function varargout = nmssCalibrationDlg(varargin)
% NMSSCALIBRATIONDLG M-file for nmssCalibrationDlg.fig
%      NMSSCALIBRATIONDLG, by itself, creates a new NMSSCALIBRATIONDLG or raises the existing
%      singleton*.
%
%      H = NMSSCALIBRATIONDLG returns the handle to a new NMSSCALIBRATIONDLG or the handle to
%      the existing singleton*.
%
%      NMSSCALIBRATIONDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSCALIBRATIONDLG.M with the given input arguments.
%
%      NMSSCALIBRATIONDLG('Property','Value',...) creates a new NMSSCALIBRATIONDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssCalibrationDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssCalibrationDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssCalibrationDlg

% Last Modified by GUIDE v2.5 26-Jan-2010 12:43:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssCalibrationDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssCalibrationDlg_OutputFcn, ...
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


% --- Executes just before nmssCalibrationDlg is made visible.
function nmssCalibrationDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssCalibrationDlg (see VARARGIN)

    % Choose default command line output for nmssCalibrationDlg
    handles.output = hObject;

    vargc = size(varargin,1);
    for k=1:vargc
        if (strcmp(varargin(k,1),'HANDLE_PARENT'))
            % access cell array element
            handles.parent = varargin{k,2};
        end
    end

    global doc;
    global app;
    handles.cali_ratio_list.x = [];
    handles.cali_ratio_list.y = [];
    handles.cali_ratio_x = app.calidata.micron_per_px.x;
    handles.cali_ratio_y = app.calidata.micron_per_px.y;
    handles.num_of_calibrations = 0;
    
    set(handles.btnCalibrationMoveStage, 'Enable','off');
    set(handles.textCaliHowtoStep2, 'Enable', 'off');
    set(handles.editCaliRatioMicronPx_x, 'String', num2str(handles.cali_ratio_x,'%3.3f'));
    set(handles.editCaliRatioMicronPx_y, 'String', num2str(handles.cali_ratio_y,'%3.3f'));
    
    

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes nmssCalibrationDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssCalibrationDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssCalibrationDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnPos1.
function btnPos1_Callback(hObject, eventdata, handles)
% hObject    handle to btnPos1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % refresh image (deletes old markers)    
    global app;
    RefreshImage();

    % get current position of the stage
    handles.stage_xPos1 = 0;
    [status val] = nmssPSGetPosX(app.hStage);
    if (strcmp(status, 'ERROR')) 
        errordlg(val);
        return;
    end
    handles.stage_xPos1 = val;

    handles.stage_yPos1 = 0;
    [status val] = nmssPSGetPosY(app.hStage);
    if (strcmp(status, 'ERROR')) 
        errordlg(val);
        return;
    end
    handles.stage_yPos1 = val;


    % get selection cursor to mark the initial position of the structure
    % to be tracked for calibration
    [xPos1 yPos1] = ginput(1);
 
    nmssDrawCross(xPos1, yPos1, 3, 3);
    
    set(handles.editPos1X, 'String', num2str(xPos1,'%4.0f'));
    set(handles.editPos1Y, 'String', num2str(yPos1,'%4.0f'));
    
    handles.xPos1 = xPos1;
    handles.yPos1 = yPos1;
    
    % enable next steps
    set(handles.btnCalibrationMoveStage, 'Enable','on');
    set(handles.textCaliHowtoStep2, 'Enable', 'on');
    
    set(handles.btnPos1, 'Enable', 'off');
    set(handles.textCaliHowtoStep1, 'Enable', 'off');
    
    % Update handles structure
    guidata(hObject, handles);

%  
function RefreshImage()
% clears markers or other items drawn on the image
    global app;
    global doc;
    
    figure_handles = guidata(app.nmssFigure);

    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    
    figure(app.nmssFigure);
    current_limits.x = xlim;
    current_limits.y = ylim;
    
    nmssPaintImage('refresh', doc.img, app.nmssFigure, figure_handles.canvasFigureAxes, full_lim, current_limits);



% --- Executes on button press in btnPos2.
function btnPos2_Callback(hObject, eventdata, handles)
% hObject    handle to btnPos2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global app;
    figure(app.nmssFigure);
    
    [xPos2 yPos2] = ginput(1);
 
    nmssDrawCross(xPos2, yPos2, 3, 3);

    set(handles.editPos2X, 'String', num2str(xPos2,'%4.0f'));
    set(handles.editPos2Y, 'String', num2str(yPos2,'%4.0f'));
    
    
    % get current position of the stage
    global app;
    handles.stage_xPos2 = 0;
    [status val] = nmssPSGetPosX(app.hStage);
    if (strcmp(status, 'ERROR')) 
        errordlg(val);
        return;
    end
    handles.stage_xPos2 = val;

    handles.stage_yPos2 = 0;
    [status val] = nmssPSGetPosY(app.hStage);
    if (strcmp(status, 'ERROR')) 
        errordlg(val);
        return;
    end
    handles.stage_yPos2 = val;

    % calculate distance (in microns) travelled by the stage
    stage_xDist = handles.stage_xPos2 - handles.stage_xPos1;
    stage_yDist = handles.stage_yPos2 - handles.stage_yPos1;
    stage_fullDist = sqrt(stage_xDist^2 + stage_yDist^2);
    
    set(handles.editDistMicronX, 'String', num2str(stage_xDist,'%3.2f'));
    set(handles.editDistMicronY, 'String', num2str(stage_yDist,'%3.2f'));
    set(handles.editDistMicronFull, 'String', num2str(stage_fullDist,'%3.2f'));
    
    % calculate distance (in camera pixels) on image 
    xPos1 = handles.xPos1;
    yPos1 = handles.yPos1;
    user_xDist = xPos2 - xPos1;
    user_yDist = yPos2 - yPos1;
    user_fullDist = sqrt(user_xDist^2 + user_yDist^2);
    
    set(handles.editDistPxX, 'String', num2str(user_xDist,'%4.0f'));
    set(handles.editDistPxY, 'String', num2str(user_yDist,'%4.0f'));
    set(handles.editDistPxFull, 'String', num2str(user_fullDist,'%4.0f'));
    
    cali_ratio_x  = handles.cali_ratio_x;
    if (abs(stage_xDist) >= 0.01) % only horizontal stage movement (movements smaller than 10nm are not considered)
        cali_ratio_x = abs(stage_xDist / user_xDist);
        
        % question dialog about whether the user accepts the calculated
        % calibration ratio. In case something went wrong or other factors were
        % negatively impacting the calculation of the calibration ratio the
        % user has the oppurtunity here to reject the result
        txt = {['this calibration step resulted in a micron / pixel ratio of :'], 
               [num2str(cali_ratio_x,'%3.3f'), ' in X-direction'], 
               ['Do you accept this?']};
        button = questdlg(txt,'Nano-Multi-Scan Spec','Yes','No','Yes');
        if (strcmp('Yes',button))   

            % calculate calibration ratio of micron per pixel
            handles.cali_ratio_list.x = [handles.cali_ratio_list.x, cali_ratio_x];
            handles.cali_ratio_x = median(handles.cali_ratio_list.x(:));
            set(handles.editCaliRatioMicronPx_x, 'String', num2str(handles.cali_ratio_x,'%3.3f'));
        end
    end
    
    cali_ratio_y  = handles.cali_ratio_y;
    disp(stage_yDist);
    if (abs(stage_yDist) >= 0.01) % only vertical stage movement (movements smaller than 10nm are not considered)
        cali_ratio_y = abs(stage_yDist / user_yDist);
        % question dialog about whether the user accepts the calculated
        % calibration ratio. In case something went wrong or other factors were
        % negatively impacting the calculation of the calibration ratio the
        % user has the oppurtunity here to reject the result
        txt = {['this calibration step resulted in a micron / pixel ratio of :'], 
               [num2str(cali_ratio_y,'%3.3f'), ' in Y-direction'], 
               ['Do you accept this?']};
        button = questdlg(txt,'Nano-Multi-Scan Spec','Yes','No','Yes');
        if (strcmp('Yes',button))   

            % calculate calibration ratio of micron per pixel
            handles.cali_ratio_list.y = [handles.cali_ratio_list.y, cali_ratio_y];
            handles.cali_ratio_y = median(handles.cali_ratio_list.y(:));
            set(handles.editCaliRatioMicronPx_y, 'String', num2str(handles.cali_ratio_y,'%3.3f'));

        end
    end
    
    
    % enable next steps
    set(handles.btnPos1, 'Enable','on');
    set(handles.textCaliHowtoStep1, 'Enable', 'on');
    
    set(handles.btnPos2, 'Enable', 'off');
    set(handles.textCaliHowtoStep3, 'Enable', 'off');
    
    % Update handles structure
    guidata(hObject, handles);
    
    
    
function editPos1X_Callback(hObject, eventdata, handles)
% hObject    handle to editPos1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPos1X as text
%        str2double(get(hObject,'String')) returns contents of editPos1X as a double



% --- Executes during object creation, after setting all properties.
function editPos1X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPos1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



% --- Executes during object creation, after setting all properties.
function editPos1Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPos1Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



% --- Executes during object creation, after setting all properties.
function editPos2X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPos2X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



function editPos2Y_Callback(hObject, eventdata, handles)
% hObject    handle to editPos2Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPos2Y as text
%        str2double(get(hObject,'String')) returns contents of editPos2Y as a double


% --- Executes during object creation, after setting all properties.
function editPos2Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPos2Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



function editDistPxFull_Callback(hObject, eventdata, handles)
% hObject    handle to editDistPxFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistPxFull as text
%        str2double(get(hObject,'String')) returns contents of editDistPxFull as a double


% --- Executes during object creation, after setting all properties.
function editDistPxFull_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistPxFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



function editDistPxX_Callback(hObject, eventdata, handles)
% hObject    handle to editDistPxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistPxX as text
%        str2double(get(hObject,'String')) returns contents of editDistPxX as a double


% --- Executes during object creation, after setting all properties.
function editDistPxX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistPxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



% --- Executes during object creation, after setting all properties.
function editDistPxY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistPxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes on button press in btnCalibrationMoveStage.
function btnCalibrationMoveStage_Callback(hObject, eventdata, handles)
% hObject    handle to btnCalibrationMoveStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % switch on live moving modus (take image after each move)
    handles.parent.parent.hStagePosDlgData.live_modus = 1
    nmssStagePosDlg('HANDLE_PARENT', handles.parent.parent);

    % enable and disable GUI elements for the next step
    set(hObject, 'Enable', 'off');
    set(handles.textCaliHowtoStep2, 'Enable', 'off');
    
    set(handles.btnPos2, 'Enable', 'on');
    set(handles.textCaliHowtoStep3, 'Enable', 'on');



% --- Executes during object creation, after setting all properties.
function editCaliRatioMicronPx_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCaliRatioMicronPx_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor','white');


% --- Executes during object creation, after setting all properties.
function editNumCaliSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumCaliSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));



% --- Executes during object creation, after setting all properties.
function editDistMicronFull_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMicronFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));




% --- Executes during object creation, after setting all properties.
function editDistMicronX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMicronX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes during object creation, after setting all properties.
function editDistMicronY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMicronY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % this is the place to save back all relevant information into the main
    % window
    
    % Update handles structure
    global app;
    
    % save data to the main window's application data
    if (~nmssValidateNumericEdit(handles.editCaliRatioMicronPx_x, 'Calibration ratio x'))
        return;
    end
    if (~nmssValidateNumericEdit(handles.editCaliRatioMicronPx_y, 'Calibration ratio y'))
        return;
    end
    app.calidata.micron_per_px.x = str2num(get(handles.editCaliRatioMicronPx_x, 'String'));
    app.calidata.micron_per_px.y = str2num(get(handles.editCaliRatioMicronPx_y, 'String'));
    
    nmssCalibrationDlg_CloseRequestFcn(handles.nmssCalibrationDlg, eventdata, handles);

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssCalibrationDlg_CloseRequestFcn(handles.nmssCalibrationDlg, eventdata, handles);


% --- Executes when user attempts to close nmssCalibrationDlg.
function nmssCalibrationDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssCalibrationDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %nmssFigure('HANDLE_PARENT', handles.parent.parent);
    clear target_figure; % clear global variable used only in this m-file

    % Hint: delete(hObject) closes the figure
    delete(hObject);




function editCaliRatioMicronPx_x_Callback(hObject, eventdata, handles)
% hObject    handle to editCaliRatioMicronPx_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCaliRatioMicronPx_x as text
%        str2double(get(hObject,'String')) returns contents of editCaliRatioMicronPx_x as a double



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editCaliRatioMicronPx_y_Callback(hObject, eventdata, handles)
% hObject    handle to editCaliRatioMicronPx_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCaliRatioMicronPx_y as text
%        str2double(get(hObject,'String')) returns contents of editCaliRatioMicronPx_y as a double


% --- Executes during object creation, after setting all properties.
function editCaliRatioMicronPx_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCaliRatioMicronPx_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function Set_Figure(figure_handle)
% sets the global variable which will be used in scope of this m-file thus
% in the dialog
    global target_figure;
    target_figure = figure_handle;


% --- Executes on button press in pbDelCaliRatioX.
function pbDelCaliRatioX_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelCaliRatioX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.cali_ratio_list.x = [];
    handles.num_of_calibrations = 0;
    handles.cali_ratio_x = 0;
    
    set(handles.editCaliRatioMicronPx_x, 'String', num2str(handles.cali_ratio_x,'%3.3f'));
    

    % Update handles structure
    guidata(hObject, handles);




% --- Executes on button press in pbDelCaliRatioY.
function pbDelCaliRatioY_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelCaliRatioY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.cali_ratio_list.y = [];
    handles.num_of_calibrations = 0;
    handles.cali_ratio_y = 0;
    
    set(handles.editCaliRatioMicronPx_y, 'String', num2str(handles.cali_ratio_y,'%3.3f'));

    % Update handles structure
    guidata(hObject, handles);
