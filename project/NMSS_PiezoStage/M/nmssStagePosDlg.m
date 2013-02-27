function varargout = nmssStagePosDlg(varargin)
% NMSSSTAGEPOSDLG M-file for nmssStagePosDlg.fig
%      NMSSSTAGEPOSDLG, by itself, creates a new NMSSSTAGEPOSDLG or raises the existing
%      singleton*.
%
%      H = NMSSSTAGEPOSDLG returns the handle to a new NMSSSTAGEPOSDLG or the handle to
%      the existing singleton*.
%
%      NMSSSTAGEPOSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSSTAGEPOSDLG.M with the given input arguments.
%
%      NMSSSTAGEPOSDLG('Property','Value',...) creates a new NMSSSTAGEPOSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssStagePosDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssStagePosDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssStagePosDlg

% Last Modified by GUIDE v2.5 07-Sep-2007 16:37:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssStagePosDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssStagePosDlg_OutputFcn, ...
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


% --- Executes just before nmssStagePosDlg is made visible.
function nmssStagePosDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to nmssStagePosDlg (see VARARGIN)

    % Choose default command line output for nmssStagePosDlg
    handles.output = hObject;
    
    % modal 'move stage dialog' (user can only intereact with this dialog)
    set(hObject,'WindowStyle','modal');


%     parentfound = false;
%     vargc = size(varargin,1);
%     for k=1:vargc
%         if (strcmp(varargin(k,1),'HANDLE_PARENT'))
%             % access cell array element
%             handles.parent = varargin{k,2};
%             parentfound = true;
%         end
%     end
    global doc;

    [status returnval] = nmssStageInit(handles);
    if (strcmp(status, 'OK'))
        handles = returnval;
    end

    set(handles.leStageStepSize, 'String' , doc.hStagePosDlgData.step_size);
    set(handles.chbxLiveModus, 'Value', doc.hStagePosDlgData.live_modus);

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes nmssStagePosDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssStagePosDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssStagePosDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in btnStageMvFront.
function btnStageMvFront_Callback(hObject, eventdata, handles)
% hObject    handle to btnStageMvFront (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (~nmssValidateNumericEdit(handles.leStageStepSize, 'Step size'))
        return;
    end
    
    global app;
    
    [status val] = nmssPSGetPosY(app.hStage);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
        return;
    else
        lStageStepSize = str2num(get(handles.leStageStepSize,'String'));
        new_stagePosY = val - lStageStepSize;
        [status val] = nmssPSSetPosY(app.hStage, new_stagePosY);
        if (strcmp(status, 'ERROR')) 
            warndlg(val);
            return;
        else
            set(handles.leStagePosY, 'String', num2str(new_stagePosY, '%3.1f'));
        end
    end
    nmssStagePosDlg_LiveImaging(handles);
    % Update handles structure
    guidata(hObject, handles);



% --- Executes on button press in btnStageMvBack.
function btnStageMvBack_Callback(hObject, eventdata, handles)
% hObject    handle to btnStageMvBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (~nmssValidateNumericEdit(handles.leStageStepSize, 'Step size'))
        return;
    end
    
    global app;
    
    [status val] = nmssPSGetPosY(app.hStage);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
        return;
    else
        lStageStepSize = str2num(get(handles.leStageStepSize,'String'));
        new_stagePosY =  val + lStageStepSize;
        [status val] = nmssPSSetPosY(app.hStage, new_stagePosY);
        if (strcmp(status, 'ERROR')) 
            warndlg(val);
            return
        else
            set(handles.leStagePosY, 'String', num2str(new_stagePosY, '%3.1f'));
        end
    end
    nmssStagePosDlg_LiveImaging(handles);
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in btnStageMvRight.
function btnStageMvRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnStageMvRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (~nmssValidateNumericEdit(handles.leStageStepSize, 'Step size'))
        return;
    end
    
    global app;
    
    [status val] = nmssPSGetPosX(app.hStage);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
        return
    else
        lStageStepSize = str2num(get(handles.leStageStepSize,'String'));
        new_stagePosX =  val - lStageStepSize;
        [status val] = nmssPSSetPosX(app.hStage, new_stagePosX);
        if (strcmp(status, 'ERROR')) 
            warndlg(val);
            return
        else
            set(handles.leStagePosX, 'String', num2str(new_stagePosX, '%3.1f'));
        end
    end
    nmssStagePosDlg_LiveImaging(handles);
    % Update handles structure
    guidata(hObject, handles);



% --- Executes on button press in btnStageMvLeft.
function btnStageMvLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnStageMvLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (~nmssValidateNumericEdit(handles.leStageStepSize, 'Step size'))
        return;
    end
    
    global app;
    
    [status val] = nmssPSGetPosX(app.hStage);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
        return
    else
        lStageStepSize = str2num(get(handles.leStageStepSize,'String'));
        new_stagePosX =  val + lStageStepSize;
        [status val] = nmssPSSetPosX(app.hStage, new_stagePosX);
        if (strcmp(status, 'ERROR')) 
            warndlg(val);
            return
        else
            set(handles.leStagePosX, 'String', num2str(new_stagePosX, '%3.1f'));
        end
    end
    
    nmssStagePosDlg_LiveImaging(handles);
    % Update handles structure
    guidata(hObject, handles);






function leStagePosX_Callback(hObject, eventdata, handles)
% hObject    handle to leStagePosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leStagePosX as text
%        str2double(get(hObject,'String')) returns contents of leStagePosX as a double


% --- Executes during object creation, after setting all properties.
function leStagePosX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leStagePosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end





function leStagePosY_Callback(hObject, eventdata, handles)
% hObject    handle to leStagePosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leStagePosY as text
%        str2double(get(hObject,'String')) returns contents of leStagePosY as a double


% --- Executes during object creation, after setting all properties.
function leStagePosY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leStagePosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end


% --- Executes on button press in btnStageMove.
function btnStageMove_Callback(hObject, eventdata, handles)
% hObject    handle to btnStageMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (~nmssValidateNumericEdit(handles.leStagePosX, 'x (um)'))
        return;
    end
    if (~nmssValidateNumericEdit(handles.leStagePosX, 'y (um)'))
        return;
    end
    
    new_x = str2num(get(handles.leStagePosX,'String'));
    new_y = str2num(get(handles.leStagePosY,'String'));
    
    global app;
    nmssStageMove(handles, app.hStage, new_x, new_y);

    nmssStagePosDlg_LiveImaging(handles);

    % Update handles structure
    guidata(hObject, handles);



function leStageStepSize_Callback(hObject, eventdata, handles)
    % hObject    handle to leStageStepSize (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of leStageStepSize as text
    %        str2double(get(hObject,'String')) returns contents of leStageStepSize as a double


% --- Executes during object creation, after setting all properties.
function leStageStepSize_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to leStageStepSize (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end


% --- Executes on button press in btnStagePositionDlgCancel.
function btnStagePositionDlgCancel_Callback(hObject, eventdata, handles)
    % hObject    handle to btnStagePositionDlgCancel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    nmssStagePosDlg_CloseRequestFcn(handles.nmssStagePosDlg, eventdata, handles);


% --- Executes when user attempts to close nmssStagePosDlg.
function nmssStagePosDlg_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to nmssStagePosDlg (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    delete(hObject);




% --- Executes on button press in btnStagePositionDlgOK.
function btnStagePositionDlgOK_Callback(hObject, eventdata, handles)
    % hObject    handle to btnStagePositionDlgOK (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    if (~nmssValidateNumericEdit(handles.leStageStepSize, 'Step size'))
        return;
    end
    
    global doc;
    doc.hStagePosDlgData.step_size = get(handles.leStageStepSize, 'String');
    doc.hStagePosDlgData.live_modus = get(handles.chbxLiveModus, 'Value');
    
    nmssStagePosDlg_CloseRequestFcn(handles.nmssStagePosDlg, eventdata, handles);


% --- Executes on button press in chbxLiveModus.
function chbxLiveModus_Callback(hObject, eventdata, handles)
% hObject    handle to chbxLiveModus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxLiveModus


function nmssStagePosDlg_LiveImaging(handles)
% Take image after each stage movement
% hndles     structure with handles and user data (see GUIDATA)
    live_modus = get(handles.chbxLiveModus, 'Value');
    
    % no live imaging? so what the hell are you looking for here?
    if (~live_modus)
        return;
    end
    
    global app;
    hCam = app.hCamera;
    
    global doc;
    expTime = doc.expTime;
    %expTime = str2double(get(handles.parent.edExpTime,'String'));
    
    set(handles.nmssStagePosDlg,'Pointer','watch');
    [status camera_image] = nmssTakeImage(hCam, expTime, 1, -1);
    set(handles.nmssStagePosDlg,'Pointer','arrow');

    % check if correct image has been received
    if (size(camera_image,1) == 0)
        errordlg('No image received from the camera!');
        return;
    end
    
    % display image in figure
    
    % get image figure dialog
    %handles.parent.parent.hCameraImage = 0;
    %handles.parent.hFigure = nmssFigure('HANDLE_PARENT', handles.parent, 'IMAGE', camera_image');
    doc.img = camera_image';
    job = nmssResetJob();
    job.grating = doc.specinfo.CurrentGratingIndex;
    job.central_wavelength = doc.specinfo.CurrentWavelength;
    job.status = 1;
    
    doc.current_job = job;

    % refresh and activate image
    RefreshImage();

%  
function RefreshImage()
% clears markers or other items drawn on the image
    global app;
    global doc;
    
    if (~ishandle(app.nmssFigure))
        nmssFigure();
    end
    figure_handles = guidata(app.nmssFigure);
    

    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    
    figure(app.nmssFigure);
    current_limits.x = xlim;
    current_limits.y = ylim;

    nmssPaintImage('refresh', doc.img, app.nmssFigure, figure_handles.canvasFigureAxes, full_lim, current_limits);
    

