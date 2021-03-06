function varargout = nmssWavelengthCalDlg(varargin)
% NMSSWAVELENGTHCALDLG M-file for nmssWavelengthCalDlg.fig
%      NMSSWAVELENGTHCALDLG, by itself, creates a new NMSSWAVELENGTHCALDLG or raises the existing
%      singleton*.
%
%      H = NMSSWAVELENGTHCALDLG returns the handle to a new NMSSWAVELENGTHCALDLG or the handle to
%      the existing singleton*.
%
%      NMSSWAVELENGTHCALDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSWAVELENGTHCALDLG.M with the given input arguments.
%
%      NMSSWAVELENGTHCALDLG('Property','Value',...) creates a new NMSSWAVELENGTHCALDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssWavelengthCalDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssWavelengthCalDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssWavelengthCalDlg

% Last Modified by GUIDE v2.5 18-Oct-2007 19:48:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssWavelengthCalDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssWavelengthCalDlg_OutputFcn, ...
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




% --- Executes just before nmssWavelengthCalDlg is made visible.
function nmssWavelengthCalDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssWavelengthCalDlg (see VARARGIN)

% Choose default command line output for nmssWavelengthCalDlg
handles.output = hObject;

    global nmssWavelengthCalDlgData;
    global doc;
    global app;
    
    nmssWavelengthCalDlgData.wavelength_calibration = app.wavelength_calibration;
    nmssWavelengthCalDlgData.wavelength_calibration.cur_grating_id = doc.specinfo.CurrentGratingIndex;
    
    disp('nmssWavelengthCalDlgData.wavelength_calibration.cur_grating_id');
    disp(nmssWavelengthCalDlgData.wavelength_calibration.cur_grating_id);
    set(handles.editSpectrograph_1_nm, 'String', num2str(doc.specinfo.CurrentWavelength,'%4.0f'));
    
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssWavelengthCalDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssWavelengthCalDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssWavelengthCalDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.nmssWavelengthCalDlg;


% --- Executes on button press in btnAutoCalibration.
function btnAutoCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to btnAutoCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editDistance_px_Callback(hObject, eventdata, handles)
% hObject    handle to editDistance_px (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistance_px as text
%        str2double(get(hObject,'String')) returns contents of editDistance_px as a double


% --- Executes during object creation, after setting all properties.
function editDistance_px_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistance_px (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editDistance_nm_Callback(hObject, eventdata, handles)
% hObject    handle to editDistance_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistance_nm as text
%        str2double(get(hObject,'String')) returns contents of editDistance_nm as a double


% --- Executes during object creation, after setting all properties.
function editDistance_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistance_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnSelectLaserLine_1.
function btnSelectLaserLine_1_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectLaserLine_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    global nmssWavelengthCalDlgData;
    % activate spectrum image
    global app;
    figure(app.nmssFigure);
    
    % display the current position of the grating
    set(handles.editSpectrograph_1_nm, 'String', num2str(doc.specinfo.CurrentWavelength,'%4.0f'));

    [pos_x, pos_y] = ginput(1);
    
    nmssWavelengthCalDlgData.cal_step_1.px = floor(pos_x);
    
    set(handles.editPixel_1, 'String', num2str(pos_x, '%4.0f'));
    
    
    


function editPixel_1_Callback(hObject, eventdata, handles)
% hObject    handle to editPixel_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPixel_1 as text
%        str2double(get(hObject,'String')) returns contents of editPixel_1 as a double


% --- Executes during object creation, after setting all properties.
function editPixel_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPixel_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editLaser_1_nm_Callback(hObject, eventdata, handles)
% hObject    handle to editLaser_1_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLaser_1_nm as text
%        str2double(get(hObject,'String')) returns contents of editLaser_1_nm as a double


% --- Executes during object creation, after setting all properties.
function editLaser_1_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLaser_1_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssWavelengthCalDlgData;
    global app;

    app.wavelength_calibration = nmssWavelengthCalDlgData.wavelength_calibration;
    
    figure(app.nmssFigure);
    zoom out;


    nmssWavelengthCalDlg_CloseRequestFcn(handles.nmssWavelengthCalDlg, eventdata, handles);

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssWavelengthCalDlg_CloseRequestFcn(handles.nmssWavelengthCalDlg, eventdata, handles);

function editSpectrograph_1_nm_Callback(hObject, eventdata, handles)
% hObject    handle to editSpectrograph_1_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpectrograph_1_nm as text
%        str2double(get(hObject,'String')) returns contents of editSpectrograph_1_nm as a double


% --- Executes during object creation, after setting all properties.
function editSpectrograph_1_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpectrograph_1_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes on button press in btnMoveSpectrograph.
function btnMoveSpectrograph_Callback(hObject, eventdata, handles)
% hObject    handle to btnMoveSpectrograph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % take over laser wavelength setting
    if (~nmssValidateNumericEdit(handles.editLaser_1_nm, 'Laser 1 wavelength'))
        return;
    end
    laser_wavelength = str2num(get(handles.editLaser_1_nm, 'String'));
    set(handles.editLaser_2_nm, 'String', num2str(laser_wavelength ,'%4.0f'));
    
    % call spectrograph coltrol dialog (wait until closing)
    dlg_handle = nmssSPECControlDlg();
    uiwait(dlg_handle);
    
    global doc;
    global nmssWavelengthCalDlgData;
    % check if the user hasn't changed the grating
    if (nmssWavelengthCalDlgData.wavelength_calibration.cur_grating_id ~= doc.specinfo.CurrentGratingIndex)
        errtxt = {'The grating has been changed!';'';'Please start over!'};
        errordlg(errtxt);
        % reset settings in the first step
        set(handles.editSpectrograph_1_nm, 'String', num2str(doc.specinfo.CurrentWavelength,'%4.0f'));
        set(handles.editPixel_1, 'String', num2str(0,'%4.0f'));
        nmssWavelengthCalDlgData.wavelength_calibration.cur_grating_id = doc.specinfo.CurrentGratingIndex;
        return;
    end
    
    % display the new position of the grating
    set(handles.editSpectrograph_2_nm, 'String', num2str(doc.specinfo.CurrentWavelength,'%4.0f'));
    
    % enable further gui elements
    set(handles.btnSelectLaserLine_2, 'Enable','on');
    

% --- Executes on button press in btnSelectLaserLine_2.
function btnSelectLaserLine_2_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectLaserLine_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    global app;
    
    % activate spectrum image
    global nmssWavelengthCalDlgData;
    figure(app.nmssFigure);
    
    % display the new position of the grating
    set(handles.editSpectrograph_2_nm, 'String', num2str(doc.specinfo.CurrentWavelength,'%4.0f'));

    

    [pos_x, pos_y] = ginput(1);
    
    nmssWavelengthCalDlgData.cal_step_2.px = floor(pos_x);
    
    set(handles.editPixel_2, 'String', num2str(nmssWavelengthCalDlgData.cal_step_2.px, '%4.0f'));
    
    spec_wl_1 = str2num(get(handles.editSpectrograph_1_nm, 'String'));
    spec_wl_2 = str2num(get(handles.editSpectrograph_2_nm, 'String'));
    px1 = nmssWavelengthCalDlgData.cal_step_1.px;
    px2 = nmssWavelengthCalDlgData.cal_step_2.px;
    
    cur_grating_id = app.wavelength_calibration.cur_grating_id
    
    % scaling information for the current grating
    nm_per_pixel = abs((spec_wl_2 - spec_wl_1) / (px2 - px1));
    
    
    nmssWavelengthCalDlgData.wavelength_calibration.nm_per_pixel(cur_grating_id) = nm_per_pixel; 
    
    txt = {['grating ', num2str(cur_grating_id), ...
        ' nm / pixel =', num2str(nmssWavelengthCalDlgData.wavelength_calibration.nm_per_pixel(cur_grating_id))]};
    warndlg(txt);
    


function editPixel_2_Callback(hObject, eventdata, handles)
% hObject    handle to editPixel_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPixel_2 as text
%        str2double(get(hObject,'String')) returns contents of editPixel_2
%        as a double


% --- Executes during object creation, after setting all properties.
function editPixel_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPixel_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editLaser_2_nm_Callback(hObject, eventdata, handles)
% hObject    handle to editLaser_2_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLaser_2_nm as text
%        str2double(get(hObject,'String')) returns contents of editLaser_2_nm as a double


% --- Executes during object creation, after setting all properties.
function editLaser_2_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLaser_2_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSpectrograph_2_nm_Callback(hObject, eventdata, handles)
% hObject    handle to editSpectrograph_2_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpectrograph_2_nm as text
%        str2double(get(hObject,'String')) returns contents of editSpectrograph_2_nm as a double


% --- Executes during object creation, after setting all properties.
function editSpectrograph_2_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpectrograph_2_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% --- Executes on button press in btnChangeLaserWavelength.
function btnChangeLaserWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to btnChangeLaserWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbAutomaticCalibration.
function rbAutomaticCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to rbAutomaticCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbAutomaticCalibration
if (get(hObject,'Value'))
    set(handles.editLaser_1_nm, 'Enable','off');
    set(handles.editLaser_2_nm, 'Enable','off');
    set(handles.btnSelectLaserLine_1, 'Enable','off');
    set(handles.btnSelectLaserLine_2, 'Enable','off');
    set(handles.editPixel_1, 'Enable','off');
    set(handles.editPixel_2, 'Enable','off');
    set(handles.btnMoveSpectrograph, 'Enable','off');
    set(handles.btnChangeLaserWavelength, 'Enable','off');
    
    % enable Auto calibration button
    set(handles.btnAutoCalibration, 'Enable','on');
end


% --- Executes on button press in rbManualCalibration.
function rbManualCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to rbManualCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbManualCalibration
if (get(hObject,'Value'))
    set(handles.editLaser_1_nm, 'Enable','on');
    %set(handles.editLaser_2_nm, 'Enable','on');
    set(handles.btnSelectLaserLine_1, 'Enable','on');
    set(handles.editPixel_1, 'Enable','inactive');
    set(handles.editPixel_2, 'Enable','inactive');
    
    % disable Auto calibration button
    set(handles.btnAutoCalibration, 'Enable','off');
    
end
    



% --- Executes when user attempts to close nmssWavelengthCalDlg.
function nmssWavelengthCalDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssWavelengthCalDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


function Set_Figure(figure_handle)
% sets the global variable which will be used in scope of this m-file thus
% in the dialog
    global nmssWavelengthCalDlgData;
    nmssWavelengthCalDlgData.target_figure = figure_handle;


% --- Executes on button press in rbSpectrographBased.
function rbSpectrographBased_Callback(hObject, eventdata, handles)
% hObject    handle to rbSpectrographBased (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbSpectrographBased
    if (get(hObject,'Value'))
        set(handles.rbTwoLaserBased, 'Value', 0);
        
        set(handles.btnMoveSpectrograph, 'Enable','on');
        set(handles.btnChangeLaserWavelength, 'Enable','off');
        set(handles.editLaser_2_nm, 'Enable','off');
        set(handles.btnSelectLaserLine_2, 'Enable','off');
        
    end

% --- Executes on button press in rbTwoLaserBased.
function rbTwoLaserBased_Callback(hObject, eventdata, handles)
% hObject    handle to rbTwoLaserBased (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbTwoLaserBased
    if (get(hObject,'Value'))
        set(handles.rbSpectrographBased, 'Value', 0);
        
        set(handles.btnMoveSpectrograph, 'Enable','off');
        set(handles.btnChangeLaserWavelength, 'Enable','on');
        set(handles.editLaser_2_nm, 'Enable','on');
        set(handles.btnSelectLaserLine_2, 'Enable','on');
    end


